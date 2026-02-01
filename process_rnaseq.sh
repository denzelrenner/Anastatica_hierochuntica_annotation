#!/bin/bash
#SBATCH -J process_rna_seq
#SBATCH -A naiss2025-5-531
#SBATCH -p shared
#SBATCH --mem=80GB
#SBATCH -t 2:00:00
#SBATCH -o %x.out
#SBATCH -e %x.err

# this script will process the RNA seq reads

# source and actiavte envs
source $HOME/.bash_profile

# load modules for java 
module load PDCOLD/23.12
module load openjdk/11.0.20.1_1-gcc-aua

# define inputs
outputdir=~/Anastatica_hierochuntica/RNAseq/PRJNA731383
rnaseqdir=~/Anastatica_hierochuntica/RNAseq/PRJNA731383/runs
project=PRJNA731383

# make dirs
mkdir -p $outputdir
cd $outputdir
mkdir -p s1_fastmultqc
cd s1_fastmultqc 
mkdir -p fastqc
mkdir -p multiqc

# run fastqc

conda activate fastqc

fastqc -t 20 -o fastqc -f fastq $rnaseqdir/*

conda deactivate

# run multiqc

conda activate multiqc

multiqc --filename $project --outdir multiqc fastqc

conda deactivate

# get job id
echo "The Job ID for this job is: $SLURM_JOB_ID"
