#!/usr/bin/bash

################################
## vt analysis main propgram
################################


##input
name=$1
fq1=$2
fq2=$3
filter_length=${4:-1000} ## this is used for filter scaffolds length above this

##fastpOutput
qcDir="qc/$name"
fastpfq1="$qcDir/$name.1.fastq.gz"
fastpfq2="$qcDir/$name.2.fastq.gz"

##spadesOutput
assembleDir="assemble_spades/$name"
scaffolds="$assembleDir/scaffolds.fasta"
scaffolds_limit_length="$assembleDir/scaffolds.gt${filter_length}.fasta"


##software
fastp="/home/viro/xue.peng/software_home/fastp/fastp"
spades="/home/viro/xue.peng/software_home/SPAdes-3.15.2-Linux/bin/spades.py"

## function
echo $name
function mkdirs(){
    dir_name=$1
    clean=${2:-1}
    if [[ -e $dir_name && $clean == 1 ]];then
        rm -rf $dir_name  && mkdir -p $dir_name
    elif [[ -e $dir_name && $clean == 0 ]];then
        echo "dir exist and not clean!!"
    else
        mkdir -p $dir_name
    fi
}

###qc
mkdir -p $qcDir
$fastp -i $fq1 -I $fq2 -o $fastpfq1 -O $fastpfq2 -q 20 -h $qcDir/$name.fastp.html -j $qcDir/$name.fastp.json -z 4 -n 10 -l 60 -5 -3 -W 4 -M 20 -c -g -x

###assemble
mkdirs $assembleDir
$spades --meta -1 $fastpfq1 -2 $fastpfq2 -o $assembleDir -t 20
#

### filter length
seqkit seq -m $filter_length $scaffolds >$scaffolds_limit_length

### checkv
checkv_opt_ori="./checkv/$name/proviruses_virus_all.fna"
checkv_opt="./checkv/$name/proviruses_virus_all.level_2.fna"
sh /home/viro/xue.peng/script/run_checkv.sh $name $scaffolds_limit_length "checkv"

## virsorter1
vs_inputseq="$checkv_opt_ori"
vs_optdir="vs1"
vs_selectdb="123"
virsorter_db="/home/viro/xue.peng/software_home/VirSorter1/VirSorter/virsorter-data"

function run_vs1(){
    local vs_inputseq=$1
    local name=$2
    local select_cat=${3:-"1245"}
    local vs_optdir=${4:-"vs1"}
    local vs_db=${5:-2}
    local otherPara=${6:-"--ncpu 20"}
    local virsorter_db="/home/viro/xue.peng/software_home/VirSorter1/VirSorter/virsorter-data"

    . /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
    conda activate virsorter_1
    mkdir -p $vs_optdir
    optdir=`realpath $vs_optdir`

    echo "Run command: wrapper_phage_contigs_sorter_iPlant.pl -f $vs_inputseq --db $vs_db --data-dir $virsorter_db --wdir $vs_optdir/$name_db${vs_db} $otherPara"
    wrapper_phage_contigs_sorter_iPlant.pl -f $vs_inputseq --db $vs_db --data-dir $virsorter_db --wdir $vs_optdir/${name}_db${vs_db} $otherPara
    conda deactivate

    ## select catigory seq
    vs_opt_fna_dir="$vs_optdir/${name}_db${vs_db}/Predicted_viral_sequences"
    cat $vs_opt_fna_dir/VIRSorter_*cat*[$select_cat].fasta >$vs_optdir/${name}_db${vs_db}/merged_sequence_cat${select_cat}.fna
}
run_vs1 $vs_inputseq $name $vs_selectdb $vs_optdir 2
run_vs1 $vs_inputseq $name $vs_selectdb $vs_optdir 1

### merge vs results
ls $vs_optdir/${name}_db*/Predicted_viral_sequences//VIRSorter_*cat*[$vs_selectdb].fasta
merge_dir="$vs_optdir/${name}_merge"
if [ -z $merge_dir ];then mkdir -p $merge_dir;fi
cat $vs_optdir/${name}_db*/Predicted_viral_sequences//VIRSorter_*cat*[$vs_selectdb].fasta|seqkit rmdup -o $merge_dir/all.tmp.fasta
cat $vs_optdir/${name}_db*/Predicted_viral_sequences//VIRSorter_*cat*[$vs_selectdb].fasta |grep \> |sort|uniq|sed 's/>//' > $merge_dir/header
seqtk subseq $merge_dir/all.tmp.fasta $merge_dir/header >$merge_dir/vs1_db12_merged.viral.fasta && rm -rf $merge_dir/all.tmp.fasta


### Taxonomy use kraken and genomad to identify the viral contig
### kranken classified the tax
sh ../src/k2tax_bin/k2tax.main.sh $merge_dir/vs1_db12_merged.viral.fasta viral kraken_contig/$name

### genomad tax; because mmseqs can not assign taxonomy
genomad_dir="./genomad"
sh ../src/run_genomad.sh $name $merge_dir/vs1_db12_merged.viral.fasta $genomad_dir/$name


### HOST identification
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate iphop_env

host_dir="./host_iphop/$name"
mkdir -p $host_dir
iphop predict --out_dir $host_dir --db_dir /home/viro/xue.peng/software_home/iphop/iphop_db/Sept_2021_pub --num_threads 8 --fa_file $merge_dir/vs1_db12_merged.viral.fasta
conda deactivate


####################################
## VT map to non_reduncant virome to find relationship between VT and virome
#####################################
##### vt to virome 
#####################################
### bt alignment (virome non redundant fasta as ref, see wf_virome_extra.sh script how to have the virome)
. /home/viro/xue.peng/script/bt2.sh
##btbuild virome_abundance/mashani_rep_id95.0.fasta virome_abundance/bt2Index/virome_viral
btalign virome_abundance/bt2Index/virome_viral $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "vt_mapping/btalign_virome"
samtoolsStat ./vt_mapping/btalign_virome/$name/$name.bam

## coverm
coverm_opt="vt_mapping/btalign_virome/coverm/$name"
mkdir -p $coverm_opt
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate coverm
coverm contig --bam-files ./vt_mapping/btalign_virome/$name/$name.sort.bam -m tpm covered_bases length --output-file $coverm_opt/${name}.tpm.txt -t 3

####################################
### vt to GPD
####################################
### bt alignment (vt align to GPD; because the virome have very low mapping rate)
. /home/viro/xue.peng/script/bt2.sh
btalign /home/viro/xue.peng/publicData/GPD/GPD_sequences_btindex/GPD_sequences_bt2 $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "vt_mapping/btalign_GPD"
samtoolsStat ./vt_mapping/btalign_GPD/$name/$name.bam

## coverm
coverm_opt="vt_mapping/btalign_GPD/coverm/$name"
mkdir -p $coverm_opt
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate coverm
coverm contig --bam-files ./vt_mapping/btalign_GPD/$name/$name.sort.bam -m tpm covered_bases length --output-file $coverm_opt/${name}.tpm.txt -t 3


####################################
### vt to bacteria (uhgg+contig)
####################################
### bt alignment (bacteria non redundant fasta as ref, see wf_bacteria_nonreduncant_realtiveAb.sh script how to have the non_redunant bacteria)
. /home/viro/xue.peng/script/bt2.sh
btalign /home/viro/xue.peng/workplace_2023/CRC_community_vt/results_16s/uhgg_contig_nonred_Rab/bt2Index/allSample_bacteria_uhgg $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "vt_mapping/btalign_bacteria"
samtoolsStat ./vt_mapping/btalign_bacteria/$name/$name.bam

## coverm
coverm_opt="vt_mapping/btalign_bacteria/coverm/$name"
mkdir -p $coverm_opt
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate coverm
coverm contig --bam-files ./vt_mapping/btalign_bacteria/$name/$name.sort.bam -m tpm covered_bases length --output-file $coverm_opt/${name}.tpm.txt -t 3

###################################
## vt to bacteria prophage (uhgg+contig)
###################################
## bt alignment (bacteria non redundant fasta as ref, see wf_bacteria_nonreduncant_realtiveAb.sh script how to have the non_redunant bacteria)
. /home/viro/xue.peng/script/bt2.sh
btalign /home/viro/xue.peng/workplace_2023/CRC_community_vt/results_16s/uhgg_contig_prophage_nonred_Rab/bt2Index/allSample_bacteria_uhgg_prophage $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "vt_mapping/btalign_prophage"
samtoolsStat ./vt_mapping/btalign_prophage/$name/$name.bam

## coverm
coverm_opt="vt_mapping/btalign_prophage/coverm/$name"
mkdir -p $coverm_opt
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate coverm
coverm contig --bam-files ./vt_mapping/btalign_prophage/$name/$name.sort.bam -m tpm covered_bases length --output-file $coverm_opt/${name}.tpm.txt -t 3


###################################
## vt to vt own 
###################################
### bt alignment (vt non redundant fasta as ref, see wf_vt_extra.sh script how to have the non_redunant viral vt)
. /home/viro/xue.peng/script/bt2.sh
#btbuild ./vt_abundance/mashani_rep_id95.0.fasta ./vt_abundance/bt2Index/mashani_rep_id95.0
btalign /home/viro/xue.peng/workplace_2023/CRC_community_vt/results/vt_abundance/bt2Index/mashani_rep_id95.0 $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "vt_abundance/btalign_vt_own"
samtoolsStat ./vt_abundance/btalign_vt_own/$name/$name.bam

### coverm
coverm_opt="./vt_abundance/btalign_vt_own/coverm/$name"
mkdir -p $coverm_opt
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate coverm
coverm contig --bam-files ./vt_abundance/btalign_vt_own/$name/$name.sort.bam -m tpm covered_bases length --output-file $coverm_opt/${name}.tpm.txt -t 3

#######################################################
## vt to cross_assemble (GPD + CA) rep (98%identity ANI)
########################################################
##please see how to build the non-redundant cross assemble db see script wf_cross_assemble.extra.sh
. /home/viro/xue.peng/script/bt2.sh
btalign cross_assemble_abundance/nr_gpd_crossAss/all/bt2DB/gpd_CA.rep $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "./cross_assemble_abundance/btalign_crossAssemble"
samtoolsStat ./cross_assemble_abundance/btalign_crossAssemble/$name/$name.bam


########################
## vt scaffold map to cross assemble non-reduncant contig
########################

query_contig="$merge_dir/vs1_db12_merged.viral.fasta"
outdir="vt2crossassemble_blast"
treads=30

. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate blast 

mkdir -p $outdir
cwd=`pwd`

blastn -query $query_contig -db ./cross_assemble_abundance/mash/CRC_advance/blastRefDB/CRC_advance.mashani_rep_id95.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 10 -num_threads $treads -out $outdir/$name.CRC_advance.blastn.opt.tsv

blastn -query $query_contig -db ./cross_assemble_abundance/mash/CRC_early/blastRefDB/CRC_early.mashani_rep_id95.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 10 -num_threads $treads -out $outdir/$name.CRC_early.blastn.opt.tsv

blastn -query $query_contig -db ./cross_assemble_abundance/mash/healthy/blastRefDB/healthy.mashani_rep_id95.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 10 -num_threads $treads -out $outdir/$name.healthy.blastn.opt.tsv

blastn -query $query_contig -db ./cross_assemble_abundance/mash/UC/blastRefDB/UC.mashani_rep_id95.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 10 -num_threads $treads -out $outdir/$name.UC.blastn.opt.tsv

query_contig="$assembleDir/scaffolds.fasta"
blastn -query $query_contig -db ./cross_assemble_abundance/nr_gpd_crossAss/all/blastRefDB/nr_gpd_crossAss_rep_id98.0.blastdb -outfmt '6 std qlen slen qcovs qcovhsp staxids' -max_target_seqs 10 -num_threads $treads -out $outdir/$name.nr_gpd_CA.blastn.opt.tsv


