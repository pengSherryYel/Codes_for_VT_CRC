#!/usr/bin/bash

###
### Aim: use cd hit to cluster the ctg or genome seq using psi-cd-hit; [nucletide] seq
###   Reason: cd-hit-est can not cluster long sequence(genome or scaffold)
###   Reqirement: blast should in PATH
### Usage: sh $0 <ingenome> <identity(0.95)> [mode] [outDir] [otherPara] [runPara]
###    eg. sh run_cdhit_ctg_cluster.sh example.contig.200.fasta 0.8 long
###    ingenome: input sequence file (fasta format)
###    identity: default 0.95
###    mode: long|short
###          long --> long seq using psi-cd-hit
###          short --> short seq using cd-hit-est
###    outDir: output dir name(default: ./cdhit_cluster_seq)
###    otherPara: parameter for cd-hit
###          long --> "-G 1 -g 1 -aL 0.7 -aS 0.7 -prog blastn -circle 1"
###          short --> "-n 10 -G 1 -g 1 -aL 0.7 -aS 0.7 -M 0 -T 5"
###                    wd size(-n): 4:0.75-0.8; 5:0.8-0.85; 6:0.85-0.88; 7:0.88-0.9; 8-9:0.9-0.95; 10-11: 0.95-1.0
###    runPara: parameter for psi-cd-hit. default: "-exec local -para 8 -blp 4"
###
###    Important parameter:
###         -G: global identity(total identical letters from all co-linear and non-overlapping HSPs/length of short sequence)#
###         -g: cdhit mode. 0 - fast mode, compare with representative; 1 - accuracy mode, compare all seq
###         -prog: psi-blast program. blastn: remote seq; megablast: more similar program best at 95% identity.
###                (blastp, blastn, megablast, psiblast), default blastp
###         -s: blast search para, default  "-seg yes -evalue 0.000001 -max_target_seqs 100000"
###         -circle: wheather treat input as cricle
###         -n: word_length, default 10, see user's guide for choosing it
###

ingenome=$1
identity=${2:-0.95}
mode=${3:-"long"} ##long| short
outDir=${4:-"./cdhit_cluster_seq"}
otherPara=${5:-""}
runPara=${6:-"-exec local -para 8 -blp 4"}


##----------
## help
##----------
help() {
    sed -rn 's/^### ?//;T;p;' "$0"
}

if [ $# == 0 ];then
    help
    exit 1
fi

##-----------
## main func
##-----------
function get_wd_size(){
    #wd size(-n): 4:0.75-0.8; 5:0.8-0.85; 6:0.85-0.88; 7:0.88-0.9; 8-9:0.9-0.95; 10-11: 0.95-1.0
    query_iden=`echo "scale=0;$1*100/1"|bc`
    if (( $query_iden == 100 ));then
        wd_size=11
    elif (( $query_iden < 100 )) && (( $query_iden >= 95 ));then
        wd_size=10
    elif (( $query_iden < 95 )) && (( $query_iden > 90 ));then
        wd_size=9
    elif (( $query_iden == 90 ));then
         wd_size=8
    elif (( $query_iden < 90 )) && (( $query_iden >= 88 ));then
        wd_size=7
    elif (( $query_iden < 88 )) && (( $query_iden >= 85 ));then
        wd_size=6
    elif (( $query_iden < 85 )) && (( $query_iden >= 80 ));then
        wd_size=5
    elif (( $query_iden < 80 )) && (( $query_iden >= 75 ));then
        wd_size=4
    else
        wd_size=0
    fi
    echo $wd_size
}

real_path=`realpath $0`
current_path=`dirname $real_path`
source $current_path/utility.sh
cd_hit_sft_dir="/home/viro/xue.peng/software_home/cdhit/cd-hit-v4.8.1-2019-0228"

read -r dirpath prefix suffix <<< `split_file_path $ingenome`
cd_hit_opt="$outDir/${prefix}_${mode}_idt${identity}.rep.$suffix"
mkdirs $outDir 0
tmp="cdhit_tmp/${prefix}"
mkdirs $tmp 0 && cp $ingenome $tmp

if [ $mode == "long" ];then
    cd_hit="$cd_hit_sft_dir/psi-cd-hit/psi-cd-hit.pl"

    ## set default parameter
    if [ -z "$otherPara" ];then
        otherPara="-G 1 -g 1 -aL 0.7 -aS 0.7 -prog blastn -circle 1"
    fi

    cmd="$cd_hit -i $tmp/${prefix}.${suffix} -o $cd_hit_opt -c $identity $otherPara $runPara"
    echo "Run Command: $cmd"
    $cmd && echo "psi-cd-hit DONE!!" && rm -rf $tmp

elif [ $mode == "short" ];then
    cd_hit="$cd_hit_sft_dir/cd-hit-est"
    if [ -z "$otherPara" ];then
        otherPara="-G 1 -g 1 -aL 0.7 -aS 0.7 -M 0 -T 5 "
    fi
    wd_size=`get_wd_size $identity`
    cmd="$cd_hit -i $tmp/${prefix}.${suffix} -o $cd_hit_opt -c $identity -n $wd_size $otherPara"
    echo "Run Command: $cmd"
    $cmd && echo "cd-hit-est DONE!!"

else
    echo "mode must be long | short"

fi
