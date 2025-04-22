# coding: utf-8
import pandas as pd
import re
import glob

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


def merge_coverm(coverm_dir, regrex_pattern="*tpm.txt"):
    coverm_fileL=glob.glob("%s/**/%s"%(coverm_dir, regrex_pattern),recursive=True)  
    print(coverm_fileL)
    
    ###parse the coverm
    abundanceDf=pd.DataFrame([])
    for coverm in coverm_fileL:
        sample_name=coverm.split("/")[-2]
        d = pd.read_csv(coverm,sep="\t")
        d.columns=["Contig","%s_TPM"%sample_name, "%s_CoveredBases"%sample_name, "%s_length"%sample_name]
        if abundanceDf.empty:
            abundanceDf = d
        else:
            abundanceDf = abundanceDf.merge(d,on="Contig",how="outer")
        print("pay attention to the shape:",abundanceDf.shape)
    print(abundanceDf)    
    return abundanceDf
    
def load_genomad_tax(genomad_dir, regrex_pattern="*viral_annotate/*taxonomy.tsv"):
    genomad_fileL=glob.glob("%s/**/%s"%(genomad_dir, regrex_pattern), recursive=True)
    print(genomad_fileL)
    
    ###parse the genomad  
    taxL=[]
    for genomad in genomad_fileL:
        sample_name=genomad.split("/")[-3]
        d = pd.read_csv(genomad,sep="\t")
        d.columns=["Contig" if i== "seq_name" else "genomad_%s"%i for i in d.columns]
        d["Source"]=[sample_name if "NODE" in i else "UHGG" for i in d.Contig]
        #print(d)
        taxL.append(d)
        
    taxDf = pd.concat(taxL)
    print("\nduplicate")
    print(taxDf[taxDf.duplicated()]["Source"].value_counts())
    
    taxDf = taxDf.drop_duplicates()
    print(taxDf)
    return taxDf
    
def load_kraken_tax(kraken_dir,regrex_pattern="*taxlineage"):
    tax_fileL=glob.glob("%s/**/%s"%(kraken_dir, regrex_pattern), recursive=True)
    print(tax_fileL)
    
    ###parse the kraken
    taxL=[]
    for kraken in tax_fileL:
        sample_name=kraken.split("/")[-1].split(".")[0]
        kd = pd.read_csv(kraken,sep="\t")
        d = kd[kd["status"]=="C"].loc[:,["seqid","taxid","lineage"]]
        d.columns=["Contig" if i== "seqid" else "kraken_%s"%i for i in d.columns]
        d["Source"]=[sample_name if "NODE" in i else "UHGG" for i in d.Contig]
        taxL.append(d)
          
    taxDf = pd.concat(taxL)
    print("\nduplicate")
    print(taxDf[taxDf.duplicated()]["Source"].value_counts())
    
    taxDf = taxDf.drop_duplicates()
    print(taxDf)
    return taxDf     

def load_mmseqs_tax(mmseqs_dir,regrex_pattern="*lca.addlineage.tsv"):
    tax_fileL=glob.glob("%s/**/%s"%(mmseqs_dir, regrex_pattern), recursive=True)
    print(tax_fileL)
    
    ## parse mmseqs
    taxL=[]
    for mmseqs in tax_fileL:
        sample_name=mmseqs.split("/")[-1].strip("_lca.addlineage.tsv")
        d = pd.read_csv(mmseqs,sep="\t",names=["Contig","mmseqs_taxid","mmseqs_lineage"],usecols=[0,1,2])
        d["Source"]=[sample_name if "NODE" in i else "UHGG" for i in d.Contig]
        #print(d)
        taxL.append(d)
        
    taxDf = pd.concat(taxL)
    print("\nduplicate")
    print(taxDf[taxDf.duplicated()]["Source"].value_counts())
    
    taxDf = taxDf.drop_duplicates()
    print(taxDf)
    return taxDf

def load_iphop(iphop_dir,regrex_pattern="Host_prediction_to_genome_m90.csv"):
    host_fileL=glob.glob("%s/**/%s"%(iphop_dir, regrex_pattern), recursive=True)
    print(host_fileL)
    
    ## parse host
    hostL=[]
    for iphop in host_fileL:
        sample_name=iphop.split("/")[-2]
        d = pd.read_csv(iphop,sep=",",usecols=["Virus","Host taxonomy"])
        d.columns=["Contig" if i== "Virus" else "iphop_%s"%i.replace(" ","_") for i in d.columns]
        d["Source"]=[sample_name if "NODE" in i else "UHGG" for i in d.Contig]
        #print(d)
        hostL.append(d)
    
    hostDf = pd.concat(hostL)
    print("\nduplicate")
    print(hostDf[hostDf.duplicated()]["Source"].value_counts())
    
    hostDf = hostDf.drop_duplicates()
    print(hostDf)
    return hostDf
    
'''
##Bacteria    
abundanceDf = merge_coverm("./results_16s/uhgg_contig_nonred_Rab/btalign_b2b/coverm/")  
kraken_tax_df=load_kraken_tax("./results_16s/kraken_contig/")
mmseqs_tax_df=load_mmseqs_tax("./results_16s/mmseqs/")

t = abundanceDf.merge(mmseqs_tax_df,on="Contig",how="left").merge(kraken_tax_df,on="Contig",how="left")
t.to_csv("summary/metagenomic_contig_taxonomy_abbundance.txt",sep="\t")
print(t)


##Virome 
abundanceDf = merge_coverm("results/virome_abundance/coverm/")
abundanceDf.columns=["Contig_ori" if i== "Contig" else i for i in abundanceDf.columns]
abundanceDf["Contig"]=[i.split("_",2)[-1] for i in abundanceDf.Contig_ori]

kraken_tax_df=load_kraken_tax("results/kraken_contig/","*viral.k2.output.taxlineage")
genomad_tax_df = load_genomad_tax("./results/genomad/")
iphop_host_df = load_iphop("./results/host_iphop/")

t = abundanceDf.merge(genomad_tax_df,on="Contig",how="left").merge(kraken_tax_df,on="Contig",how="left").merge(iphop_host_df,on="Contig",how="left")
t.to_csv("summary/virome_contig_taxonomy_abbundance.txt",sep="\t")
print(t)
'''
## VT map abundance (virom; bacteria; GPD)
abundanceDf = merge_coverm("results/vt_mapping/btalign_virome/coverm/")
abundanceDf.to_csv("summary/vt_mapping_virome.abundance.txt")

abundanceDf = merge_coverm("results/vt_mapping/btalign_GPD/coverm/")
abundanceDf.to_csv("summary/vt_mapping_GPD.abundance.txt")

abundanceDf = merge_coverm("results/vt_mapping/btalign_bacteria/coverm/")
abundanceDf.to_csv("summary/vt_mapping_bacteria.abundance.txt")
#
