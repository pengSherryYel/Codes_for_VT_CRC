#!/usr/bin/bash

###############################
## vt and virome cross assemble
###############################
optDir="./cross_assemble"
currentDir=`pwd`

mkdir $optDir
variable=(
  "healthy"
  "UC"
  "CRC_early"
  "CRC_advance"
)

for i in "${variable[@]}"; do
    echo $i
    
    ## get id and cat the virome into the output file
    viromes=`less /home/viro/xue.peng/workplace_2023/CRC_community_vt/data/metadata_dieasse.info|grep "_v"|grep $i|cut -d , -f 1`
    echo $viromes
    
    ## find VT with same Virome
    case $i in
       "healthy")
           vt=`ls ./qc|grep VH`;;

       "UC")
           vt=`ls ./qc|grep VCO`;;

       "CRC_early")
           vt=`ls ./qc|grep VCE`;;
       
       "CRC_advance")
           vt=`ls ./qc|grep VCA`;;
    esac
    echo $vt|sed 's/ /\n/g'

    for viromeid in $viromes;do
        
       for vtid in $vt;do   

       ########################
       ## prepare the output file
       diease_based_opt_1="$optDir/merged.$i.$viromeid.$vtid.1.fastq"
       diease_based_opt_2="$optDir/merged.$i.$viromeid.$vtid.2.fastq"
       #if [ -e $diease_based_opt_1 ];then rm -rf $diease_based_opt_1 $diease_based_opt_2;fi

       ## prepare the assemble file
       assemble_file="$optDir/sbatch.$i.$viromeid.$vtid.cross_assemble.sh"
       echo '#!/usr/bin/bash' >$assemble_file
       echo "/home/viro/xue.peng/software_home/SPAdes-3.15.2-Linux/bin/spades.py --meta -1 $currentDir/$diease_based_opt_1 -2 $currentDir/$diease_based_opt_2 -o $currentDir/$optDir/assemble_spades/${i}_${viromeid}_{$vtid} -t 30 -m 400" >> $assemble_file
       ########################

       virome_1=`ls ./qc/$viromeid/*1.fastq.gz`
       virome_2=`ls ./qc/$viromeid/*2.fastq.gz`
       echo $virome_1
       
       #zcat $virome_1 >> $diease_based_opt_1
       #zcat $virome_2 >> $diease_based_opt_2
 
       vt_1=`ls ./qc/$vtid/*1.fastq.gz` 
       vt_2=`ls ./qc/$vtid/*2.fastq.gz`
       #zcat $vt_1 >>$diease_based_opt_1
       #zcat $vt_2 >>$diease_based_opt_2
       echo $vt_1
    
       done
   done
done

