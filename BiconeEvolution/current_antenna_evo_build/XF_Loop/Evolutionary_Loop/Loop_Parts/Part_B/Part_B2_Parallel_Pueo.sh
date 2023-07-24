#!/bin/bash
# Parallel version of Part B for PUEO
# This script will wait for the XF simulations to finish,
# submitting the pueoSim jobs as they finish
# The script waits until all XF and pueoSim jobs are finished

# varaibles
indiv=$1
gen=$2
NPOP=$3
WorkingDir=$4
RunName=$5
XmacrosDir=$6
XFProj=$7
GeoFactor=$8
num_keys=$9
NSECTIONS=${10}
XFCOUNT=${11}
PSIMDIR=${12}
SYMMETRY=${13}
exp=${14}
NNT=${15}

start_time=`date +%s`

cd $WorkingDir
mkdir -m775 ${XFProj}/XF_models_${gen} 2> /dev/null
mkdir -m775 Run_Outputs/${RunName}/Root_Files/${gen}_Root_Files 2> /dev/null
mkdir -m775 Run_Outputs/${RunName}/uan_files/${gen}_uan_files 2> /dev/null
mkdir -m775 ${PSIMDIR}/outputs/${RunName}/${gen}_outputs 2> /dev/null

# We need to count how many XF and pueoSim jobs are finished
# We'll do this by counting the number of files in the GPUFlags and PUEOFlags directory

cd $WorkingDir/Run_Outputs/$RunName/GPUFlags
gpu_flags=$(ls | wc -l)
cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags
pueo_flags=$(ls | wc -l)

peuosimsperindiv=49
peuocount=$((peuosimsperindiv * NPOP))
max_jobs=250
job_cutoff=$((max_jobs - peuosimsperindiv))
echo "job cutoff: $job_cutoff"
echo "peuosimsperindiv: $peuosimsperindiv"
echo "max_jobs: $max_jobs"
echo "peuocount: $peuocount"
#echo "pueocount: $peuocount"

# We need to wait until all the XF jobs are finished
while [[ $gpu_flags -lt $XFCOUNT ]]
do
	# if there is an output file in the TMPGPUFlags directory, submit a pueoSim job for that antenna and then move the file to the GPUFlags directory
	cd $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags
	# if there are no files in the TMPGPUFlags directory, wait 10 seconds and then check again Or if the number of jobs submitted is greater than 250 - 49
	jobs_submitted=$(squeue -u $USER | wc -l)
	if [[ $(ls | wc -l) -eq 0 || $jobs_submitted -gt $job_cutoff ]]
	then
		sleep 10
	else
		for file in *
		do
			indiv=$(echo "$file" | cut -d'_' -f5)
			# submit the pueoSim job
			cd $WorkingDir
			sbatch --array=1-49 --export=ALL,gen=$gen,WorkingDir=$WorkingDir,RunName=$RunName,Seeds=$Seeds,PSIMDIR=$PSIMDIR,NPOP=$NPOP,NNT=$NNT,Exp=$exp,indiv=$indiv --job-name=${RunName}_${indiv}_psim Batch_Jobs/PueoCall_Array_Indiv.sh
			# move the file to the GPUFlags directory
			cd $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags
			mv $file $WorkingDir/Run_Outputs/$RunName/GPUFlags
		done
	fi
	cd $WorkingDir/Run_Outputs/$RunName/GPUFlags
	gpu_flags=$(ls | wc -l)

	cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags
	pueo_flags=$(ls | wc -l)

	percent_gpu=$(bc <<< "scale=2; $gpu_flags/$XFCOUNT")
	percent_gpu=$(bc <<< "scale=2; $percent_gpu*100")
	percent_pueo=$(bc <<< "scale=2; $pueo_flags/$peuocount")
	percent_pueo=$(bc <<< "scale=2; $percent_pueo*100")

	echo "XF flags: $gpu_flags , $percent_gpu %"
	echo "PUEO flags: $pueo_flags, $percent_pueo %"
done

echo "XF flags: $gpu_flags , $percent_gpu % - All XF jobs finished!"

xf_finish_time=`date +%s`

pueosim_start_time=`date +%s`
# Now we need to wait until all the pueoSim jobs are finished
while [[ $pueo_flags -lt $peuocount ]]
do
	cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags

	pueo_flags=$(ls | wc -l)
	percent_pueo=$(bc <<< "scale=2; $pueo_flags/$peuocount")

	echo "PUEO flags: $pueo_flags, $percent_pueo %"
	sleep 10
done

echo "PUEO flags: $pueo_flags, $percent_pueo % - All pueoSim jobs finished!"

pueo_finish_time=`date +%s`

cd $WorkingDir/Run_Outputs/$RunName

xf_total_time=$((xf_finish_time - start_time))
pueo_total_time=$((pueo_finish_time - pueosim_start_time))

echo "Total XF time: $xf_total_time seconds" >> time.txt
echo "Total pueoSim time: $pueo_total_time seconds" >> time.txt