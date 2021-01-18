
#configuration file with output directories, number of threads to use, arguments for fasterq-dump
configfile:
	"config/run_SRA_params.yaml"

#For each SRX experiment, create a list of each SRR run to be downloaded	
rule get_experiment_run_list:
	input:
	output:
		run_accession_list="output/{project_accession}/{experiment_accession}/run_accession_list.txt"
	conda:
		"config/SRA_workflow.yaml"
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
#get the SRX metadata (sequence types, samples, ...)
rule get_experiment_metadata:
	input:
	output:
		#Actual accession list
		run_accession_list="output/{project_accession}/{experiment_accession}/{experiment_accession}_run_accession_list.txt"
	params:
		metadata_out_dir=config["metadata_out_dir"]
	conda:
        	"config/SRA_workflow.yaml"
	shell:
		"""
		mkdir -p  output/{wildcards.project_accession}/{wildcards.experiment_accession}/ 

                #Grabs meta data, fetches in table format, and saves to csv
                esearch -db sra -query '{wildcards.experiment_accession}' |efetch -format runinfo \
			> {params.metadata_out_dir}

                #same thing, but save only SRRs, one per line, to use with nstall -c bioconda perl-xml-xpathpprefetch or fasterqdump
                #First column (-f1) holds SRRs, delim is ",", egrep gets rid of the heading and returns just SRRs
		esearch -db sra -query '{wildcards.experiment_accession}' | efetch -format runinfo | cut -f1 -d, \
			| egrep 'SRR' > {output.run_accession_list}

		"""

#actually call fasterq-dump which will download the fastqs for each SRR run, organized into directories for the SRP project and SRX experiment
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
		"config/SRA_workflow.yaml"
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

		"""
