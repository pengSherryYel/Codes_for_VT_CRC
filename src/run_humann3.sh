#!/usr/bin/bash

#
sample_name=$1
fq1=$2
fq2=${3:-""}
outDir=${4:-"./humann3"}
echo ${sample_name}, $fq1, $fq2


## merge PE
outDir_merge="$outDir/${sample_name}/merge"
outDir_merge_seq="$outDir_merge/${sample_name}.merge.fq"

mkdir -p $outDir_merge

if [ -n $fq2 ];then
    echo "merge two PE seq"
    echo "seqtk mergepe $fq1 $fq2"
    zcat $fq1|sed '/^@/{s/ /_1 /};' >$outDir_merge/${sample_name}.tmp.1.fq
    zcat $fq2|sed '/^@/{s/ /_2 /};' >$outDir_merge/${sample_name}.tmp.2.fq
    cat $outDir_merge/${sample_name}.tmp.1.fq $outDir_merge/${sample_name}.tmp.2.fq >$outDir_merge_seq
    #seqtk mergepe $outDir_merge/${sample_name}.tmp.1.fq $outDir_merge/${sample_name}.tmp.2.fq >$outDir_merge_seq
    #rm -rf $outDir_merge/${sample_name}.tmp*
else
    zcat $fq1 >$outDir_merge_seq
fi

###############################
## run humann
###############################

. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate humann3

export PATH=/home/viro/xue.peng/software_home/diamond/v2.1.9:$PATH
export PATH=/home/viro/xue.peng/software_home/bowtie2_2.4.4/bowtie2-2.4.4-linux-x86_64:$PATH
outDir_humann="$outDir/${sample_name}/humann_afterM"
output_metaphlan="${outDir_humann}/metaphlan.taxonomy_profile.tsv"
mkdir -p $outDir_humann
echo "RUN COMMAND: metaphlan $outDir_merge_seq $output_metaphlan --input_type fastq --nproc 10"
metaphlan $outDir_merge_seq $output_metaphlan --input_type fastq --nproc 10 --force 

echo "RUN humann"
humann --input $outDir_merge_seq --output $outDir_humann --threads 10 --nucleotide-database /home/viro/xue.peng/software_home/humann/v3/humann-3.9/db/chocophlan --protein-database /home/viro/xue.peng/software_home/humann/v3/humann-3.9/db/uniref --metaphlan-options "-t rel_ab" -r --taxonomic-profile $output_metaphlan
echo DONE 
