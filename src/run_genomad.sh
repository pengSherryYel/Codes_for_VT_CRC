#!/usr/bin/bash

#set -e
source /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate genomad

prefix=$1
inputSeq=$2
outputDir=${3:-""}
genomad_db="/home/viro/xue.peng/publicData/genomad/genomad_db"

### defaulat output dir is for NCBI 
#if [ -z $outputDir ];then 
#    dir_prefix=${prefix:4:3}
#    dir_middle=${prefix:7:3}
#    dir_suffix=${prefix:10:3}
#    outputDir="genomad/$dir_prefix/$dir_middle/$dir_suffix"
#fi


echo $outputDir
mkdir -p $outputDir

sample_id=`echo $inputSeq|awk -F '/' '{print $NF}'|sed 's/.fna.gz//'`
summary_file="$outputDir/${sample_id}_summary/${sample_id}_virus_summary.tsv"
if [ -e $summary_file ];then
    echo "log exist! pass"
    echo `pwd`/$summary_file >>genomad.log
else 
    genomad annotate --cleanup -t 20 $inputSeq $outputDir $genomad_db
    ## provirus is only for bacteria  
    genomad find-proviruses --cleanup -t 20 $inputSeq $outputDir $genomad_db 
    #echo $outputDir done &&\
    echo `pwd`/$summary_file >>genomad.log
fi
