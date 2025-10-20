#!/bin/bash
#SBATCH --job-name=spaceranger
#SBATCH --account pedrini.edoardo
#SBATCH --mem=128GB  # amout of RAM in MB required (and max ram available).
#SBATCH --time=INFINITE  ## OR #SBATCH --time=10:00 means 10 minutes OR --time=01:00:00 means 1 hour
#SBATCH --ntasks=16  # number of required cores
#SBATCH --nodes=1  # not really useful for not mpi jobs
#SBATCH --mail-type=FAIL ## BEGIN, END, FAIL or ALL
#SBATCH --mail-user=pedrini.edoardo@hsr.it
#SBATCH --error="Sample_HDP031_E1_HE_test.err"
#SBATCH --output="Sample_HDP031_E1_HE_test.out"

. /opt/common/tools/ric.cosr/miniconda3/bin/activate;
conda activate demux

spaceranger3 count --id=Sample_HDP031_E1_HE_test \
--fastqs=/beegfs/scratch/ric.cosr/ric.cosr/runs//250213_A00626_0926_BHTC3CDRX5_2/Project_CastellanoA_2392_SpatialTrasccriptomicsVisiumHD_Hyperdirect/Sample_HDP031_E1 \
--transcriptome=/beegfs/datasets/buffer/ric.cosr/cellranger_genomes/refdata-gex-GRCh38-2020-A \
--probe-set=/beegfs/datasets/buffer/ric.cosr/cellranger_probesets/Visium_Human_Transcriptome_Probe_Set_v2.0_GRCh38-2020-A.csv \
--custom-bin-size 16 \
--slide H1-6YFXB49 \
--area D1 \
--image /beegfs/scratch/ric.cosr/ric.cosr/cytassist_images//250213_A00626_0926_BHTC3CDRX5_2/Project_CastellanoA_2392_SpatialTrasccriptomicsVisiumHD_Hyperdirect/Sample_HDP031_E1/Sample_HDP031_E1.ome.tif \
--cytaimage=/beegfs/scratch/ric.cosr/ric.cosr/cytassist_images//250213_A00626_0926_BHTC3CDRX5_2/Project_CastellanoA_2392_SpatialTrasccriptomicsVisiumHD_Hyperdirect/Sample_HDP031_E1/H1-6YFXB49-D1-sample.tif \
--create-bam=false \
--localcores 16 \
--localmem 128
