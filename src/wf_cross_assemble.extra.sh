#!/usr/bin/bash

#####################
## constract VT & Virome cross assemble to non-redundant 
#######################

variable=(
  "healthy"
  "UC"
  "CRC_early"
  "CRC_advance"
)


for i in "${variable[@]}"; do
     
    echo $i
     
    #####################################################
    ## first merge all the contig from cross assemble data
    ###################################################
    opt_dir=`realpath cross_assemble_abundance`
    merged_opt_dir="$opt_dir/merged_contig/$i"
    mkdir -p $merged_opt_dir
    merged_fasta_all="$opt_dir/merged_contig/cross_assemble_all4_gt1k.fasta"
    merged_fasta="$merged_opt_dir/cross_assemble_all_${i}.fasta"
    merged_fasta_gt1k="$merged_opt_dir/cross_assemble_all_${i}_gt1k.fasta"

    if [ -e $merged_fasta ];then rm -rf $merged_fasta;fi
 

    scaffold_file=`ls ./cross_assemble/assemble_spades/${i}*/scaffolds.fasta`
    echo $scaffold_file


    while read line;do
        echo $line
        sample_name=`echo $line|awk -F / '{print $(NF-1)}'|sed 's/v_{//'|sed 's/}//'`
        echo $sample_name
        cat $line|sed "s/>/>${sample_name}_/" >> $merged_fasta
        

    done <<<$scaffold_file
    seqkit seq -m 1000 $merged_fasta > $merged_fasta_gt1k
    

    ###################################################
    ## remove redundant of contig gt1k based on diease type
    ##################################################

    ###
    ## remove redundant using mash
    script="$opt_dir/sbatch_mash_${i}.sh"
    echo -e "#!/usr/bin/bash\n" >$script

    mash_opt="$opt_dir/mash/$i"
    mkdir -p $mash_opt
    
    crispr_opt="$opt_dir/CrisprOpenDB/$i"
    mkdir -p $crispr_opt

    checkv_opt="$opt_dir/checkV"
    mkdir -p $checkv_opt

    nr_gpd_ca_opt="$opt_dir/nr_gpd_crossAss"
    mkdir -p $nr_gpd_ca_opt
    
    genomad_opt="$opt_dir/nr_gpd_crossAss_genomad"
    mkdir -p $genomad_opt

    mmseqs2_tax_opt="$opt_dir/nr_gpd_crossAss_mmseqsTax"
    mkdir -p $mmseqs2_tax_opt

    iphop_opt="$opt_dir/nr_gpd_crossAss_iphop"
    mkdir -p $genomad_opt

echo "
## run mash to get non_redundant contig for each diease
. /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/runmash.sh
runSketchMulfa $merged_fasta_gt1k
echo 'run mash'
runMashScreen $merged_fasta_gt1k.k21.s10000.msh $merged_fasta_gt1k.k21.s10000.msh $mash_opt/$i.mashscreen.txt
 
cd $mash_opt
python /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/mash_clstr.py $merged_fasta_gt1k $mash_opt/$i.mashscreen.txt 95


## build blast db used for blast alignment
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate blast
rename_fasta=\`python /home/viro/xue.peng/script/utility_python/rename_seq_id_substring.py mashani_rep_id95.0.fasta \"_\" 0 6\`
makeblastdb -in \$rename_fasta -dbtype nucl -parse_seqids -out $mash_opt/blastRefDB/$i.mashani_rep_id95.0.blastdb 
cd -


### checkv (filter later in jupyter)
checkv_opt_ori=\"$checkv_opt/$i/proviruses_virus_all.fna\"
checkv_opt=\"$checkv_opt/$i/proviruses_virus_all.level_2.fna\"
sh /home/viro/xue.peng/script/run_checkv.sh $i $mash_opt/mashani_rep_id95.0.fasta $checkv_opt


### identify taxonomy
### first merge checkv results with blast results
merged_CA_viral_check_blast_fna=\"$genomad_opt/$i.CA.checkv.blast.viralContig.fna\"
seqtk subseq $mash_opt/mashani_rep_id95.0.fasta $opt_dir/Viral_nodeid_inCrossAss_blast_only.csv > \$merged_CA_viral_check_blast_fna
seqtk subseq \$checkv_opt_ori $opt_dir/Viral_nodeid_inCrossAss_checkv_vggt1_only.csv >> \$merged_CA_viral_check_blast_fna

## because checkv prophage id have _1 extra suffix, so add it 
## use command to get prophage id 
## less checkV/*/proviruses_virus_all.fna|grep \/|sed 's/>//'|cut -d " " -f 1 >checkv_prophage.id
seqtk subseq \$checkv_opt_ori $opt_dir/checkv_prophage.id >> \$merged_CA_viral_check_blast_fna
## genomad
sh /ictstr01/home/viro/xue.peng/publicData/GPD/genomad/run_genomad.sh $i \$merged_CA_viral_check_blast_fna $genomad_opt/$i


### host taxonomy
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate iphop_env

host_dir=\"$iphop_opt/$i\"
mkdir -p \$host_dir
iphop predict --out_dir \$host_dir --db_dir /home/viro/xue.peng/software_home/iphop/iphop_db/Sept_2021_pub --num_threads 8 --fa_file \$merged_CA_viral_check_blast_fna
conda deactivate


## crispr
cd $crispr_opt
sh /home/viro/xue.peng/workplace_2023/CRC_community_vt/src/run_CrisprOpenDB.sh $mash_opt/mashani_rep_id95.0.fasta $crispr_opt
cd -
## merge all the results for crispr
less CrisprOpenDB_1v1/$i/*CrisprOpenDB_opt.txt|grep '^('|sed 's/(//'|sed 's/)//'|sed 's/'//g'|sed 's/\s\+//g' > ${crispr_opt}.CrisprOpenDB.opt

" >>$script


#######################################################
### remove redancy with GPD (mapping reads selected)
### prepare the GPD contig(only need run once)
### same methods in the checkV 
#######################################################
idFile="$nr_gpd_ca_opt/gpd_meet_creteria.uniqueID.id"
gpdSeqF="$nr_gpd_ca_opt/gpd_meet_creteria.fasta"
if [ ! -s $idFile ]; then
echo "select GPD seq!!"
tail -n +2 /home/viro/xue.peng/workplace_2023/CRC_community_vt/results/virome_abundance/btalign_GPD.coverage.csv /home/viro/xue.peng/workplace_2023/CRC_community_vt/results/vt_mapping/btalign_GPD.coverage.csv|awk -F , '{if ($6 >= 10000 || $7 >= 60) print $0}' >$nr_gpd_ca_opt/gpd_meet_creteria.csv
less $nr_gpd_ca_opt/gpd_meet_creteria.csv |cut -d "," -f 2|sort|uniq >$idFile
seqtk subseq /home/viro/xue.peng/publicData/GPD/GPD_sequences.fa $idFile >$gpdSeqF
fi

done

####################################################################
### remove redundant using fastANI for all the cross assemble contig (CA + GPD)
### because mash take very long time
####################################################################
nr_gpd_ca_all_opt="$nr_gpd_ca_opt/all"
mkdir -p $nr_gpd_ca_all_opt
###please make sure above script is done and the renamed file is exists!!!!!
cat ./cross_assemble_abundance/mash/*/mashani_rep_id95.0.rename.fasta $gpdSeqF >$merged_fasta_all
sh ~/script/module_cluster/checkv_cluster_ctg/cluster_ctg_balstn_ani_modify.sh $merged_fasta_all all_ani $nr_gpd_ca_all_opt 30 98 85
gpd_CA_rep_fasta="$nr_gpd_ca_all_opt/rep.fasta"


###############################################################################################
### build bowtie index for the GPD and CA non_redundant set (98%) to have the relative abundance
################################################################################################
. ~/script/bt2.sh
#btbuild $gpd_CA_rep_fasta $nr_gpd_ca_all_opt/bt2DB/gpd_CA.rep


############################################
###  build blast index for the GPD and CA non_redundant set (98%) to have virome and vt alignment 
###################################################
### build blast db used for blast alignment
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate blast

makeblastdb -in cross_assemble_abundance/nr_gpd_crossAss/all/rep.fasta -dbtype nucl -parse_seqids -out cross_assemble_abundance/nr_gpd_crossAss/all/blastRefDB/nr_gpd_crossAss_rep_id98.0.blastdb 

