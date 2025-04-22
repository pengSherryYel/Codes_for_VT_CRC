mash="/home/viro/xue.peng/software_home/mash/mash-Linux64-v2.3/mash"

#$mash sketch -s 1e4 
echo "have function as follow:" \
     "statScreenTable" \
     "runSketchList" \
     "runSketchMulfa" \
     "runMashScreenPE" \
     "runMashScreen"



statScreenTable(){
    screentable=$1
    name=`echo $screentable|sed 's/\.table//g'`
    total=`less $screentable|awk '{if($1>=0) print}'|wc -l`
    total95=`less $screentable|awk '{if($1>=0.95) print}'|wc -l`
    total90=`less $screentable|awk '{if($1>=0.9) print}'|wc -l`
    total80=`less $screentable|awk '{if($1>=0.8) print}'|wc -l`
    total70=`less $screentable|awk '{if($1>=0.7) print}'|wc -l`
printf "identy\t%s
>0.95\t%s
>0.9\t%s
>0.8\t%s
>0.7\t%s
>0.0\t%s\n" $name $total95 $total90 $total80 $total70 $total
}

runSketchList(){
    inputList=$1
    kmer=${2:-21}
    sketchsize=${3:-10000}
    otherParameter=${4:-"-p 1"}
    if [ -z $inputList ];then
        echo "please input sequnce path list for -l parameter!"
        echo "Usage:runSketchList <seqlist> [kmer(default:21)] [sketchsize(default:1e4)] [otherParameter]"
    else
        echo "sketch begin"
        echo "run command '$mash sketch -l $inputList -o $inputList.k${kmer}.s${sketchsize} -k $kmer -s $sketchsize $otherParameter'"
        $mash sketch -l $inputList -o $inputList.k${kmer}.s${sketchsize} -k $kmer -s $sketchsize $otherParameter && echo "sketch done!"
    fi

}


runSketchMulfa(){
    inputfa=$1
    kmer=${2:-21}
    sketchsize=${3:-10000}
    otherParameter=${4:-"-p 1"}
    if [ -z $inputfa ];then
        echo "please input sequnce file!"
        echo "Usage:runSketchMulfa <seqfa> [kmer(default:21)] [sketchsize(default:1e4)] [otherParameter]"
    else
        echo "sketch begin"
        echo "run command '$mash sketch -i $inputfa -o $inputfa.k${kmer}.s${sketchsize} -k $kmer -s $sketchsize $otherParameter'"
        $mash sketch -i $inputfa -o $inputfa.k${kmer}.s${sketchsize} -k $kmer -s $sketchsize $otherParameter && echo "sketch done!"
    fi

}

runMashScreen(){
    querySketch=${1}
    refSketch=${2}
    optFile=$3
    otherParameter=${4:-"-p 3"}    
    $mash dist $otherParameter $querySketch $refSketch >$optFile
    python ~/script/runmashstat.py $optFile
}


runMashScreenPE(){
    sketchFile=${1}
    read1=${2}
    read2=${3}
    sampleName=${4:-"nosamplename"}
    otherParameter=${5:-"-p 3"}  
    
    readinOne="./$sampleName.tmp"

    if [ -z $sketchFile -o -z $read1 ];then
        echo "please input sketch file(query.msh) and read file!"
        echo "Usage: runMashS <query.msh> <read1> [read2] [sampleName] [otherParameter]"
        return 0
    fi

    if [[ -n $read1 && -n $read2 ]];then
        echo "cat the PE read……"
        fileStatus=`file $read1|grep gzip`
        if [ -z "fileStatus" ];then
            echo "run command 'cat $read1 $read2 > $readinOne'"
            cat $read1 $read2 > $readinOne
        else
            echo "run command 'zcat $read1 $read2 > $readinOne'"
            zcat $read1 $read2 > $readinOne
        fi
    elif [[ -n $read1 && -z $read2 ]];then
        echo "all seq in one file……"
        fileStatus=`file $read1|grep gzip`
        if [ -z "fileStatus" ];then
            echo "run command 'cat $read1 > $readinOne'"
            cat $read1 > $readinOne
        else
            echo "run command 'zcat $read1 > $readinOne'"
            zcat $read1 > $readinOne
        fi
    else
        echo "Usage: runMashS <query.msh> <read1> [read2] [sampleName] [otherParameter]"
    fi

    echo "screen begin"
    echo "run command '$mash screen -w $otherParameter $sketchFile $readinOne > $sampleName.mashScreen.table '"
    $mash screen -w $otherParameter $sketchFile $readinOne > $sampleName.mashScreen.table && echo "$sampleName mashScreen done"
    rm -rf $readinOne
}


