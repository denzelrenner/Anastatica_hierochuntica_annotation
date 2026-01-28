#!/bin/bash

#SBATCH -J braker_no_rnaseq_hap1
#SBATCH -A naiss2025-5-531
#SBATCH -p memory
#SBATCH --mem=400GB
#SBATCH -t 48:00:00
#SBATCH -o %x.out
#SBATCH -e %x.err

# source and actiavte envs
source $HOME/.bash_profile

# load singularity
module load PDC/24.11
module load singularity/4.2.0-cpeGNU-24.11

# set important variables
BRAKER_DIR=~/BRAKER
SHARED_DATA_DIR=~/Cardamine_Annotation_Haplomes/Shared_Input_Data
augustus_config=/cfs/klemming/projects/supr/yantlab_storage/Denzel/BRAKER/augustus_config

## softmask possible cglacua
# set shared data, braker, input and output dirs
GENOMESEQDIR=/cfs/klemming/projects/supr/yantlab_storage/Denzel/Anastatica_hierochuntica/Haplome1/Output/Rmodeler
genome_name=anastatica_hierochuntica_hap1.softmasked.fa
species=a_hier1
OUTPUTDIR=/cfs/klemming/projects/supr/yantlab_storage/Denzel/Anastatica_hierochuntica/Haplome1/Output/BRAKER

# move into shared data dir
cd $SHARED_DATA_DIR

# get orthodb partition for plants
if [ ! -f Viridiplantae.fa.gz ] || [ ! -f Viridiplantae.fa ]; then
    echo "File not found! Downloading..."
    wget https://bioinf.uni-greifswald.de/bioinf/partitioned_odb11/Viridiplantae.fa.gz
    gunzip Viridiplantae.fa.gz
fi

# move into directory with barker.sif file
cd $BRAKER_DIR

# set new variable for BRAKER SIF file location
BRAKER_SIF=$PWD/braker3.sif

# run braker3, below is the original code from the test3.sh script
# Author: Katharina J. hoff
# Contact: katharina.hoff@uni-greifswald.de
# Date: Jan 12th 2023

# Copy this script into the folder where you want to execute it, e.g.:
# singularity exec -B $PWD:$PWD braker3.sif cp /opt/BRAKER/example/singularity-tests/test3.sh .
# Then run "bash test3.sh".

# Check whether braker3.sif is available

if [[ -z "${BRAKER_SIF}" ]]; then
    echo ""
    echo "Variable BRAKER_SIF is undefined."
    echo "First, build the sif-file with \"singularity build braker3.sif docker://teambraker/braker3:latest\""
    echo ""
    echo "After building, export the BRAKER_SIF environment variable on the host as follows:"
    echo ""
    echo "export BRAKER_SIF=\$PWD/braker3.sif"
    echo ""
    echo "You will have to modify the export statement if braker3.sif does not reside in \$PWD."
    echo ""
    exit 1
fi

# Check whether singularity exists

if ! command -v singularity &> /dev/null
then
    echo "Singularity could not be found."
    echo "On some HPC systems you can load it with \"module load singularity\"."
    echo "If that fails, please install singularity."
    echo "Possibly you misunderstood how to run this script. Before running it, please copy it to the directory where you want to execute it by e.g.:"
    echo "singularity exec -B \$PWD:\$PWD braker3.sif cp /opt/BRAKER/example/singularity-tests/test3.sh ."
    echo "Then execute on the host with \"bash test3.sh\"".
    exit 1
fi

# remove output directory if it already exists
#    - viridiplantae_odb12
#                - brassicales_odb12

# output directory set previously is the wording directory. If already exists it is replaced, otherwise it is ren
wd=$OUTPUTDIR

if [ -d $wd ]; then
    rm -r $wd
fi

singularity exec -B ${PWD}:${PWD} \
		-B ${GENOMESEQDIR}:${GENOMESEQDIR} \
		-B ${SHARED_DATA_DIR}:${SHARED_DATA_DIR} \
		-B ${augustus_config}:${augustus_config} ${BRAKER_SIF} braker.pl --AUGUSTUS_CONFIG_PATH=${augustus_config} \
		--genome=$GENOMESEQDIR/$genome_name \
		--prot_seq $SHARED_DATA_DIR/Viridiplantae.fa --workingdir=${wd} \
		--species=$species --gff3 \
		--threads 8 --busco_lineage brassicales_odb12 &> brakerrun.log



# get job id
echo "The Job ID for this job is: $SLURM_JOB_ID"
