#!/usr/bin/bash
prefix=$1
contigfa=`realpath $2`
bamfile=`realpath $3`
parent_dir=${4:-"metabat"}

##parent dir is where to store the results. default is ./metabat

#outdir="metabat_modifyP/$prefix"
outdir="$parent_dir/$prefix"
mkdir -p $outdir

## use prefix only to find the contig and bamfile
## default 
cd $outdir
/home/viro/xue.peng/software_home/metabat/metabat/runMetaBat.sh $contigfa $bamfile 
cd -

## paramter
#sft_path="/home/viro/xue.peng/software_home/metabat/metabat"
#$sft_path/jgi_summarize_bam_contig_depths --outputDepth $outdir/$prefix.depth.txt $bamfile
#$sft_path/metabat2 -i $contigfa -a $outdir/$prefix.depth.txt -o $outdir/bin -t 3 -m 2000 -s 100000
