#!/usr/bin/env bash

py3=`which python3`
wkpath=`realpath $0`
wkdir=`dirname $wkpath`
echo $wddir

if [ -z $py3 ];then
    echo "This program need python3 installed! if not please install before"
    break
else
    python3 -m venv venv
    . ./venv/bin/activate
    . $wkdir/kraken2_classify.sh
    echo "install require package..."
    #pip3 install -r $wkdir/requirements.txt

    
    ##main function part
    ##usage krakenClassContig contig "viral"|"bav" samplename
    optdir=`dirname $3`
    if [ -e $optdir ];then echo "output dir: $optdir"; else mkdir -p $optdir;fi
    optfile=${3}.${2}.k2.output
    krakenClassContig $1 $2 $3 && \
    python3  $wkdir/k2tax.py --krakenopt $optfile && echo "lineage done"  
    
    deactivate 
#    rm -rf venv
fi
