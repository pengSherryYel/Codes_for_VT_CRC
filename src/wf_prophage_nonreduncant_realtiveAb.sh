#!/usr/bin/bash


opt_dir="uhgg_contig_prophage_nonred_Rab"
mkdir -p $opt_dir

########################
## based on the uhgg and scaffold >=1000 contig after CDHIT, merge all the samples and create one prophage dataset to get relative abundance.
## CDHIT
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate blast

cdhit_outDir="genomad_cdhit"
cdhit_opt=`ls ${cdhit_outDir}/*/*_find_proviruses/*rep_provirus.fna`
echo $cdhit_opt
cat $cdhit_opt|seqkit rmdup > $opt_dir/redundant_allSample.uhgg_scaffold.prophage.fasta

sh /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/run_cdhit_ctg_cluster.sh ./$opt_dir/redundant_allSample.uhgg_scaffold.prophage.fasta 0.95 long ${opt_dir}/allSample_cdhit


## build bowtie index for VT read mapping and bacteria relative abundance 
## example: uhgg_contig_derep/MTHDA8355_b_cdhit/MTHDA8355_b.uhgg.contig.merged_long_idt0.95.rep.fasta
cdhit_opt="$opt_dir/allSample_cdhit/redundant_allSample.uhgg_scaffold.prophage_long_idt0.95.rep.fasta"

########################
##Bowtie2 mapping to derep contig and binning
. /home/viro/xue.peng/script/bt2.sh
btbuild $cdhit_opt $opt_dir/bt2Index/allSample_bacteria_uhgg_prophage "--threads 20"


