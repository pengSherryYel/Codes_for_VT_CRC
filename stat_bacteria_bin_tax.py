# coding: utf-8
import pandas as pd
import glob
def format_bin(bindirpath="./uhgg_contig_derep",regrex_pattern="*fa"):
    ## bin file
    bin_fileL=glob.glob("%s/metabat/*/*bins/%s"%(bindirpath,regrex_pattern), recursive=True)
    #print(bin_fileL)
    sampleflag=0    
    merge_allL=[]    
    taxonomyDfL=[]
    
    for binfile in bin_fileL:
        bin_number=binfile.split("/")[-1].replace(".fa","")
        sample=binfile.split("/")[-3]
        print(bin_number, sample)
        seqid=get_ipython().getoutput("less $binfile|grep \\>|sed 's/^>//g'")
        tmpdf=pd.DataFrame(seqid,columns=["Contig"])
        tmpdf["bin_number"]=[bin_number]*len(tmpdf)
        tmpdf["sample"]=[sample]*len(tmpdf)
        #print(tmpdf)
        
        ## add bin tax
        gtdbtk_bac="%s/gtdbtk/%s/gtdbtk*tsv"%(bindirpath,sample)
        gtdbtk_bac_L=glob.glob(gtdbtk_bac)

        if gtdbtk_bac_L:
            for i in gtdbtk_bac_L:
                tax_tmpdf=pd.read_csv(i,sep="\t",usecols=[0,1,2,3])
                taxonomyDfL.append(tax_tmpdf)
            taxDf = pd.concat(taxonomyDfL)
            sampleflag=sample
            taxonomyDfL=[]
        finalDf = tmpdf.merge(taxDf,left_on="bin_number",right_on="user_genome",how="left")
            
        print(finalDf)
        merge_allL.append(finalDf)
    outputDF = pd.concat(merge_allL)
    print(outputDF)
    outputDF.to_csv("../summary/bacteria_bin.txt",index=False)
format_bin()
