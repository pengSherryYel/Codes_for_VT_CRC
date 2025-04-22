#!/usr/bin/bash

. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate fastq-screen

optDir="fastq_screen"

if [ ! -e $optDir ];then
    mkdir $optDir
fi

cd $optDir
## website: https://stevenwingett.github.io/FastQ-Screen/
#fastq_screen -c /home/viro/xue.peng/script/fastq_screen/fastq-screen.myconf $@
fastq_screen --subset 300000 -c /home/viro/xue.peng/workplace_2023/twins_uk/src/fastq_screen.conf $@
cd ..
