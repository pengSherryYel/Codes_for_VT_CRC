from ete3 import NCBITaxa


class ncbiAccTax:
   
    def __init__(self,acc=[],accType="l",ncbifile="./test"):
        ## acc type is f-file|l-list
        self.acc = acc
        self.accType = accType
        self.ncbitax = ncbifile
    
    def loadTaxFile(self,sep="\t"):
        acc2taxD = {}
        with open(self.ncbitax) as f:
            for line in f:
                acc,version,taxid,gi = line.strip("\n").split(sep)
                if taxid != "taxid":
                    acc2taxD[acc] = (version,int(taxid))
        self.acc2taxD = acc2taxD
        return acc2taxD
    
    def updateNcbiTaxDB(self):
        print("updating ncbi tax database")
        ncbi = NCBITaxa()
        ncbi.update_taxonomy_database()

    def taxid2name(self,taxidNum):
        ## input should be list --> return dict
        ncbi = NCBITaxa()
        if not isinstance(taxidNum,list):
            taxidNum = [taxidNum]
        name = ncbi.get_taxid_translator(taxidNum)
        return name

    def name2taxid(self,name):
        ## input should be list --> return dict
        ncbi = NCBITaxa()
        if not isinstance(name,list):
            name = [name]
        taxid = ncbi.get_name_translator(name)
        return taxid

    def taxid2rank(self,taxid):
        ## input should be list --> return dict
        ncbi = NCBITaxa()
        if not isinstance(taxid,list):
            taxid = [taxid]
        rank = ncbi.get_rank(taxid)
        return rank
    
    def taxid2lineage(self,taxidNum,level=['superkingdom','phylum','class','order','family','genus','species']):
        ## input a taxid num --> lineage(str)
        prefixD = {'superkingdom':"k",'phylum':"p",
                    'class':"c",'order':"o",'family':"f",
                    'genus':"g",'species':"s"}
        ncbi = NCBITaxa()
        lineage = ncbi.get_lineage(taxidNum)
        rankD = self.taxid2rank(lineage)
        level2taxidD = {taxlevel:taxid for taxid, taxlevel in rankD.items()}
        t = []
        for i in level:
            name = "NA"
            taxidlevel = level2taxidD.get(i,"NA")
            if taxidlevel != "NA":
                name = self.taxid2name(taxidlevel)[taxidlevel]
            prefix = prefixD[i]
            t.append("%s_%s"%(prefix,name))
        wd = ";".join(t)
        return wd


    def acc2taxid(self,optFile="./accTax.list"):
        ## input list or file --> file
        opt = open(optFile,"w")
        if self.accType == "l":
            for i in self.acc:
                accNoVersion = i.split(".")[0]
                accVersion,taxid = self.acc2taxD.get(accNoVersion,["NA",0])
                if taxid != 0:
                    taxidLevel = self.taxid2rank(taxid)[taxid]
                    taxidName = self.taxid2name(taxid)[taxid]
                    lineage = self.taxid2lineage(taxid)
                    t = [i, accVersion, str(taxid), taxidName, taxidLevel, lineage]
                    opt.write("\t".join(t)+"\n")
                    print(i, accVersion, taxid, taxidName, taxidLevel, lineage)
                elif taxid == 0:
                    print("%s not in ncbi acc file"%i)
        elif self.accType == "f":
            with open(self.acc) as f:
                for line in f:
                    i = line.strip("\n")
                    accNoVersion = i.split(".")[0]
                    accVersion,taxid = self.acc2taxD.get(accNoVersion,["NA",0])
                    if taxid != 0:
                        taxidLevel = self.taxid2rank(taxid)[taxid]
                        taxidName = self.taxid2name(taxid)[taxid]
                        lineage = self.taxid2lineage(taxid)
                        t = [i, accVersion, str(taxid), taxidName, taxidLevel, lineage]
                        opt.write("\t".join(t)+"\n")
                        print(i, accVersion, taxid, taxidName, taxidLevel, lineage)
                    elif taxid == 0:
                        print("%s not in ncbi acc file"%i)

        else:
            print("accType should be l|f")
        opt.close()
    # def accfile


if __name__ == "__main__":
    t = ncbiAccTax(["A00003.1","A00005.1","A00021.1"],accType="l",ncbifile="./test")
    # t.updateNcbiTaxDB()
    d = t.loadTaxFile()
    # print(t.taxid2name([32630,1385]))
    # print(t.name2taxid('Bacillales'))
    # print(t.taxid2rank(32630))
    # print(t.taxid2lineage(1423))
    t.acc2taxid()





