# coding: utf-8
# %load merge_bactera_crispr.py
# %load ../../results/merge_bt_align.py
import pandas as pd
import glob
def merge_crispr_bacteria(dirpath,optfile,sep="\t"):
    resultL=[]
    FL = glob.glob(dirpath)
    print(FL)
    for infile in FL:
        sampleid=infile.split("/")[-2]
        tmpD = pd.read_csv(infile,sep=sep)
        tmpD["Sample"]=[sampleid]*len(tmpD)
        #print(tmpD)
        resultL.append(tmpD)
    d = pd.concat(resultL)
    d.to_csv(optfile,index=False)
    print(d)
    

def pd2fasta(incsv,optseq,sep="\t"):
    d = pd.read_csv(incsv,sep=sep)
    print(d)
    
    resL=[]
    for i in d.index:
        sid=d.loc[i,"Name"]
        sseq=d.loc[i,"Consensus repeat"]
        #print(sid,sseq)
        resL.append(">%s\n"%sid)
        resL.append(sseq+"\n")
    opt=open(optseq,"w")
    opt.writelines(resL)
    opt.close()
        
## merge result and merge the fasta 
infile_regex="/home/viro/xue.peng/workplace_2023/CRC_community_vt/results_16s/uhgg_contig_nonred_Rab/CRISPR/*/Complete_summary.csv"
outmergeF="/home/viro/xue.peng/workplace_2023/CRC_community_vt/results_16s/uhgg_contig_nonred_Rab/CRISPR.bacteria.merged.csv"
merge_crispr_bacteria(infile_regex,outmergeF,",")
outmergeS="/home/viro/xue.peng/workplace_2023/CRC_community_vt/results_16s/uhgg_contig_nonred_Rab/CRISPR.bacteria.merged.fasta"
pd2fasta(outmergeF,outmergeS,",")

