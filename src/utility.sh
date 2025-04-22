#!/usr/bin/bash


function split_file_path(){
     path=$1
     path_dir=`dirname $path`
     path_suffix=`echo ${path##*.}`
     path_prefix=`basename $path .$path_suffix`
     echo $path_dir $path_prefix $path_suffix
}

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

