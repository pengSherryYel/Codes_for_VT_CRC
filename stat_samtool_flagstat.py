#!/usr/bin/python

import pandas as pd
import os
import sys
import glob

def parse_samtool_flagstat(infile):
    sample_name=infile.split("/")[-2]
    with open(infile) as f:
        content=f.readlines()
        total_number=content[0].split(" ")[0]
        primary_number=content[1].split(" ")[0]
        mapped_reads=content[6].split(" ")[0]
        mapped_reads_rates=content[6].split(" ")[4].strip("(")
        properly_paired_mapped_reads = content[11].split(" ")[0]
        properly_paired_mapped_rates=content[11].split(" ")[5].strip("(")
        
        output=[sample_name,total_number,primary_number,mapped_reads,mapped_reads_rates,properly_paired_mapped_reads,properly_paired_mapped_rates]
        headerL="sample_name,total_number,primary_number,mapped_reads,mapped_reads_rates,\
                properly_paired_mapped_reads,properly_paired_mapped_rate".split(",")
        d = pd.DataFrame([output],columns=headerL)
        return d

def batch_handle(dirpath):
    ## given a path find all the flagstat file and form the results
    flagstat_file=glob.glob("%s/**/*bam.flagstat"%dirpath,recursive=True)
    print(len(flagstat_file),"files is found")

    summaryL = []
    for infile in flagstat_file:
        d = parse_samtool_flagstat(infile)
        d["FILE"]=infile
        summaryL.append(d)

        summaryDF = pd.concat(summaryL)

    print(summaryDF)
    summaryDF.to_csv("flagstat_summary.csv", sep="\t")
        

if __name__ == "__main__":
    d = parse_samtool_flagstat("./results/btalign/BCAVCA_16/BCAVCA_16.bam.flagstat")
    #print(d)
    batch_handle("./results/vt_mapping")
