# coding: utf-8
import pandas as pd
import sys,os

## this script is used for select the uhgg mapping contig, prepare the seq for cluster with assemble 

prefix=sys.argv[1]

#coverage="./MTFLA8057_b/MTFLA8057_b.bam.coverage"
coverage="btalign_uhgg/{0}/{0}.bam.coverage".format(prefix)

coverage_df = pd.read_csv(coverage,sep="\t")
sampleL=[i.split("_")[0] for i in coverage_df["#rname"]]
coverage_df["sample"]=sampleL

max_reads= coverage_df["numreads"].max()
read_creteria = 0.8*max_reads

max_depth = coverage_df["meandepth"].max()
depth_creteria = 0.8*max_depth

coverage_df.describe()

final_df = coverage_df.query("(numreads >= @read_creteria) | (coverage >= 60) | (meandepth >= @depth_creteria)")


outDir="uhgg_contig_derep"
if not os.path.exists(outDir):
    os.makedirs(outDir)

final_df.to_csv("{0}/{1}.selected.uhgg.detailInfo.csv".format(outDir,prefix))
final_df.loc[:,"#rname"].to_csv("{0}/{1}.header".format(outDir,prefix),index=False)
