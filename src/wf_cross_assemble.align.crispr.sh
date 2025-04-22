#!/usr/bin/bash

########################
## inhouse bacteria crispr DB align to non_redundant cross assemble contig
########################

query_contig="/home/viro/xue.peng/workplace_2023/CRC_community_vt/results_16s/uhgg_contig_nonred_Rab/CRISPR.bacteria.merged.fasta "
outdir="./cross_assemble_abundance/crossAss2bacCrisprDB_blast"
treads=6

. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate blast

mkdir -p $outdir
cwd=`pwd`


blastn -query $query_contig -db ./cross_assemble_abundance/mash/CRC_advance/blastRefDB/CRC_advance.mashani_rep_id95.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 1000 -num_threads $treads -out $outdir/bacCrisprDB.CRC_advance.blastn.opt.tsv

blastn -query $query_contig -db ./cross_assemble_abundance/mash/CRC_early/blastRefDB/CRC_early.mashani_rep_id95.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 1000 -num_threads $treads -out $outdir/bacCrisprDB.CRC_early.blastn.opt.tsv

blastn -query $query_contig -db ./cross_assemble_abundance/mash/healthy/blastRefDB/healthy.mashani_rep_id95.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 1000 -num_threads $treads -out $outdir/bacCrisprDB.healthy.blastn.opt.tsv

blastn -query $query_contig -db ./cross_assemble_abundance/mash/UC/blastRefDB/UC.mashani_rep_id95.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 1000 -num_threads $treads -out $outdir/bacCrisprDB.UC.blastn.opt.tsv
