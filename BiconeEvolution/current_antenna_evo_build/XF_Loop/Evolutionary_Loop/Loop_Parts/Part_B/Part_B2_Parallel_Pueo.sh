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
Seeds=${16}

start_time=`date +%s`

function printProgressBar () {
	#This function will create a progress bar based
	#on an inputted name and target file count

	cd $WorkingDir/Run_Outputs/$RunName/${1}Flags
	flags=$(find . -type f | wc -l)
	percent=$(bc <<< "scale=2; $flags/$2")
	percent=$(bc <<< "scale=2; $percent*100")
	
	num_bars=$(bc <<< "scale=0; $percent/4")
	num_spaces=$(bc <<< "scale=0; 25-$num_bars")
	GREEN='\033[0;32m'
	NC='\033[0m'

	echo -ne "$1"
	if [ ${#1} -lt 10 ]
	then
		for ((i=0; i<10-${#1}; i++))
		do
			echo -ne " "
		done
	fi
	echo -ne "[${GREEN}"
	for ((i=0; i<$num_bars; i++))
	do
		echo -ne "#"
	done
	echo -ne "${NC}"
	for ((i=0; i<$num_spaces; i++))
	do
		echo -ne "#"
	done
	echo -ne "] - flags: $flags, $percent %"
	echo -ne "\n"
}


cd $WorkingDir
mkdir -m775 ${XFProj}/XF_models_${gen} 2> /dev/null
mkdir -m775 Run_Outputs/${RunName}/Root_Files/${gen}_Root_Files 2> /dev/null
mkdir -m775 Run_Outputs/${RunName}/uan_files/${gen}_uan_files 2> /dev/null
mkdir -m775 ${PSIMDIR}/outputs/${RunName}/${gen}_outputs 2> /dev/null

# We need to count how many XF and pueoSim jobs are finished
# We'll do this by counting the number of files in the GPUFlags and PUEOFlags directory

cd $WorkingDir/Run_Outputs/$RunName/GPUFlags
gpu_flags=$(find . -type f | wc -l)
cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags
pueo_flags=$(find . -type f | wc -l)
cd $WorkingDir/Run_Outputs/$RunName/ROOTFlags
root_flags=$(find . -type f | wc -l)


peuosimsperindiv=49
peuocount=$((peuosimsperindiv * NPOP))
max_jobs=250
job_cutoff=$((max_jobs - peuosimsperindiv))
UJSER=$(whoami)

echo "Waiting for XF and pueoSim jobs..."
echo ""
echo ""
echo ""
echo ""

# We need to wait until all the XF jobs are finished
while [[ $root_flags -lt $NPOP ]]
do
	# if there is an output file in the TMPGPUFlags directory, 
	# submit a pueoSim job for that antenna and then move the file to the GPUFlags directory
	cd $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags
	# if there are no files in the TMPGPUFlags directory, 
	# wait 10 seconds and then check again Or if the number of jobs submitted is greater than 250 - 49
	jobs_submitted=$(squeue -u $USER | wc -l)
	if [[ $(ls | wc -l) -eq 0 || $jobs_submitted -gt $job_cutoff ]]
	then
		sleep 10
	else
		for file in *
		do
			indiv=$(echo "$file" | cut -d'_' -f5)
			# remove the .txt from the end of the file name
			indiv=$(echo "$indiv" | cut -d'.' -f1)
			# submit the pueoSim job
			cd $WorkingDir
			sbatch --array=1-49 --export=ALL,gen=$gen,WorkingDir=$WorkingDir,RunName=$RunName,Seeds=$Seeds,PSIMDIR=$PSIMDIR,NPOP=$NPOP,NNT=$NNT,Exp=$exp,indiv=$indiv --job-name=${RunName} Batch_Jobs/PueoCall_Array_Indiv.sh
			# move the cursor up 1 line
			tput cuu 1
			# move the file to the GPUFlags directory
			cd $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags
			mv $file $WorkingDir/Run_Outputs/$RunName/GPUFlags
		done
	fi
	cd $WorkingDir/Run_Outputs/$RunName/GPUFlags
	gpu_flags=$(ls | wc -l)

	cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags
	pueo_flags=$(find . -type f | wc -l)

	cd $WorkingDir/Run_Outputs/$RunName/ROOTFlags
	root_flags=$(find . -type f | wc -l)

	if [ $gpu_flags -eq $XFCOUNT ]
	then
		xf_finish_time=`date +%s`
		pueosim_start_time=`date +%s`
	fi

	tput cuu 3

	printProgressBar "GPU" $XFCOUNT
	printProgressBar "PUEO" $peuocount
	printProgressBar "ROOT" $NPOP

done

cd $WorkingDir/Run_Outputs/$RunName

xf_total_time=$((xf_finish_time - start_time))
pueo_total_time=$((pueo_finish_time - pueosim_start_time))

echo "Total XF time: $xf_total_time seconds" >> time.txt
echo "Total pueoSim time: $pueo_total_time seconds" >> time.txt
