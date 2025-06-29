# Codes_for_VT_CRC
Codes for the CRC projects

The study explores the interactions between phages and bacteria in the gut, comparing healthy individuals to those with ulcerative colitis and colorectal cancer. It identifies significant shifts in these interactions related to disease states.


## Bioinformatic analysis overview
To elucidate the interactions between phages and bacteria, three systematic steps were implemented:
1. **Construction of the Bacterial Source**  
This step involved assemble and identify bacterial communities from the fecal samples of the study participants. The aim was to create a diverse and representative source of bacteria for subsequent analysis.

2. **Construction of the Virome Source (Virome + cross assemble)**  
In this phase, viral-like particles were identified from the same fecal samples . This step ensured that the virome source accurately reflected the viral population present in the gut microbiome, enabling a thorough examination of phage diversity. 
Moreover, **cross-assemble** of virome and viral tagging samples were applied to create a representative source of virus for subsequent analysis.

3. **Analysis of the Viral Tagging Samples**  
This step involved the identify the phages and bacteria pairs from viral tagging techniques. This analysis was crucial for understanding the dynamics of phage-bacteria relationships and their implications for gut health.

## Folder Structure
results: folder contain main workflow analysis viral tagging and virome data

results_bacteria: folder contain main workflow analysis bacteria data

src: folder contain all script used in this project.

## Main Scripts/Workflow for each part
### Viral tagging 
#### Main workflow (results/wf_vt_main.sh) 
Steps:  
1. QC 
2. Assemble
3. viral identification: CheckV + VirSorter (db1+db2)
4. Taxonomy identification (Kranken + genomad)  
5. Host identification (iphop) 

To accurately identify bacteria and phages in viral tagging samples, viral reads were initially mapped to the nonredundant virome catalog (NR<sub>Virome</sub>), constructed from virome data. Due to a low mapping rate, the analysis incorporated the Gut Phage Database (GPD) to enhance reference material. Subsequently, a cross-assembly strategy was employed to integrate data from both the NR<sub>cross-assemble</sub> and GPD, thereby expanding the viral source for a more comprehensive identification of viral entities within the samples.

1. NR<sub>Virome</sub>
2. GPD  
    To narrow down the GPD scope, sequences been mapped were retained to gather together with NR<sub>cross-assemble</sub>.
3. NR<sub>bacteria</sub>   
    To identify the bacteria soruce in viral tagging
4. NR<sub>bacteria_prophage</sub>   
    To make sure no prophages influence the bacteria source identification
5. NR<sub>viral_tagging</sub>  
    To assess the assemble quality and relative abundance of viral tagging samples
6. NR<sub>cross-assemble</sub>  
    To identify the viral soruce in viral tagging

To create circle plot, viral tagging contigs were map to cross-assemble sequences and GPD database.

#### Other scripts
results/wf_vt_extra.sh: Construct VT non-redundant catalog.

---
---

### Virome
#### Main workflow (results/wf_virome_main.sh) 
Steps:  
1. QC (remove Phix/Human and low quality)
2. Assemble
3. Viral identification: CheckV + VirSorter (db1+db2)
4. Clean reads were map to NR<sub>Virome</sub> to assess the assemble quality and relative abundance 
5. Clean reads were map to GPD, mapped sequences were retained to gather together with NR<sub>cross-assemble</sub>.
6. To create circle plot, virome contigs were map to cross-assemble sequences and GPD database.
7. Taxonomy identification (Kranken + genomad)  
8. Host identification (iphop) 

#### Other scripts
results/wf_virome_extra.sh: Construct virome non-redundant catalog

----
----

### Cross assemble of viral tagging and virome sample
#### Main workflow 
#### 1. results/wf_cross_assemble.sh  
This script will generate the batch scripts for pairwise cross assemble for virome and viral tagging samples.

#### 2. results/wf_cross_assemble.extra.sh
Following the cross-assembly of samples, the next step involved dereplicating the datasets according to different disease types. This process was implemented to reduce the volume of data, thereby facilitating more efficient and targeted analysis in subsequent investigations.  

steps:
1. Merge sequences according to different disease types
2. dereplicate (Mash; 95% similarity)
3. Identify viral contigs  
a. build blast db, use for vt and virome viral sequences alignment. Aligned cross-assemble sequences will be classified as viral sequences. 
b. CheckV
4. Taxnomy (genomad): After got the viral sequences from step 3, taxonomy is assigned by genomad
5. Host identification  
a. Crispr: CrisprOpenDB + Crispr identified from bacteria source    
 (Ps: Crispr identified from bacteria source please see results_bacteria/wf_bacteria_nonreduncant_realtiveAb.sh and alignment see results/wf_cross_assemble.align.crispr.sh)  
b. Iphop

To make a comprehensive viral source catalog, sequences from GPD were included. first, viral reads from vt and virome were map to GPD. Sequences been mapped (covbases > 10k or coverage > 60) were kept. And mapped GPD sequences and viral cross-assemble sequences were dereplicate at 98%. After that build bowtie and blast index for next step analysis. 

#### 3. results/wf_cross_assemble.align.crispr.sh
This script use blast to identify the host information of cross-assemble contigs using crispr identified from bacteria source. 


#### Other scripts
results/merge_bt_align.py: merge multiple alignment coverage file.

------
------

### Bacteria
#### Main workflow 
#### 1. results_bacteria/wf_bacteria_main.sh
Steps:  
1. QC (remove Phix/Human and low quality reads)
2. Assemble
3. Clean reads were map to assembled contigs to assess the assemble quality 
4. Clean reads were map to UHGG database to expand the bacteria source, mapped sequences were retained to gather together with assembled bacteria contigs.
5. Taxonomy identification (Kranken + MMseqs2)  
6. To get the relative abundance, clean reads were map to NR<sub>bacteria</sub> and relative abundance were calculated using coverM. (see how to create the no redunant dataset：results_bacteria/wf_bacteria_nonreduncant_realtiveAb.sh)

7. To assess the prophage effect in clean reads. Clean reads were map to NR<sub>prophage</sub> and relative abundance were calculated using coverM. （see how to create the no redunant dataset：  results_bacteria/wf_prophage_nonreduncant_realtiveAb.sh）


#### 2. results_bacteria/wf_bacteria_select_uhgg_mapping_derep.sh
1. Merge UHGG with assembled contigs of each sample, and then dereplicate use CDHIT at 95%. Since dereplicating all samples together requires a large amount of memory, first dereplicate each sample individually against UHGG.
2. Clean reads were map to dereplicated sequence to assess the quality.
3. Identify prophages using genomad.


#### 3. results_bacteria/wf_bacteria_nonreduncant_realtiveAb.sh
1. To create the NR<sub>bacteria</sub>, merge all dereplicated contigs from indivial samples (created from results_bacteria/wf_bacteria_select_uhgg_mapping_derep.sh) into one, and then use CDHIT to dereplicate at 95%.
2. build bowtie index of NR<sub>bacteria</sub> for VT reads and bacteria reads mapping.
3. Identify the CRISPR from NR<sub>bacteria</sub>, this will use to identify the host information of viral source.  (Ps: identify viral host see results/wf_cross_assemble.align.crispr.sh)  

#### 4. results_bacteria/wf_prophage_nonreduncant_realtiveAb.sh
1. To create the NR<sub>prophage</sub>, merge all dereplicated prophages from indivial samples (created from results_bacteria/wf_bacteria_select_uhgg_mapping_derep.sh) into one, and then use CDHIT to dereplicate at 95%.
2. build bowtie index of NR<sub>prophage</sub> for VT reads and bacteria reads mapping.

-----
-----


## Dependent Scripts in this projects (Folder src)
1. src/cluster_ctg_balstn_ani_modify.sh  
    Cluster the cross assemble contigs based on 98% ANI.   
    Used in results/wf_cross_assemble.extra.sh

2. src/k2tax_bin/k2tax.main.sh  
    Use kraken to predict the taxonomy.  
    Used in results/wf_virome_main.sh, results/wf_vt_main.sh:sh, results_bacteria/wf_bacteria_main.sh

3. src/mash_clstr.py  
    Use mash to cluster contigs.  
    Used in results/wf_cross_assemble.extra.sh. results/wf_virome_extra.sh, results/wf_vt_extra.sh

4. src/run_CrisprOpenDB.sh  
    Identify the viral host use CrisprOpenDB.  
    Used in results/wf_cross_assemble.extra.sh

5. src/run_cdhit_ctg_cluster.sh  
    Run CDHIT to cluster the sequences.  
    Used in results_bacteria/wf_bacteria_nonreduncant_realtiveAb.sh, results_bacteria/wf_bacteria_select_uhgg_mapping_derep.sh, results_bacteria/wf_prophage_nonreduncant_realtiveAb.sh

6. src/run_checkv.sh  
    Run checkv to identify the viral sequences.   
    Used in results/wf_cross_assemble.extra.sh, results/wf_virome_main.sh, results/wf_vt_main.sh  

7. src/run_crisprIdentify.sh  
    Identify crispr from bacteria.   
    Used in results_bacteria/wf_bacteria_nonreduncant_realtiveAb.sh  

8. src/run_genomad.sh  
    Run genomad.  
    Used in results/wf_cross_assemble.extra.sh, results/wf_virome_main.sh, results/wf_vt_main.sh, results_bacteria/wf_bacteria_select_uhgg_mapping_derep.sh

9. src/runmash.sh  
    Run mash to cluster sequences.  
    Used in results/wf_cross_assemble.extra.sh, results/wf_virome_extra.sh, results/wf_vt_extra.sh  

10. src/select_uhgg_mapping.py  
    After mapping clean reads to UHGG, this will help to select the UHGG sequences which been mapped by bacteria clean reads.

11. src/stat_merge_Metagenomic_abundance_tax.py  
    Statistic script. Merge viral tagging reads map to bacteria and virome source.   

12. src/utility.sh  
    Utility script contain common function used in python script.   
    Used in src/run_cdhit_ctg_cluster.sh



Rest of the scripts is the main workflow of each part. See detail above.  
**Bacteria**  
├── wf_bacteria_main.sh  
├── wf_bacteria_nonreduncant_realtiveAb.sh  
├── wf_bacteria_select_uhgg_mapping_derep.sh  
├── wf_prophage_nonreduncant_realtiveAb.sh  

**Virome+Viral tagging cross assemble**  
├── wf_cross_assemble.align.crispr.sh  
├── wf_cross_assemble.extra.sh  
├── wf_cross_assemble.sh  

**Virome**  
├── wf_virome_extra.sh  
├── wf_virome_main.sh  

**Viral tagging**  
├── wf_vt_extra.sh  
└── wf_vt_main.sh  

-----
-----






