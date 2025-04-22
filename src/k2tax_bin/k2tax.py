# coding: utf-8
# %load ./k2tax.py

import pandas as pd
from NCBITaxonomy import ncbiAccTax
import click

def progresscheck(lst,n,checknumber=1000):
    totallen = len(lst)
    if totallen < checknumber:
        print("Total %s"%totallen)
    else:
        if int(n)%checknumber == 0:
            print("progress:%s"%(int(n)/totallen * 100))

@click.command()
@click.option("--krakenopt",'-i', help="Input krakenOpt file name")
def fmtkrakenOpt(krakenopt):
    data = pd.read_csv(krakenopt,header=None,sep="\t")
    data.columns = ["status","seqid","taxid","length","lca_mapping"]
    taxL = []
    taxD = {}
    n = 0
    for i in data["taxid"]:
        n+=1
        tax = ""
        if i in taxD:
            tax = taxD[i]
        else:
            tax = ncbiAccTax().taxid2lineage(i)
            taxD[i] = tax
        taxL.append(tax)
 
        #progresscheck(data["taxid"],n,checknumber=10000)

    data["lineage"] = taxL
    opt = data[["status","seqid","lineage","taxid","length"]]
    opt.to_csv("%s.taxlineage"%krakenopt,sep="\t",index=False)

if __name__ == "__main__":
    fmtkrakenOpt()

