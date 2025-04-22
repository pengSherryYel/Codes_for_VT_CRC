#!/usr/bin/bash

###########################################################################################################################
### this file is generate CrisprOpenDB sbatch file
### because when dataset is large the CrisprOpenDB software might have problem, which can stoped in the middle have no reason
### and the single script take much long time to run
### so this script is for the CrisprOpenDB script
### Workflow: 
###       1. split the input seq into multple seq file (store at $outputDir/$sampleid/split)
###       2. read each of the split file and generate the script (run together or run seperate)
### Example:
###       sh prepare_CrisprOpenDB_script.sh ./mash/healthy/mashani_rep_id95.0.fasta healthy 
#############################################################################################################################


inseq=$1
sampleid=$2
wd=${3:-"."}
mode=${4:-"all"}
seqnumberInEachF=${5:-500}

function ceil(){
  floor=`echo "scale=0;$1/1"|bc -l ` 
  add=`awk -v num1=$floor -v num2=$1 'BEGIN{print(num1<num2)?"1":"0"}'`
  echo `expr $floor  + $add`
}


function split_file_path(){
     path=$1
     path_dir=`dirname $path`
     path_suffix=`echo ${path##*.}`
     path_prefix=`basename $path .$path_suffix`
     echo $path_dir $path_prefix $path_suffix
}

total_seq=`less $1|grep \>|wc -l`
split_seq_number=`echo "scale=1; ($total_seq/$seqnumberInEachF)"|bc`
celi_split_seq_number=`ceil $split_seq_number`
echo "$inseq $total_seq $celi_split_seq_number"

## generate the bash script to predict each of them
if [ $mode == "all" ];then
    script="/home/viro/xue.peng/script/module_crispr/CrisprOpenDB/run_CrisprOpenDB_notsplit.sh"
    outputDir="$wd/CrisprOpenDB_batch"
elif [ $mode == "1v1" ];then
    script="/home/viro/xue.peng/script/module_crispr/CrisprOpenDB/run_CrisprOpenDB.sh"
    outputDir="$wd/CrisprOpenDB_1v1"
else
    echo "mode must be all or 1v1"
    echo "all: run them together; 1v1: resplit the seq again, predict it one by one"
    exit 0
fi


## split to small subset (output/split/dir)
outputDir_split="$outputDir/$sampleid/split"
mkdir -p $outputDir_split
seqtk split -n $celi_split_seq_number $outputDir_split/split $inseq
echo "split seq store in $outputDir_split"


## main program
while read line; do
    echo "$line"
    read inf_dir inf_prefix inf_suffix<<<`split_file_path $line`
    echo "#!/usr/bin/bash" > ./${sampleid}_${inf_prefix}.sbatch.sh
    echo "sh $script $line ./$outputDir/$sampleid" >>./${sampleid}_${inf_prefix}.sbatch.sh
done <<< `ls $outputDir_split/*fa`


