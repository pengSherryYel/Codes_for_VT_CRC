#!/bin/bash

###To de-replicate the scaffolds, you will cluster them at 95% Average Nucleotide Identify (ANI) over 85% of the length of the shorter sequence, cutoffs often used to cluster viral genomes at the species level.From CheckV




contigs=$1
sample=$2
outdir=$3
treads=${4:-2}
minani=${5:-95}
min_tcov=${6:-85}
min_qcov=${7:-0}


. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate day1_env


script_dir=`realpath $0`
script_dir=`dirname $script_dir`
opt_real_dir=`realpath $outdir`
blastdb_dir="$opt_real_dir/db/$sample"
echo "$scirpt_dir"
mkdir -p $outdir
mkdir -p $blastdb_dir
cwd=`pwd`
cp $contigs $outdir

cd $outdir
makeblastdb -in $contigs -dbtype nucl -parse_seqids -out $blastdb_dir/$sample.blastdb
blastn -query $contigs -db $blastdb_dir/$sample.blastdb -outfmt '6 std qlen slen' -max_target_seqs 10000 -num_threads $treads -out $sample.blast.all2all.tsv
python $script_dir/ani_script/anicalc.py -i $sample.blast.all2all.tsv -o $sample.ani.tsv
#python $script_dir/ani_script/aniclust.py --fna $contigs --ani $sample.ani.tsv --out ctg_clusters.tsv --min_ani 95 --min_tcov 85 --min_qcov 0
python $script_dir/ani_script/aniclust.py --fna $contigs --ani $sample.ani.tsv --out ctg_clusters.ani_$minani.tcov_$min_tcov.tsv --min_ani $minani --min_tcov $min_tcov --min_qcov $min_qcov
cut -f1 ctg_clusters.ani_$minani.tcov_$min_tcov.tsv | sort -u > rep.list
seqkit grep -f rep.list $contigs > rep.fasta
cd $cwd
