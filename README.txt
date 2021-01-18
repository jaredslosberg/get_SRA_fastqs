Snakemake workflow to go from NCBI accessions to fastqs.

Maybe a worse version of https://bioconductor.org/packages/devel/bioc/vignettes/SRAdb/inst/doc/SRAdb.pdf

Input: could be SRR, SRX, or SRP ids
	-recommended to be SRP ids, directories are named based on this
note: smallest resolution that can be returned is SRX. if a SRR is input, it will grab metadata and fastqs for the entire SRX it resides in

Output:
	-writes fastqs from fasterq-dump to any directory specified in config file
	-appends [project_id]/[experiment_id] to that specified directory to organize fastqs
	-status file in ./output/[project_id]/[experiment_id] that records date of most recent download

TODO: make clear which yaml is parameters vs conda env
Test in isolated (singularity) environment
Where does prefetch go
Write metadata and fastqs to same location


First time running:
#will create conda environment to call snakemake helper scripts with
$ bash ./scripts/config.sh
#may need to configure (https://github.com/ncbi/sra-tools/wiki/03.-Quick-Toolkit-Configuration)

Call SRA_project_snake with:
$ bash SRA_project_snake.sh [SRP-accession-id]


