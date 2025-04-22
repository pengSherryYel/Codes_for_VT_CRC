#!/usr/bin/bash

. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate checkm

export CHECKM_DATA_PATH=/home/viro/xue.peng/publicData/checkm_db
## infile is 2 or 3 coloumn file, genomeID fna faa (TAB Sep)
infile=$1
outputDir=${2:-"./gtdb_checkm"}

## small dataset 
#checkm lineage_wf $infile $outputDir -t 5 


## large dataset each one seperate 
while read line;do
    read prefix fna <<< `echo $line`
    outdir_sample="$outputDir/$prefix"
    mkdir -p $outdir_sample
    echo -e "$prefix\t$fna" >$prefix.tmp 

    checkm lineage_wf $prefix.tmp $outdir_sample -t 5 && rm $prefix.tmp
done < $infile
