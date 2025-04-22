#!/usr/bin/bash

#####################
## constract VT non-redundant 
#######################

### first merge all the viral contig from vt data
#opt_dir="vt_abundance"
#mkdir $opt_dir
#merged_vt_fasta="$opt_dir/viral_from_vt.fasta"
#
#if [ -e $merged_vt_fasta ];then rm -rf $merged_vt_fasta;fi
#
#
#while read line;do
#
#    echo $line
#    sample_name=`echo $line|awk -F / '{print $(NF-1)}'|sed 's/_merge//'`
#    echo $sample_name
#    cat $line|sed "s/>/>${sample_name}_/" >> $merged_vt_fasta
#
#done <<<`ls vs1/*[0-9]_merge/vs1_db12_merged.viral.fasta`
###
### remove redundant using mash
#mash_opt="$opt_dir/mash"
#mkdir $mash_opt
#. /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/runmash.sh
#runSketchMulfa $merged_vt_fasta
#runMashScreen $merged_vt_fasta.k21.s10000.msh $merged_vt_fasta.k21.s10000.msh $mash_opt/viral_from_vt.mashscreen.txt
#cd $opt_dir
#python /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/mash_clstr.py viral_from_vt.fasta mash/viral_from_vt.mashscreen.txt 95
#cd -


########################
## vt to virome non-reduncant
########################


query_contig=${1:-"/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/vt_abundance/mashani_rep_id95.0.fasta"}
ref_contig=${2:-"/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/virome_abundance/mashani_rep_id95.0.fasta"}
sample=${3:-"virome_nonredundant"}
outdir=${4:-"vt2virome_blast"}
treads=${5:-30}

rename_ref_contig=`python /home/viro/xue.peng/script/utility_python/rename_seq_id_substring.py $ref_contig "_" 0 4`
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate blast 

mkdir -p $outdir
cwd=`pwd`
#cd $outdir

makeblastdb -in $rename_ref_contig -dbtype nucl -parse_seqids -out $outdir/$sample.blastdb
blastn -query $query_contig -db $outdir/$sample.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 10 -num_threads $treads -out $outdir/$sample.blastn.opt.tsv

