#!/bin/bash
#SBATCH -J process_rna_seq_v2
#SBATCH -A naiss2025-5-531
#SBATCH -p shared
#SBATCH --mem=200GB
#SBATCH -t 24:00:00
#SBATCH -o %x.out
#SBATCH -e %x.err

# this script will process the RNA seq reads

# source and actiavte envs
source $HOME/.bash_profile

# load modules for java 
module load PDCOLD/23.12
module load openjdk/11.0.20.1_1-gcc-aua

# define inputs
hap1=~/Anastatica_hierochuntica/Haplome1/Assembly/haplome1.fa
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

# fastqc -t 20 -o fastqc -f fastq $rnaseqdir/*

conda deactivate

# run multiqc

conda activate multiqc

# multiqc --filename $project --outdir multiqc fastqc

conda deactivate

cd ../
mkdir -p s2_trimming_reads
cd s2_trimming_reads
mkdir -p trimmed_fastqs
mkdir -p fastqc
mkdir -p multiqc

# trim reads
conda activate trim-galore

# trim_galore --cores 20 -o ./trimmed_fastqs $rnaseqdir/*

conda deactivate

# rerun fastqc and multiqc
# run fastqc

conda activate fastqc

# fastqc -t 20 -o fastqc -f fastq trimmed_fastqs/*.fq

conda deactivate

# run multiqc

conda activate multiqc

# multiqc --filename $project --outdir multiqc fastqc

conda deactivate

cd ../
mkdir -p s3_alignment
cd s3_alignment

conda activate hisat2

# create index

# hisat2-build -f -p 10 $hap1 index

# use hisat2 to map reads to genome
#../s2_trimming_reads/trimmed_fastqs/*.fq
hisat2 -p 32 -t --dta -x index -U $(echo ../s2_trimming_reads/trimmed_fastqs/*.fq | tr ' ' ',') -S all_mapped.sam

conda deactivate

# bam conversion sorting and indexing
conda activate minimap2_samtools

samtools view -bS --threads 32 all_mapped.sam > all_mapped.bam

samtools sort --threads 32 all_mapped.bam -o all_mapped.sorted.bam

samtools index -@ 32 all_mapped.sorted.bam

conda deactivate

# get job id
echo "The Job ID for this job is: $SLURM_JOB_ID"
