# coding: utf-8
import pandas as pd
import re

def load_metadata(infile):
    d = pd.read_csv(infile,sep=",",index_col=0,names=["Status"]).to_dict()
    return d
metadataD = load_metadata("./data/metadata_dieasse.info")["Status"]

'''
## stat number of contig and data volume
contig_number_list=!seqkit stats */assemble_spades/*/*gt1000*
contig_number_process=[re.split("\s+",i) for i in contig_number_list if i!=" "]
contig_number_df = pd.DataFrame(contig_number_process[1:],columns=contig_number_process[0])
contig_number_df["sample_name"]=[i.split("/")[-2] for i in contig_number_df.file]
contig_number_df["Status"]=[metadataD.get(i,i) for i in contig_number_df.sample_name]
contig_number_df["Source"]=["Virome" if i.endswith("v") else "Metagenomic" if i.endswith("b") else "VT" for i in contig_number_df.sample_name]
contig_number_df.to_csv("./summary/contig_length_info.summary",sep="\t")
contig_number_df
'''
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
        headerL="sample_name,total_number,primary_number,mapped_reads,mapped_reads_rates,properly_paired_mapped_reads,properly_paired_mapped_rate".split(",")
        d = pd.DataFrame([output],columns=headerL)
        return d
parse_samtool_flagstat("./results/btalign/BCAVCA_16/BCAVCA_16.bam.flagstat")    
