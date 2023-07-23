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

cd $WorkingDir
mkdir -m775 ${XFProj}/XF_models_${gen}
mkdir -m775 Run_Outputs/${RunName}/Root_Files/${gen}_Root_Files
mkdir -m775 Run_Outputs/${RunName}/uan_files/${gen}_uan_files
mkdir -m775 ${PSIMDIR}/outputs/${RunName}/${gen}_outputs

# We need to count how many XF and pueoSim jobs are finished
# We'll do this by counting the number of files in the GPUFlags and PUEOFlags directory

cd $WorkingDir/Run_Outputs/$RunName/GPUFlags
gpu_flags=$(ls | wc -l)
cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags
pueo_flags=$(ls | wc -l)

peuosimsperindiv=49
peuocount=$((NPOP * pueosimsperindiv))

# We need to wait until all the XF jobs are finished
while [[ $gpu_flags -lt $XFCOUNT ]]
do
	# if there is an output file in the TMPGPUFlags directory, submit a pueoSim job for that antenna and then move the file to the GPUFlags directory
	cd $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags
	for file in *
		indiv=$(echo $file | cut -d'_' -f5)
		# submit the pueoSim job
		sbatch --array=1-$pueosimsperindiv --export=ALL,gen=$gen,WorkingDir=$WorkingDir,RunName=$RunName,Seeds=$Seeds,PSIMDIR=$PSIMDIR,NPOP=$NPOP,NNT=$NNT,Exp=$exp,indiv=$indiv --job-name=${RunName} Batch_Jobs/PueoCall_Array_Indiv.sh
		# move the file to the GPUFlags directory
		mv $file $WorkingDir/Run_Outputs/$RunName/GPUFlags
	done
	cd $WorkingDir/Run_Outputs/$RunName/GPUFlags
	gpu_flags=$(ls | wc -l)

	cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags
	pueo_flags=$(ls | wc -l)

	percent_gpu=$(bc <<< "scale=2; $gpu_flags/$XFCOUNT")
	percent_pueo=$(bc <<< "scale=2; $pueo_flags/$peuocount")

	echo "XF flags: $gpu_flags , $percent_gpu %"
	echo "PUEO flags: $pueo_flags, $percent_pueo %"
	sleep 10
done

echo "XF flags: $gpu_flags , $percent_gpu % - All XF jobs finished!"

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