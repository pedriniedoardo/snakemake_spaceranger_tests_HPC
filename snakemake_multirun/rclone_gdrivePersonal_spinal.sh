#!/bin/bash
#SBATCH --job-name=rclone
#SBATCH --account pedrini.edoardo
#SBATCH --mem=8GB  # amout of RAM in MB required (and max ram available).
#SBATCH --time=INFINITE  ## OR #SBATCH --time=10:00 means 10 minutes OR --time=01:00:00 means 1 hour
#SBATCH --ntasks=4  # number of required cores
#SBATCH --nodes=1  # not really useful for not mpi jobs
#SBATCH --mail-type=FAIL ## BEGIN, END, FAIL or ALL
#SBATCH --mail-user=pedrini.edoardo@hsr.it
#SBATCH --error="rclone_personal_spinal.err"
#SBATCH --output="rclone_personal_spinal.out"

echo "my job strart now" > rclone_personal_spinal.log;

date >> rclone_personal_spinal.log;

. /home/pedrini.edoardo/miniconda3/bin/activate;
conda activate env_rclone;

rclone copy -PL /idle/ric.cosr/ric.cosr/pedrini.edoardo/test_spatial/snakemake_multirun/results \
gdrive_edo:work/analysis/HSR/absinta/spatial/spinal/raw_data

date >> rclone_personal_spinal.log;