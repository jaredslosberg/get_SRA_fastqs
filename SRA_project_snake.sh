#Snakemake script implemented to provide experiment accessions.
#Here, before calling snakemake, provide an SRA project accession, grab the experiment accessions, and call snakemake for each

#will need conda env with snakemake esearch xpath

sra_project_accession=$1

echo $sra_project_accession
esearch -db sra -query $sra_project_accession | efetch -mode xml | \
	xpath -q -e "//EXPERIMENT/@accession" | cut -d'"' -f2 > \
	"$sra_project_accession"_experiment_accession_list.txt

while IFS= read -r exp_accession; do
	    snakemake -j16 --use-conda output/$sra_project_accession/$exp_accession/"$exp_accession"_status.txt
    done < "$sra_project_accession"_experiment_accession_list.txt

#To check if the biological and technical reads are labelled appropriately
#vdb-dump SRR9169172 -R1 -C READ_TYPE
