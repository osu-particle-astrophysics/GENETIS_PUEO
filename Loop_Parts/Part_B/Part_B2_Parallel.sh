#!/bin/bash
# Parallel version of Part B for PUEO
# This script will wait for the XF simulations to finish,
# submitting the pueoSim jobs as they finish
# The script waits until all XF and pueoSim jobs are finished

# varaibles
WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/Run_Outputs/$RunName/setup.sh

start_time=$(date +%s)

function printProgressBar () {
	#This function will create a progress bar based
	#on an inputted name and target file count

	cd $RunDir/Flags/${1}Flags
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
	for ((i=0; i<num_bars; i++))
	do
		echo -ne "#"
	done
	echo -ne "${NC}"
	for ((i=0; i<num_spaces; i++))
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

cd $RunDir/Flags/GPUFlags
gpu_flags=$(find . -type f | wc -l)
cd $RunDir/Flags/ROOTFlags
root_flags=$(find . -type f | wc -l)



max_jobs=250
USER=$(whoami)
already_checked=0

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
	# if there are no files in the TMPGPUFlags directory, 
	# wait 10 seconds and then check again or if the number of jobs submitted is greater than 250 - 49

	cd $WorkingDir

	# Count the number of jobs submitted. -f9 is the job ID
	squeue_string=$(squeue -h -u $USER | cut -d' ' -f9)
	jobs_submitted=$(python $WorkingDir/Antenna_Performance_Metric/count_jobs.py "$squeue_string")

	temp_flags=$(find Run_Outputs/$RunName/Flags/TMPGPUFlags/*.txt -type f | wc -l)

	if [[ $temp_flags -eq 0 || $jobs_submitted -gt $max_jobs ]]
	then
		tput cuu 1
		sleep 10
	else
		for file in Run_Outputs/$RunName/Flags/TMPGPUFlags/*.txt
		do	
			echo $file
			filename=$(echo "$file" | cut -d'/' -f5)
			echo $filename
			indiv=$(echo "$filename" | cut -d'_' -f5)
			indiv=$(echo "$indiv" | cut -d'.' -f1)

			indiv_in_pop=$((indiv-1))
			indiv_in_pop=$((indiv_in_pop % NPOP))

			# run the xmacro output script
			cd $WorkingDir/Batch_Jobs
			mkdir -m775 $RunDir/uan_files/${gen}_uan_files/${indiv_in_pop} 2> /dev/null
			./single_XF_output_PUEO.sh $indiv $WorkingDir $RunName $gen 1> "$RunDir/Errs_And_Outs/XFintoPUEOOuts/PUEOsim_${indiv}.output" 2> "$RunDir/Errs_And_Outs/XFintoPUEOOuts/PUEOsim_${indiv}.error"


			cd $WorkingDir

			# Get the NNT and number of jobs from the python script Antenna_Performance_Metric/calculating_NNT.py
			jobs_left=$((NPOP-root_flags))

			echo "jobs submitted: $jobs_submitted"
			echo "jobs left: $jobs_left"
			echo "XFCOUNT: $num_keys"
			echo "NNT: $NNT"
			echo "max_jobs: $max_jobs"
			echo " "
			echo " " 
			echo " " 

			parse=$(python Antenna_Performance_Metric/calculating_NNT.py $jobs_submitted $jobs_left $num_keys $NNT $max_jobs)
			NNT_per_sim=$(echo $parse | cut -d',' -f1)
			num_jobs=$(echo $parse | cut -d',' -f2)

			echo "NNT per sim: $NNT_per_sim"
			echo "num_jobs: $num_jobs"
			echo " "
			echo " "

			# set the output file to Run_Outputs/$RunName/PUEO_Outputs/PUEOsim_$indiv_$SLURM_ARRAY_TASK_ID.output
			sbatch --array=1-$num_jobs \
				--export=ALL,gen=$gen,WorkingDir=$WorkingDir,RunName=$RunName,NNT_per_sim=$NNT_per_sim,indiv=$indiv_in_pop,num_jobs=$num_jobs \
				--job-name=${RunName} --output=$RunDir/Errs_And_Outs/PUEO_Outputs/PUEOsim_${indiv_in_pop}_%a.output  \
				--error=$RunDir/Errs_And_Outs/PUEO_Errors/PUEOsim_${indiv_in_pop}_%a.error $WorkingDir/Batch_Jobs/PueoCall_Array_Indiv.sh
			# move the cursor up 1 line
			tput cuu 1
			# move the file to the GPUFlags directory
			cd $WorkingDir
			mv $file Run_Outputs/$RunName/Flags/GPUFlags
		done
	fi
	cd $RunDir/Flags/GPUFlags
	gpu_flags=$(ls | wc -l)

	cd $RunDir/Flags/ROOTFlags
	root_flags=$(find . -type f | wc -l)

	if [ $gpu_flags -eq $XFCOUNT ]
	then
	    if [ $already_checked -eq 0 ]
	    then
			xf_finish_time=$(date +%s)
			pueosim_start_time=$(date +%s)
			already_checked=1
		fi
	fi

	tput cuu 3

	printProgressBar "GPU" $XFCOUNT
	printProgressBar "ROOT" $NPOP
	echo ""

done

pueo_finish_time=$(date +%s)

echo "Done!"

cd $RunDir

xf_total_time=$((xf_finish_time - start_time))
pueo_total_time=$((pueo_finish_time - pueosim_start_time))

echo "Total XF time: $xf_total_time seconds" >> time.txt
echo "Total pueoSim time: $pueo_total_time seconds" >> time.txt
