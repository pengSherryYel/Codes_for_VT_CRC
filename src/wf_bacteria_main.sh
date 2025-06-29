#!/usr/bin/bash
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

## remove phiX
. /home/viro/xue.peng/script/bt2.sh
phix_wd="btalign_phix"
phix_dirname="phiX_$name"
phix_opt="${phix_wd}/${phix_dirname}/${phix_dirname}.bam"
phix_unmapped_reads_index="${phix_wd}/${phix_dirname}/${phix_dirname}.unmapped.id"
rx_fq1="${phix_wd}/${phix_dirname}/${phix_dirname}.1.fq.gz"
rx_fq2="${phix_wd}/${phix_dirname}/${phix_dirname}.2.fq.gz"

mkdirs ${phix_wd}/${phix_dirname} 1
btalign /home/viro/xue.peng/software_home/FastQ_Screen/FastQ-Screen-0.15.2/FastQ_Screen_Genomes/PhiX/phi_plus_SNPs $fq1 $fq2 $phix_dirname "--sensitive-local -q -p 10" $phix_wd
samtools view -f 12 $phix_opt |cut -f 1|sort |uniq > $phix_unmapped_reads_index
seqtk subseq $fq1 $phix_unmapped_reads_index|gzip > $rx_fq1
seqtk subseq $fq2 $phix_unmapped_reads_index|gzip > $rx_fq2

## remove human
human_wd="btalign_human"
human_dirname="human_$name"
human_opt="${human_wd}/${human_dirname}/${human_dirname}.bam"
human_unmapped_reads_index="${human_wd}/${human_dirname}/${human_dirname}.unmapped.id"
rxh_fq1="${human_wd}/${human_dirname}/${human_dirname}.1.fq.gz"
rxh_fq2="${human_wd}/${human_dirname}/${human_dirname}.2.fq.gz"

mkdirs ${human_wd}/${human_dirname} 1
btalign /home/viro/xue.peng/software_home/FastQ_Screen/FastQ-Screen-0.15.2/FastQ_Screen_Genomes/Human/Homo_sapiens.GRCh38  $rx_fq1 $rx_fq2 $human_dirname "--sensitive-local -q -p 10" $human_wd
samtools view -f 12 $human_opt |cut -f 1|sort |uniq > $human_unmapped_reads_index
seqtk subseq $rx_fq1 $human_unmapped_reads_index|gzip > $rxh_fq1
seqtk subseq $rx_fq2 $human_unmapped_reads_index|gzip > $rxh_fq2


###qc
mkdir -p $qcDir
$fastp -i $rxh_fq1 -I $rxh_fq2 -o $fastpfq1 -O $fastpfq2 -q 20 -h $qcDir/$name.fastp.html -j $qcDir/$name.fastp.json -z 4 -n 10 -l 60 -5 -3 -W 4 -M 20 -c -g -x

###assemble
mkdirs $assembleDir
$spades --meta -1 $fastpfq1 -2 $fastpfq2 -o $assembleDir -t 20 -m 400


### filter length
seqkit seq -m $filter_length $scaffolds >$scaffolds_limit_length


## bt alignment to scaffold (assemble quality check)
. /home/viro/xue.peng/script/bt2.sh
btbuild $scaffolds_limit_length bt2Index/$name "--threads 20"
btalign bt2Index/$name $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20"
samtoolsStat ./btalign/$name/$name.bam

### bt alignment to uhgg 
. /home/viro/xue.peng/script/bt2.sh
btalign /home/viro/xue.peng/publicData/uhgg/v2.0.1/species_catalogue_merged_btIndex/species_catalogue_merged_btIndex $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "btalign_uhgg"
samtoolsStat ./btalign_uhgg/$name/$name.bam


## Taxonomy use kraken and mmseqs to identify the bacteria contig
### kranken classified the tax
sh ../src/k2tax_bin/k2tax.main.sh $scaffolds_limit_length bav kraken_contig/$name

### mmseqs tax
mmseqs_tmp="mmseqs_tmp_$name"
mkdir -p mmseqs/$name
if [ -e $mmseqs_tmp ]; then rm -rf $mmseqs_tmp; fi
### this is for define the bacteria taxonomy
mmseqs easy-taxonomy $scaffolds_limit_length /home/viro/xue.peng/software_home/mmseqs_db/swissprot_db/swissprot mmseqs/$name $mmseqs_tmp


### Relative abundance on non-redundant bateria genome (see how to create the no redunant dataset wf_bacteria_nonreduncant_realtiveAb.sh)
. /home/viro/xue.peng/script/bt2.sh
btalign ./uhgg_contig_nonred_Rab/bt2Index/allSample_bacteria_uhgg $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "uhgg_contig_nonred_Rab/btalign_b2b"
samtoolsStat ./uhgg_contig_nonred_Rab/btalign_b2b/$name/$name.bam

## coverm
coverm_opt="./uhgg_contig_nonred_Rab/btalign_b2b/coverm/$name"
mkdir -p $coverm_opt
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate coverm
coverm contig --bam-files ./uhgg_contig_nonred_Rab/btalign_b2b/$name/$name.sort.bam -m tpm covered_bases length --output-file $coverm_opt/${name}.tpm.txt -t 3


### Relative abundance on non-redundant prophage genome (see how to create the no redunant dataset wf_prophage_nonreduncant_realtiveAb.sh)
. /home/viro/xue.peng/script/bt2.sh
btalign uhgg_contig_prophage_nonred_Rab/bt2Index/allSample_bacteria_uhgg_prophage $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 20" "uhgg_contig_prophage_nonred_Rab/btalign_b2prophage"
samtoolsStat ./uhgg_contig_prophage_nonred_Rab/btalign_b2prophage/$name/$name.bam

## coverm
coverm_opt="./uhgg_contig_prophage_nonred_Rab/btalign_b2prophage/coverm/$name"
mkdir -p $coverm_opt
. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate coverm
coverm contig --bam-files ./uhgg_contig_prophage_nonred_Rab/btalign_b2prophage/$name/$name.sort.bam -m tpm covered_bases length --output-file $coverm_opt/${name}.tpm.txt -t 3


