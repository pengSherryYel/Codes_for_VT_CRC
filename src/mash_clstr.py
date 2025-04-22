# coding: utf-8
from collections import defaultdict
from Bio import Seq,SeqIO

def loadSeqName(inputfasta):
    ## load fna file and sort by length from long to short
    seqid_d={}
    for seq in SeqIO.parse(inputfasta,"fasta"):
        newid=seq.id.replace("|","__").replace("/","__")
        seqid_d[newid]=seq
    sort_seqid_d = {k: v for k, v in sorted(seqid_d.items(), key=lambda item: len(item[1]), reverse=True)}
    return sort_seqid_d

def load_mashani_opt(seqfile,mashani,maxani=95):
    seqid_d=loadSeqName(seqfile)

    aniD = defaultdict(dict)
    clusterD = {}
    cls2seqD = defaultdict(list)
    with open(mashani) as f:
        for line in f:
            query,ref,dissimilarity,evalue,sharefrag = [i.replace(".fasta","") for i in line.strip("\n").split("\t")]
            #print(query,ref,ani)
            ## original mash opt is use distance, in order change it to similarity, we need to change it. 
            sim_ani = (1 - float(dissimilarity))*100
            if query != ref and float(sim_ani)>=maxani:
                aniD[query][ref]=sim_ani


    n=1
    for seq in seqid_d.keys():
        print("query",seq,len(seqid_d[seq]))

        # iterate the member
        if seq in aniD:
            #print(aniD[seq])
            for mem in aniD[seq]:
                fani = aniD[seq][mem]
                rani = 0
                try:
                    rani = aniD[mem][seq]
                except:
                    rani = 0


                ## if over then put together
                if float(fani) >= maxani and float(rani) >= maxani:
                    print(seq,mem,fani,rani)
                    if seq not in clusterD and mem not in clusterD:
                        clusterD[seq]=n
                        clusterD[mem]=n
                        cls2seqD[n].append(seq)
                        cls2seqD[n].append(mem)
                        n+=1
                    ## below two part code will make a-c exceed the maxani
                    elif seq in clusterD and mem not in clusterD:
                        query_cluster_number = clusterD[seq]
                        clusterD[mem] = query_cluster_number
                        cls2seqD[query_cluster_number].append(mem)
                    elif seq not in clusterD and mem in clusterD:
                        ref_cluster_number = clusterD[mem]
                        clusterD[seq] = ref_cluster_number
                        cls2seqD[ref_cluster_number].append(seq)
                    else:
                        continue
                        #print("both assgined")

        else:
            if seq not in clusterD:
                cls2seqD[n].append(seq)
                clusterD[seq] = n
                n+=1
#        print(seq,n)
        #print(clusterD)
#        print(assigned_nodeList)


    ## write to opt
    rep_fasta=open("mashani_rep_id%s.fasta"%maxani,"w")
    rep_log=open("mashani_clstr_id%s.log"%maxani,"w")
    rep_log.write("clusterNum\tRep\tcenter\tNumber\tMember\n")
    for key,value in cls2seqD.items():
        #print(value)
        lengthL = [(i,len(seqid_d[i])) for i in value]
        first=lengthL[0][0]
        lengthL.sort(key=lambda x: x[-1])
        rep=lengthL[-1][0]
        #print(lengthL)
        SeqIO.write(seqid_d[rep],rep_fasta,"fasta")
        #print(key,rep,";".join(value))
        rep_log.write("\t".join([str(key),rep,first,str(len(value)),";".join(value)])+"\n")
    rep_fasta.close()
    rep_log.close()
    return cls2seqD

def help():
    print("\nThis is a script to cluster the fastANI results. This consider from the longest genome and only based on the genome with this centriod above maxani creteria. \nDO NOT CONSIDER THE DIST WITHIN GROUP MEMBER!!!")
    print(
            "Usage: python $0 input_fasta mashani_opt maxani\n"\
            "\tmaxani:value between 1-100, best above 85, because too low ANI is not accurate!\n"
        )


if __name__ == "__main__":
    import sys
    if len(sys.argv) == 4:
        infna=sys.argv[1]
        fastani=sys.argv[2]
        ## 1-100
        maxani=sys.argv[3]
        load_mashani_opt(infna,fastani,float(maxani))
    else:
        help()
#d = load_fastani_opt("../results_sim_6th/test_data_pick/cdhit_cluster_seq/test_data_123.all_long_idt0.98.rep.fasta","../results_sim_6th/test_data_pick/fastani.opt.tsv")
