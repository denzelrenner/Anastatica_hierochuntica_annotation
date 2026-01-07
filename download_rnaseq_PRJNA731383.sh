#!/bin/bash
#SBATCH -J download_rna_seq_PRJNA731383
#SBATCH -A naiss2025-5-531
#SBATCH -p shared
#SBATCH --mem=200GB
#SBATCH -t 72:00:00
#SBATCH -o %x.out
#SBATCH -e %x.err

# this script will download the RNA seq data from sra project PRJNA731383

# source and actiavte envs
source $HOME/.bash_profile

# define inputs
outputdir=~/Anastatica_hierochuntica/RNAseq
project=PRJNA731383

# make dirs
mkdir -p $outputdir
cd $outputdir
mkdir -p $project
cd $project
mkdir -p runs

# activate sra tools
conda activate sra-tools

# use query to find accession on SRA project
esearch -db sra -query '(PRJNA731383) AND "Anastatica hierochuntica"[orgn:__txid663965]' | efetch -format runinfo | tail -n +2 | cut -d, -f1 > srr_accession_list.txt

# loop through accessions and download fastq files
while IFS="" read -r run || [ -n "$run" ]
do
 fasterq-dump --split-files --threads 40 -O ./runs "${run}"
done < srr_accession_list.txt

conda deactivate
