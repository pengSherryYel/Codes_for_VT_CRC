# coding: utf-8
import pandas as pd
import glob
def merge_vt_GPD(dirpath,optfile):
    resultL=[]
    coverageFL = glob.glob(dirpath)
    print(coverageFL)
    for coverage in coverageFL:
        sampleid=coverage.split("/")[-2]
        tmpD = pd.read_csv(coverage,sep="\t")
        tmpD["Sample"]=[sampleid]*len(tmpD)
        #print(tmpD)
        resultL.append(tmpD)
    d = pd.concat(resultL)
    d.to_csv(optfile)
    print(d)
merge_vt_GPD("./virome_abundance/btalign_GPD/*/*coverage","./virome_abundance/btalign_GPD.coverage.csv")
merge_vt_GPD("./vt_mapping/btalign_GPD/*/*coverage","./vt_mapping/btalign_GPD.coverage.csv")
merge_vt_GPD("./vt_mapping/btalign_bacteria/*/*coverage","./vt_mapping/btalign_bacteria.coverage.csv")
