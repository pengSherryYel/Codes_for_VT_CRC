#!/usr/bin/bash

sample=$1
outDir=${2:-"uhgg_contig_derep"}

#seqtk subseq /home/viro/xue.peng/publicData/uhgg/v2.0.1/species_catalogue_merged.4744.fna $outDir/$sample.header >$outDir/$sample.uhgg.fasta
#cat assemble_spades/$sample/scaffolds.gt1000.fasta $outDir/$sample.uhgg.fasta > $outDir/$sample.uhgg.contig.merged.fasta
#rm $outDir/$sample.uhgg.fasta

########################
##CDHIT
#. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
#conda activate blast
#sh /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/run_cdhit_ctg_cluster.sh $outDir/$sample.uhgg.contig.merged.fasta 0.95 long ${outDir}/${sample}_cdhit

## example: uhgg_contig_derep/MTHDA8355_b_cdhit/MTHDA8355_b.uhgg.contig.merged_long_idt0.95.rep.fasta
cdhit_opt="$outDir/${sample}_cdhit/${sample}.uhgg.contig.merged_long_idt0.95.rep.fasta"


########################
##Bowtie2 mapping to derep contig and binning
#. /home/viro/xue.peng/script/bt2.sh
#btbuild $cdhit_opt $outDir/bt2Index_$sample/$sample "--threads 20"

#fastpfq1="./qc/$sample/$sample.1.fastq.gz"
#fastpfq2="./qc/$sample/$sample.2.fastq.gz"
#btalign $outDir/bt2Index_$sample/$sample $fastpfq1 $fastpfq2 $sample "--sensitive-local -q -p 20" $outDir/bt2align_$sample 
#samtoolsStat $outDir/bt2align_$sample/$sample/$sample.bam
bam_sort_opt="$outDir/bt2align_$sample/$sample/$sample.sort.bam"

##########################
##MATBAT
#sh run_metabat.sh $sample $cdhit_opt $bam_sort_opt $outDir/metabat

########################
##CheckM
checkM_opt="$outDir/checkm/$sample"
#mkdir -p $checkM_opt
#
#. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
#conda activate checkm
#export CHECKM_DATA_PATH=/home/viro/xue.peng/publicData/checkm_db
#
####Because MTQEF8348_b have no bins so use contig instead
#if [ $sample != "MTQEF8348_b" ];then
#    #ls uhgg_contig_derep/metabat/*/*bins/*fa|awk -F / '{printf "%s_%s\t%s\n",$3,$NF, $0}'|sed 's/.fa//' >$outDir/checkm/$sample/$sample.txt
#    bin_dir=`realpath $outDir/metabat/$sample/*bins`
#    checkm lineage_wf -x fa $bin_dir $checkM_opt -t 10 
#
#else
#   echo "Process $sample in contig"
#   split_dir="$checkM_opt/split_seq"
#   mkdir -p $split_dir  
#   seqkit split -i assemble_spades/MTQEF8348_b/scaffolds.gt1000.fasta -O $split_dir
#   checkm lineage_wf -x fasta $split_dir $checkM_opt -t 10 
#
#fi
#conda deactivate


##########################
### GTDB-Tk
#gtdbtk_opt="$outDir/gtdbtk/$sample"
#mkdir -p $gtdbtk_opt
#
#
#. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
#conda activate gtdbtk-2.1.1
#if [ $sample != "MTQEF8348_b" ];then
#    bin_dir=`realpath $outDir/metabat/$sample/*bins`
#    gtdbtk classify_wf --genome_dir $bin_dir --out_dir $gtdbtk_opt --cpus 10 --extension fa
#else
#    split_dir="$checkM_opt/split_seq"
#    gtdbtk classify_wf --genome_dir $split_dir --out_dir $gtdbtk_opt --cpus 10 --extension fasta
#fi

#############################

#########################
### prophage on cdhit output

genomad_dir="./genomad_cdhit"
sh ../src/run_genomad.sh $sample $cdhit_opt ${genomad_dir}/$sample

#########################
## Select binning 
## first check the binning source
#ls uhgg_contig_derep/metabat/*/*/bin*|xargs -i sh stat_binning_source.sh {} >uhgg_contig_derep/metabat.stat.source
