#!/usr/bin/bash

infile=$1

sample=`echo $infile|cut -d / -f 3`
bin_num=`basename $infile|sed 's/.fa//'`

assemble_number=`less $infile|grep ^\>NODE|wc -l`
uhgg_number=`less $infile|grep ^\>MGYG|wc -l`
total=`less $infile|grep \>|wc -l`

echo $sample $bin_num $assemble_number $uhgg_number $total

