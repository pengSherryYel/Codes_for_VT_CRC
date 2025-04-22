#!/usr/bin/bash

## first merge all the viral contig from virome data
opt_dir="virome_abundance"
mkdir $opt_dir
merged_virome_fasta="$opt_dir/viral_from_virome.fasta"

if [ -e $merged_virome_fasta ];then rm -rf $merged_virome_fasta;fi


while read line;do

    echo $line
    sample_name=`echo $line|awk -F / '{print $(NF-1)}'|sed 's/_merge//'`
    echo $sample_name
    cat $line|sed "s/>/>${sample_name}_/" >> $merged_virome_fasta

done <<<`ls vs1/*v_merge/vs1_db12_merged.viral.fasta`

##
## remove redundant using mash
mash_opt="$opt_dir/mash"
mkdir $mash_opt
. /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/runmash.sh
runSketchMulfa $merged_virome_fasta
runMashScreen $merged_virome_fasta.k21.s10000.msh $merged_virome_fasta.k21.s10000.msh $mash_opt/viral_from_virome.mashscreen.txt
cd $opt_dir
python /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/mash_clstr.py viral_from_virome.fasta mash/viral_from_virome.mashscreen.txt 95
cd -
 

