configfile:
	"config/run_SRA_params.yaml"

#def getExperimentAccessions(wildcards):
#	exp_accessions = list()
#	for s in os.listdir(wildcards.project_accession+"_out/"):
#		if s.startswith("SRX"):
#			exp_accessions.append(s)
#	return exp_accessions
	
rule get_experiment_run_list:
	input:
	output:
		run_accession_list="output/{project_accession}/{experiment_accession}/run_accession_list.txt"
	conda:
		"config/get_SRP.yaml"
	shell:
		"""		
		#Given a experiment SRX accession number, get SRR runs that make up that experiment
		#Create a directory for each experiment to store fastqs
		esearch -db sra -query {wildcards.experiment_accession} | efetch -mode xml | \
			xpath -q -e '//EXPERIMENT/@accession' | cut -d'"' -f2 > \
			{output.run_accession_list}
	
		awk '{{print  "output/"$0"_dir"}}' {output.experiment_accession_list} > tmp_appended_experiment_accessions.txt

	
		xargs -d '\n' mkdir -p < tmp_appended_experiment_accessions.txt 
		"""

rule get_exp:
	input:
		"{project_accession}_out/{project_accession}_experiment_accession_list.txt",
		
	params:
	output:
		"{project_accession}_test.txt"
	shell:
		"printf {params.exp} > {wildcards.project_accession}_test.txt"


rule get_experiment_metadata:
	input:
	output:
		#Actual accession list
		run_accession_list="output/{project_accession}/{experiment_accession}/{experiment_accession}_run_accession_list.txt"
	params:
	conda:
        	"config/get_SRP.yaml"
	shell:
		"""
		mkdir -p  output/{wildcards.project_accession}/{wildcards.experiment_accession}/ 

                #Grabs meta data, fetches in table format, and saves to csv
                esearch -db sra -query '{wildcards.experiment_accession}' |efetch -format runinfo \
			> {output.run_accession_list}

                #same thing, but save only SRRs, one per line, to use with nstall -c bioconda perl-xml-xpathpprefetch or fasterqdump
                #First column (-f1) holds SRRs, delim is ",", egrep gets rid of the heading and returns just SRRs
		esearch -db sra -query '{wildcards.experiment_accession}' | efetch -format runinfo | cut -f1 -d, \
			| egrep 'SRR' > {output.run_accession_list}

		"""

rule get_SRA:
	input:
		run_accession_list="output/{project_accession}/{experiment_accession}/{experiment_accession}_run_accession_list.txt"
	output:
		status="output/{project_accession}/{experiment_accession}/{experiment_accession}_status.txt"
	params:
		fastq_out_dir=config["fastq_out_dir"],
		fasterq_flags=config["fasterq_flags"]
	threads:
		config["THREADS"]
	conda:
		"config/get_SRP.yaml"
	log:
		"logs/{project_accession}/{experiment_accession}_test.log"
	shell:
		"""
		

		#Use this section if you want to use prefetch and validate the downloads. Necessary with
		#fastq dump but not neccesary with fasterq-dump
		#prefetch SRR6854061
		cat {input.run_accession_list} | while IFS= read -r run_accession; do
            		prefetch $run_accession && fasterq-dump $run_accession {params.fasterq_flags} \
				-O {params.fastq_out_dir}/{wildcards.project_accession}/{wildcards.experiment_accession}
			done > {log} 2>&1
			#cat {input.run_accession_list} | xargs -l prefetch > {log}
		#point to correct directory and append ".sra" to each argument
		#TODO: Where does prefetch download to, when installed from conda?
		#sra_dir="/scratch/users/jared/sra_tmp/"
		#awk '{{print $0".sra"}}' {input.run_accession_list} > outputrun_accession_list
		#xargs -l vdb-validate < /home/jared/projects/SRA/Vandy_ENS/tmpSRA.txt

		#feeds each line of SRR accession numbers list to fasterq command
		#flags: --split-files separates paired reads
		#xargs operates on each line with "-l"
		#-I appends a unique "1" or "2" to pairs
		#-O output directory, -t temp directory
		##Tags project accession and exp accession to general fastq location, to be processed togtherr
#		cat {input.run_accession_list} | xargs -l fasterq-dump {params.fasterq_flags} \
#-O {params.fastq_out_dir}/{wildcards.project_accession}/{wildcards.experiment_accession} \
#2> {log}

		echo 'fastqs for {wildcards.experiment_accession} were obtained on:' > {output.status}
		date >> {output.status}

		#Clear tmp .sra files
		#rm /home/jared/tmp_sra_home/sra/*.sra*
		"""
