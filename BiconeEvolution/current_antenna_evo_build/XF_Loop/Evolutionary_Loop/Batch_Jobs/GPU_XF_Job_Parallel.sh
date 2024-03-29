#!/bin/bash
## We want to submit the XFsolver as a job array to GPUs
## We'll submit up to 4 at a time (based on number of XF keys)
## Here's the submission command:
## sbatch --array=1-$NPOP%$batch_size --export=ALL,(variables) GPU_XF_job.sh
#SBATCH -A PAS1960
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -G 2
#SBATCH --output=Run_Outputs/%x/XF_Outputs/XF_%a.output
#SBATCH --error=Run_Outputs/%x/XF_Errors/XF_%a.error
#SBATCH --mem-per-gpu=178gb

#WorkingDir=$WorkingDir,RunName=$RunName,XmacrosDir=$XmacrosDir,XFProj=$XFProj,NPOP=$NPOP,indiv=$individual_number,indiv_dir=$indiv_dir,gen=${gen},SYMMETRY=$SYMMETRY,PSIMDIR=$PSIMDIR

# Variables:
# WorkingDir
# RunName
# XmacrosDir
# XFProj
# NPOP
# indiv
# indiv_dir
# gen
# SYMMETRY
# PSIMDIR
# batch_size
# SingleBatch

module load xfdtd/7.10.2.3 #7.9.2.2
module load cuda

## We need to get the individual number
## This will be based on the number in the array

symmetry_multiplier=2

if [ $SYMMETRY -eq 1 ]
then
	symmetry_multiplier=1
fi

sim_num=$SLURM_ARRAY_TASK_ID
# correct for indiv_in_pop being 1-indexed
indiv_in_pop=$((sim_num-1))

# If we run a single batch of jobs, we run until we hit NPOP
# Otherwise, run once
if [ $SingleBatch -eq 1 ]
then
	upper_limit=$((NPOP*symmetry_multiplier-1))
else
	upper_limit=$indiv_in_pop
fi

while [ $indiv_in_pop -le $upper_limit ]
do
	individual_number=$((gen*NPOP*symmetry_multiplier+sim_num))

	## Based on the individual number, we need the right parent directory
	## This involves checking the individual number being submitted
	## This is complicated--the individual number should be the number in the job array
	## To do this, we'll have to call the array number (see above)
	if [ $individual_number -lt 10 ]
	then
		indiv_dir_parent=$XFProj/Simulations/00000$individual_number/
	elif [[ $individual_number -ge 10 && $individual_number -lt 100 ]]
	then
		indiv_dir_parent=$XFProj/Simulations/0000$individual_number/
	elif [[ $individual_number -ge 100 && $individual_number -lt 1000 ]]
	then
		indiv_dir_parent=$XFProj/Simulations/000$individual_number/
	elif [ $individual_number -ge 1000 ]
	then
		indiv_dir_parent=$XFProj/Simulations/00$individual_number/
	fi

	## Now we need to get into the Run0001 directory inside the parent directory
	indiv_dir=$indiv_dir_parent/Run0001

	cd $indiv_dir
	xfsolver --use-xstream=true --xstream-use-number=2 --num-threads=2 -v

	echo "finished XF solver"

	cd $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags

	echo "done"

	flag_file=Part_B_GPU_Flag_${individual_number}.txt

	echo "The GPU job is done!" >> $flag_file

	# iterate which individual we're on
	sim_num=$((indiv_in_pop+batch_size*symmetry_multiplier))
	indiv_in_pop=$((sim_num-1))

	# if we go over tartget, the job doesn't need to wait for
	# output xmacro and can terminate
	if [ $indiv_in_pop -gt $upper_limit ]
	then
		# echo how long this bash script has been running
		echo $SECONDS
		# echo all job information about time
		sacct -X -j $SLURM_JOB_ID --format=JobID,JobName,Partition,Elapsed,CPUTime,Reserved
		exit 0
	fi

	# wait until output xmacro is finished before starting next xsolver
	# to not go over XF key limit
	while [ ! -f $WorkingDir/Run_Outputs/$RunName/GPUFlags/$flag_file ]
	do
		sleep 1
	done

done

# echo how long this bash script has been running
echo $SECONDS
# echo all job information about time
sacct -X -j $SLURM_JOB_ID --format=JobID,JobName,Partition,Elapsed,CPUTime,Reserved




