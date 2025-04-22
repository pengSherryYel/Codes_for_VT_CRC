#!/usr/bin/bash

#################################
## the software can batch run, but sometimes it will interrapt in the middle
## need to rerun again 
## so use separate contig to aviod error in the middle
################################

infile=$1
outputDir=${2:-"."}

if [ -e $outputDir ];then mkdir -p $outputDir;fi
infile_real=`realpath $infile`
outputDir_real=`realpath $outputDir`


function split_file_path(){
     path=$1
     path_dir=`dirname $path`
     path_suffix=`echo ${path##*.}`
     path_prefix=`basename $path .$path_suffix`
     echo $path_dir $path_prefix $path_suffix
}

. /home/viro/xue.peng/software_home/miniconda3/etc/profile.d/conda.sh
conda activate CrisprOpenDB_env

script="/home/viro/xue.peng/software_home/CrisprOpenDB/CrisprOpenDB/CL_Interface.py"
blast_db="/home/viro/xue.peng/software_home/CrisprOpenDB/CrisprOpenDB/CrisprOpenDB/SpacersDB/SpacersDB"
fasta_db="/home/viro/xue.peng/software_home/CrisprOpenDB/CrisprOpenDB/CrisprOpenDB/SpacersDB/SpacersDB.fasta"
detail_opt=`realpath $outputDir_real/CrisprOpenDB_opt.txt`
final_opt="$outputDir_real/CrisprOpenDB_opt_final.txt"


## program must run the dir, otherwise it will not work
read inf_dir inf_prefix inf_suffix<<<`split_file_path $infile_real`
echo $inf_dir $inf_prefix

##split fasta into each contig
sh ~/script/utility_python/fasta2list.sh $infile ${inf_prefix}.split.txt ${inf_prefix}_split_dir
while read line;do 
    read seqid seqpath <<< `echo $line|sed 's/\t/ /g'`
    echo $seqid
    echo $seqpath
    optlog="$outputDir_real/$seqid.CrisprOpenDB_opt.txt"
    if [ -s $optlog ];then
        echo "$seqid output exist!! pass !!"
    else
        cd /home/viro/xue.peng/software_home/CrisprOpenDB/CrisprOpenDB/
        python $script -i $seqpath -t -r -n 30 -b $blast_db > $optlog
        mv $seqid.csv $outputDir_real/
        cd -
    fi
done <<< `less ${inf_prefix}.split.txt`

less *CrisprOpenDB_opt.txt|grep '^('|sed 's/(//'|sed 's/)//' >$final_opt

