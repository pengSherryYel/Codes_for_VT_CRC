#!/usr/bin/bash

sample=$1
outDir=${2:-"uhgg_contig_derep"}

seqtk subseq /home/viro/xue.peng/publicData/uhgg/v2.0.1/species_catalogue_merged.4744.fna $outDir/$sample.header >$outDir/$sample.uhgg.fasta
cat assemble_spades/$sample/scaffolds.gt1000.fasta $outDir/$sample.uhgg.fasta > $outDir/$sample.uhgg.contig.merged.fasta
rm $outDir/$sample.uhgg.fasta

########################
##CDHIT (single sample dereplication, because all samples together will cause too much memory)
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate blast
sh /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/run_cdhit_ctg_cluster.sh $outDir/$sample.uhgg.contig.merged.fasta 0.95 long ${outDir}/${sample}_cdhit
cdhit_opt="$outDir/${sample}_cdhit/${sample}.uhgg.contig.merged_long_idt0.95.rep.fasta"


########################
##Bowtie2 mapping to derep contig to assess the quality
. /home/viro/xue.peng/script/bt2.sh
btbuild $cdhit_opt $outDir/bt2Index_$sample/$sample "--threads 20"

fastpfq1="./qc/$sample/$sample.1.fastq.gz"
fastpfq2="./qc/$sample/$sample.2.fastq.gz"
btalign $outDir/bt2Index_$sample/$sample $fastpfq1 $fastpfq2 $sample "--sensitive-local -q -p 20" $outDir/bt2align_$sample 
samtoolsStat $outDir/bt2align_$sample/$sample/$sample.bam


#########################
### prophage on cdhit output

genomad_dir="./genomad_cdhit"
sh ../src/run_genomad.sh $sample $cdhit_opt ${genomad_dir}/$sample

