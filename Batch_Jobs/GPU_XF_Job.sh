#!/bin/bash
## We want to submit the XFsolver as a job array to GPUs
## We'll submit up to 4 at a time (based on number of XF keys)
## Here's the submission command:
## sbatch --array=1-$NPOP%$batch_size --export=ALL,(variables) GPU_XF_job.sh
#SBATCH -A PAS1960
#SBATCH -t 3:00:00
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -G 2
#SBATCH --output=Run_Outputs/%x/Errs_And_Outs/XF_Outputs/XF_%a.output
#SBATCH --error=Run_Outputs/%x/Errs_And_Outs/XF_Errors/XF_%a.error
#SBATCH --mem-per-gpu=178gb

## make sure we're in the right directory
source $WorkingDir/Run_Outputs/$RunName/setup.sh

cd Run_Outputs/$RunName/Flags/GPUFlags

module load xfdtd/7.10.2.3 #7.9.2.2
module load cuda

# Get the individual's simulation directory
if [ $SYMMETRY -eq 0 ]
then
	individual_number=$((${gen}*${NPOP}*2+${SLURM_ARRAY_TASK_ID}))
else
	individual_number=$((${gen}*${NPOP}+${SLURM_ARRAY_TASK_ID}))
fi

individual_number=$((gen*NPOP*symmetry_multiplier+sim_num))
indiv_dir_parent=$XFProj/Simulations/$(printf "%06d" $individual_number)
indiv_dir=$indiv_dir_parent/Run0001

# Run the xsolver
cd $indiv_dir
xfsolver --use-xstream=true --xstream-use-number=2 --num-threads=2 -v

# Create the flag file
cd $RunDir/Flags/GPUFlags
echo "The GPU job is done!" >> Part_B_GPU_Flag_${individual_number}.txt 
