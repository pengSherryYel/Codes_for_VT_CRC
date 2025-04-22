#!/usr/bin/bash

infile=$1

echo $1
less $infile|awk '{if($6 >=60 && $7 >=1000) print }'|wc -l
