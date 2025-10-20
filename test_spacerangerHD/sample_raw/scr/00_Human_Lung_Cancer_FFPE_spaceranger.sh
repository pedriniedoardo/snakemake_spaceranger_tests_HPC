#!/bin/bash
#SBATCH --job-name=spaceranger
#SBATCH --account pedrini.edoardo
#SBATCH --mem=64GB  # amout of RAM in MB required (and max ram available).
#SBATCH --time=INFINITE  ## OR #SBATCH --time=10:00 means 10 minutes OR --time=01:00:00 means 1 hour
#SBATCH --ntasks=8  # number of required cores
#SBATCH --nodes=1  # not really useful for not mpi jobs
#SBATCH --mail-type=FAIL ## BEGIN, END, FAIL or ALL
#SBATCH --mail-user=pedrini.edoardo@hsr.it
#SBATCH --error="Human_Lung_Cancer_FFPE.err"
#SBATCH --output="Human_Lung_Cancer_FFPE.out"

. /opt/common/tools/ric.cosr/miniconda3/bin/activate;
conda activate demux

spaceranger3 count --id=Human_Lung_Cancer_FFPE \
--fastqs=/idle/ric.cosr/ric.cosr/pedrini.edoardo/test_spatial/test_spacerangerHD/sample_raw/Visium_HD_Human_Lung_Cancer_fastqs \
--transcriptome=/beegfs/datasets/buffer/ric.cosr/cellranger_genomes/refdata-gex-GRCh38-2020-A \
--probe-set=/idle/ric.cosr/ric.cosr/pedrini.edoardo/test_spatial/test_spacerangerHD/sample_raw/Visium_HD_Human_Lung_Cancer_probe_set.csv \
--custom-bin-size=50 \
--slide=H1-HMD7CWH \
--area=A1 \
--darkimage=/idle/ric.cosr/ric.cosr/pedrini.edoardo/test_spatial/test_spacerangerHD/sample_raw/Visium_HD_Human_Lung_Cancer_tissue_image.tif \
--cytaimage=/idle/ric.cosr/ric.cosr/pedrini.edoardo/test_spatial/test_spacerangerHD/sample_raw/Visium_HD_Human_Lung_Cancer_cytaimage.tif \
--create-bam=false \
--localcores=8 \
--localmem=64