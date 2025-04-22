#!/usr/bin/bash

function krakenClassContig(){
    ##usage: krakenClassContig cotig "viral"|"bav" samplename
    contigFile=$1
    ## db should be viral|bav
    db=$2
    sample=$3

    kraken2="/home/viro/xue.peng/software_home/kraken2-v2.1.2/kraken2"
    viralDB="/home/viro/xue.peng/software_home/kraken2-v2.1.2/viral_db/v23_04_2021/"
    ## this bavdb built from the refseq bacteria, archaea, and viral libraries.
    bavDB="/home/viro/xue.peng/software_home/kraken2-v2.1.2/minikraken2_v1_8GB_201904/minikraken2_v1_8GB"
   
    echo "kraken2 start!"

    if [ $db == "viral" ];then
        $kraken2 --db $viralDB --unclassified-out ${sample}.${db}.unclassified.seq --classified-out ${sample}.${db}.classified.seq --output ${sample}.${db}.k2.output --report ${sample}.${db}.k2.report $contigFile
    elif [ $db == "bav" ];then
        $kraken2 --db $bavDB --unclassified-out ${sample}.${db}.unclassified.seq --classified-out ${sample}.${db}.classified.seq --output ${sample}.${db}.k2.output --report ${sample}.${db}.k2.report $contigFile
    else
        echo "db should be viral|bav"
    fi
  
    echo "kraken2 end!"
}

