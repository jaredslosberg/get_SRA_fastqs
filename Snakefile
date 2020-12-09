rule get_metadata:
	input:
	output:
		"{project_accession}_out/{project_accession}_runinfo.csv",
		"{project_accession}_out/{project_accession}_accession_list.txt"
	conda:
        	"config/get_SRP.yaml"
	shell:
		"""
		cd {wildcards.project_accession}_out/ 

                #Grabs meta data, fetches in table format, and saves to csv
                esearch -db sra -query '{wildcards.project_accession}' |efetch -format runinfo \
> {wildcards.project_accession}_runinfo.csv

                #same thing, but save only SRRs, one per line, to use with prefetch or fasterqdump
                #First column (-f1) holds SRRs, delim is ",", egrep gets rid of the heading and returns just SRRs
		esearch -db sra -query '{wildcards.project_accession}' | efetch -format runinfo | cut -f1 -d, \
| egrep 'SRR' > {wildcards.project_accession}_accession_list.txt

		"""

rule get_SRA:
	input:
		"{project_accession}_out/{project_accession}_accession_list.txt"
	output:
		"logs/{project_accession}_test.log"
	conda:
		"config/get_SRP.yaml"
	log:
		"logs/{project_accession}_test.log"
	shell:
		"""
		pwd > {log}
		
		prefetch SRR6854061
		#xargs -l prefetch < Acc_list.txt
		#point to correct directory and append ".sra" to each argument
		#cd /home/jared/tmp_sra_home/sra/
		#awk '{{print $0".sra"}}' /home/jared/projects/SRA/Vandy_ENS/SRP268705_Acc_List.txt > \
		#       /home/jared/projects/SRA/Vandy_ENS/tmpSRA.txt
		#xargs -l vdb-validate < /home/jared/projects/SRA/Vandy_ENS/tmpSRA.txt

		#feeds each line of smallset.txt (accession numbers) to fastq command
		#flags: --split-files separates paired reads
		#-I appends a unique "1" or "2" to pairs
		#-O output directory, -t temp directory
		#xargs -l fasterq-dump -O /mnt/morbo/Data/Public/Southard_Smith_Vanderbilt_ENS_2020/mouse/SRP268705/raw/ --include-technical < /home/jared/projects/SRA/Vandy_ENS/tmpSRA.txt

		#Clear tmp .sra files
		#rm /home/jared/tmp_sra_home/sra/*.sra*
		"""
