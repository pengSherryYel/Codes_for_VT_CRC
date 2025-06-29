#!/usr/bin/bash

####################
# construct VT non-redundant 
######################

## first merge all the viral contig from vt data
opt_dir="vt_abundance"
mkdir $opt_dir
merged_vt_fasta="$opt_dir/viral_from_vt.fasta"

if [ -e $merged_vt_fasta ];then rm -rf $merged_vt_fasta;fi


while read line;do

    echo $line
    sample_name=`echo $line|awk -F / '{print $(NF-1)}'|sed 's/_merge//'`
    echo $sample_name
    cat $line|sed "s/>/>${sample_name}_/" >> $merged_vt_fasta

done <<<`ls vs1/*[0-9]_merge/vs1_db12_merged.viral.fasta`
##
## remove redundant using mash
mash_opt="$opt_dir/mash"
mkdir $mash_opt
. /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/runmash.sh
runSketchMulfa $merged_vt_fasta
runMashScreen $merged_vt_fasta.k21.s10000.msh $merged_vt_fasta.k21.s10000.msh $mash_opt/viral_from_vt.mashscreen.txt
cd $opt_dir
python /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/mash_clstr.py viral_from_vt.fasta mash/viral_from_vt.mashscreen.txt 95
cd -


