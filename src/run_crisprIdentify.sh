#!/usr/bin/bash

inputFa=$1
output=${2:-"crisprIdentify_opt"}
infile_type=${3:-"s"} 
## f -- folder contain each fa (--input_folder); s -- a single multiline fasta input (--file)
para=${4:-"--cpu 20"}

. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate crispr_identify_env

CRISPRidentify="/home/viro/xue.peng/software_home/CRISPRidentify/CRISPRidentify/CRISPRidentify.py"

if [ $infile_type == "s" ];then
    python $CRISPRidentify --file $inputFa --result_folder $output $para
elif [ $infile_type=="f"];then
    python $CRISPRidentify --file $inputFa --result_folder $output $para
fi
