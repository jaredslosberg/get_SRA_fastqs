#Script to grab SRA raw data entries from publicly published data, and then convert to fastqs
#Required: new line deliminated list of SRR entiries in a .txt file
#Recommended: write out to a log file to reference

pwd 2> {log}
cd ../
#xargs -l prefetch < ./SRP268705_Acc_List.txt
#point to correct directory and append ".sra" to each argument
#cd /home/jared/tmp_sra_home/sra/
#awk '{print $0".sra"}' /home/jared/projects/SRA/Vandy_ENS/SRP268705_Acc_List.txt > \
#	/home/jared/projects/SRA/Vandy_ENS/tmpSRA.txt
#xargs -l vdb-validate < /home/jared/projects/SRA/Vandy_ENS/tmpSRA.txt

#feeds each line of smallset.txt (accession numbers) to fastq command
#flags: --split-files separates paired reads
#-I appends a unique "1" or "2" to pairs
#-O output directory, -t temp directory
#xargs -l fasterq-dump -O /mnt/morbo/Data/Public/Southard_Smith_Vanderbilt_ENS_2020/mouse/SRP268705/raw/ --include-technical < /home/jared/projects/SRA/Vandy_ENS/tmpSRA.txt

#Clear tmp .sra files 
#rm /home/jared/tmp_sra_home/sra/*.sra*

