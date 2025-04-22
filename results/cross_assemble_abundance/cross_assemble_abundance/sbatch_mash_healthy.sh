#!/usr/bin/bash


### run mash to get non_redundant contig for each diease
. /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/runmash.sh
#runSketchMulfa /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/merged_contig/healthy/cross_assemble_all_healthy_gt1k.fasta
#echo 'run mash'
#runMashScreen /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/merged_contig/healthy/cross_assemble_all_healthy_gt1k.fasta.k21.s10000.msh /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/merged_contig/healthy/cross_assemble_all_healthy_gt1k.fasta.k21.s10000.msh /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/mash/healthy/healthy.mashscreen.txt
 
#cd /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/mash/healthy
#python /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/mash_clstr.py /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/merged_contig/healthy/cross_assemble_all_healthy_gt1k.fasta /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/mash/healthy/healthy.mashscreen.txt 95

### build blast db used for blast alignment
#. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
#conda activate blast
#
#rename_fasta=`python /home/viro/xue.peng/script/utility_python/rename_seq_id_substring.py mashani_rep_id95.0.fasta "_" 0 6`
#makeblastdb -in $rename_fasta -dbtype nucl -parse_seqids -out /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/mash/healthy/blastRefDB/healthy.mashani_rep_id95.0.blastdb 
#cd -

### crispr
#cd /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/CrisprOpenDB/healthy
#sh /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/run_CrisprOpenDB.sh /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/mash/healthy/mashani_rep_id95.0.fasta /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/CrisprOpenDB/healthy
#cd -
## merge all the results for crispr
#less CrisprOpenDB_1v1/healthy/*CrisprOpenDB_opt.txt|grep '^('|sed 's/(//'|sed 's/)//'|sed 's/'//g'|sed 's/\s\+//g' > /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/CrisprOpenDB/healthy.CrisprOpenDB.opt

### checkv (filter later in jupyter)
checkv_opt_ori="/ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/checkV/healthy/proviruses_virus_all.fna"
checkv_opt="/ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/checkV/healthy/proviruses_virus_all.level_2.fna"
#sh /home/viro/xue.peng/script/run_checkv.sh healthy /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/mash/healthy/mashani_rep_id95.0.fasta /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/checkV

### identify taxonomy
### first merge checkv results with blast results (the filter step is finished in jupyter notebook)
merged_CA_viral_check_blast_fna="/ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/nr_gpd_crossAss_genomad/healthy.CA.checkv.blast.viralContig.fna"
#seqtk subseq /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/mash/healthy/mashani_rep_id95.0.fasta /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/Viral_nodeid_inCrossAss_blast_only.csv > $merged_CA_viral_check_blast_fna
#seqtk subseq $checkv_opt_ori /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/Viral_nodeid_inCrossAss_checkv_vggt1_only.csv >> $merged_CA_viral_check_blast_fna
## because checkv prophage id have _1 extra suffix, so add it 
## use command to get prophage id 
## less checkV/*/proviruses_virus_all.fna|grep \/|sed 's/>//'|cut -d   -f 1 >checkv_prophage.id
#seqtk subseq $checkv_opt_ori /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/checkv_prophage.id >> $merged_CA_viral_check_blast_fna


### genomad (filter later in jupyter, not test on the final rep, because mem might be provide extra infomation)
#sh /ictstr01/home/viro/xue.peng/publicData/GPD/genomad/run_genomad.sh healthy $merged_CA_viral_check_blast_fna /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/nr_gpd_crossAss_genomad/healthy

### mmseqs taxonomy not work, all the contig can not be determined, so only based on genomad results (removed)
### mmseqs taxonomy (filter later in jupyter, not test on the final rep, because mem might be provide extra infomation)
##sh /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/src/run_mmseqs_taxonomy.sh $merged_CA_viral_check_blast_fna healthy /ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/nr_gpd_crossAss_mmseqsTax/healthy

### host taxonomy
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate iphop_env

host_dir="/ictstr01/home/viro/xue.peng/workplace_2023/CRC_community_vt/results/cross_assemble_abundance/cross_assemble_abundance/nr_gpd_crossAss_iphop/healthy"
mkdir -p $host_dir
iphop predict --out_dir $host_dir --db_dir /home/viro/xue.peng/software_home/iphop/iphop_db/Sept_2021_pub --num_threads 8 --fa_file $merged_CA_viral_check_blast_fna
conda deactivate

