Snakemake workflow to go from NCBI accessions to fastqs.

Input: can be SRR, SRX, SRP, or PRJNA ncbi ids
note: smallest resolution that can be returned is SRX. if a SRR is input, it will grab metadata and fastqs for the entire SRX it resides in

Output:

TODO: make clear which yaml is parameters vs conda env
Test in isolated (singularity) environment
Where does prefetch go
Write metadata and fastqs to same location
Multithreads 
