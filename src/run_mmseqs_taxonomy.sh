#!/usr/bin/bash

inputFa=$1
name=${2:-"mmseqs_all"}
outDir=${3:-"mmseqs"}

## output dir must exist
mkdir -p $outDir/$name
mmseqs_tmp="$outDir/${name}_mmseqs_tmp"

## this is for define the virome taxonomy
mmseqs easy-taxonomy $inputFa /home/viro/xue.peng/software_home/mmseqs_db/NR_db/seqTaxOnlyVirusDB $outDir/$name $mmseqs_tmp
#mmseqs easy-taxonomy $inputFa /home/viro/xue.peng/software_home/mmseqs_db/swissprot_db/seqTaxOnlyVirusDB mmseqs/$name $mmseqs_tmp
