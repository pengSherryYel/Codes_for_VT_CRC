#!/usr/bin/bash
#less 16s.datapath |sed 's/ /\t/g'|sed '1isample-id\tforward-absolute-filepath\treverse-absolute-filepath'> ./qiime2_input.manifest
#less 16s.datapath |sed 's/ /\t/g' > qiime2_input.manifest

. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate qiime2-2021.8
#qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path qiime2_input.manifest --output-path crc16s.qza --input-format PairedEndFastqManifestPhred33V2
qiime dada2 denoise-paired --i-demultiplexed-seqs crc16s.qza --p-trunc-len-f 150 --p-trunc-len-r 150 --o-representative-sequences representative-sequences.qza --o-table table.qza --o-denoising-stats denoisin-stats.qza --p-n-threads 20 
