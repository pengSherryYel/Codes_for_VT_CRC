#!/usr/bin/bash


opt_dir="uhgg_contig_nonred_Rab"
mkdir -p $opt_dir

#########################
### based on the uhgg and scaffold >=1000 contig after CDHIT, merge all the samples and create one bacteria dataset to get relative abundance.
### CDHIT
#. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
#conda activate blast
#
#cdhit_outDir="uhgg_contig_derep"
#cdhit_opt=`ls ${cdhit_outDir}/*_cdhit/*.uhgg.contig.merged_long_idt0.95.rep.fasta`
#echo $cdhit_opt
#cat $cdhit_opt|seqkit rmdup > $opt_dir/redundant_allSample.uhgg_scaffold.fasta
#
#sh /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/run_cdhit_ctg_cluster.sh ./$opt_dir/redundant_allSample.uhgg_scaffold.fasta 0.95 long ${opt_dir}/allSample_cdhit
#
#
#
#################################################################
### build bowtie index for VT read mapping and bacteria relative abundance 
#################################################################
### example: uhgg_contig_derep/MTHDA8355_b_cdhit/MTHDA8355_b.uhgg.contig.merged_long_idt0.95.rep.fasta
#cdhit_opt="$opt_dir/allSample_cdhit/redundant_allSample.uhgg_scaffold_long_idt0.95.rep.fasta"
#
#########################
###Bowtie2 mapping to derep contig and binning
#. /home/viro/xue.peng/script/bt2.sh
#btbuild $cdhit_opt $opt_dir/bt2Index/allSample_bacteria_uhgg "--threads 20"
#

############################################################
### predict CRISPR  from bacteria
##########################################################
cdhit_opt=`realpath $opt_dir/allSample_cdhit/redundant_allSample.uhgg_scaffold_long_idt0.95.rep.fasta`
echo $cdhit_opt
crispr_dir="$opt_dir/CRISPR"
mkdir -p $crispr_dir
cd $crispr_dir
seqtk split -n 50 redundant_allSample.uhgg_scaffold_long_idt0.95.rep.split $cdhit_opt
ls *.fa|awk -F .  '{printf "#!/usr/bin/bash\nsh /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/run_crisprIdentify.sh %s crisprIdentify_opt_%s\n",$0,$(NF-1) }'|split -l 2 - sbatch.crispr.sh
cd -

