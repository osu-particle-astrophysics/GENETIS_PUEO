#!/bin/bash

########### XF Simulation Software #######################################
#
#      This script will:
#
#      1. Prepare output.xmacro with genetic parameters such as:
#      		I. Antenna Type
#			II. Population number
#			II. Grid size
#
#	  2. Prepares simulation_PEC.xmacro with information such as:
#			I. Each generation antenna parameters
#
#	  3. Runs XF and loads XF with both xmacros.
#
###########################################################################
# variables
WorkingDir=$1
RunName=$2
gen=$3
indiv=$4
source $WorkingDir/Run_Outputs/$RunName/setup.sh

# Create directories if not already created
if [ ${gen} -eq 0 ]
then
	mkdir -m775 $WorkingDir/Run_Outputs/$RunName/XF_Outputs
	mkdir -m775 $WorkingDir/Run_Outputs/$RunName/XF_Errors
fi

# Delete Simulation directories if they exist
for i in $(seq 1 $XFCOUNT)
do
	individual_number=$(($gen*$XFCOUNT + $i))
	indiv_dir_parent=$XFProj/Simulations/$(printf "%05d" $individual_number)

	if [ -d $indiv_dir_parent ]
	then
		rm -rf $indiv_dir_parent
	fi

done

# store the next simulation number in the hidden file
if [[ $gen -ne 0 ]]
then
	echo $(($gen*$XFCOUNT + 1)) > $XFProj/Simulations/.nextSimulationNumber
fi

chmod -R 777 $XmacrosDir 2> /dev/null

cd $XmacrosDir

#get rid of the simulation_PEC.xmacro that already exists
rm -f simulation_PEC.xmacro


# Create the simulation_PEC.xmacro
echo "var NPOP = $NPOP;" > simulation_PEC.xmacro
echo "var indiv = $indiv;" >> simulation_PEC.xmacro
echo "var workingdir = \"$WorkingDir\";" >> simulation_PEC.xmacro
echo "var RunName = \"$RunName\";" >> simulation_PEC.xmacro
echo "var freq_start = $FreqStart;" >> simulation_PEC.xmacro
echo "var freq_step = $FreqStep;" >> simulation_PEC.xmacro
echo "var freq_count = $FREQS;" >> simulation_PEC.xmacro

# bit flip SYMMETRY to get symmetry count
sym_count=$(((SYMMETRY-1)*-1))
echo "var sym_count = $sym_count;" >> simulation_PEC.xmacro
chmod -R 775 simulation_PEC.xmacro 2> /dev/null

echo "//Factor of $GeoFactor frequency" >> simulation_PEC.xmacro

if [[ $gen -eq 0 && $indiv -eq 1 ]]
then
	echo "if(indiv==1){" >> simulation_PEC.xmacro
	echo "App.saveCurrentProjectAs(\"$WorkingDir/Run_Outputs/$RunName/$RunName\");" >> simulation_PEC.xmacro
	echo "}" >> simulation_PEC.xmacro
fi

cat headerPUEO.js >> simulation_PEC.xmacro
cat functionCallsPUEO.js >> simulation_PEC.xmacro
cat buildWalls.js >> simulation_PEC.xmacro
cat buildRidges.js >> simulation_PEC.xmacro
cat buildWaveguide.js >> simulation_PEC.xmacro
cat extend_ridges_trapezoid.js >> simulation_PEC.xmacro
cat CreatePEC.js >> simulation_PEC.xmacro
cat CreateAntennaSource.js >> simulation_PEC.xmacro
cat CreateGrid.js >> simulation_PEC.xmacro
cat CreateSensors.js >> simulation_PEC.xmacro
cat CreateAntennaSimulationData.js >> simulation_PEC.xmacro
cat QueueSimulation.js >> simulation_PEC.xmacro
cat MakeImage.js >> simulation_PEC.xmacro


# Remove the extra simulations
if [[ $gen -ne 0 && $i -eq 1 ]]
then
	cd $XFProj
	rm -rf Simulations
fi


# Run XF simulation PEC
echo
echo
echo 'Opening XF user interface...'
echo '*** Please remember to save the project with the same name as RunName! ***'
echo
echo '1. Import and run simulation_PEC.xmacro'
echo '2. Import and run output.xmacro'
echo '3. Close XF'

module load xfdtd/7.10.2.3

xfdtd $XFProj --execute-macro-script=$XmacrosDir/simulation_PEC.xmacro || true

chmod -R 775 $WorkingDir/../Xmacros 2> /dev/null


# Submit the Batch XF Job to solve the simulations
cd $WorkingDir

if [ $XFCOUNT -lt $num_keys ]
then
	batch_size=$XFCOUNT
else
	batch_size=$num_keys
fi

## We'll make the run name the job name
## This way, we can use it in the SBATCH commands

job_file=$WorkingDir/Batch_Jobs/GPU_XF_Job.sh
if [ $ParallelXFPUEO -eq 1 ]
then
	job_file=$WorkingDir/Batch_Jobs/GPU_XF_Job_Parallel.sh
	cd $WorkingDir/Run_Outputs/$RunName
	rm GPUFlags/* 2> /dev/null
	rm -Rf PUEOFlags/* 2> /dev/null
	rm ROOTFlags/* 2> /dev/null
	cd $WorkingDir
fi

# make sure there are no stray jobs from previous runs
scancel -n ${RunName}

# Numbers through testing
if [ $SingleBatch -eq 1 ]
then
	XFCOUNT=$batch_size
	job_time="15:00:00"
else
	job_time="02:00:00"
fi
	
mkdir -m775 $WorkingDir/Run_Outputs/$RunName/Antenna_Images/${gen}

echo "Submitting XF jobs with batch size $batch_size"
sbatch --array=1-${XFCOUNT}%${batch_size} \
	   --export=ALL,WorkingDir=$WorkingDir,RunName=$RunName,indiv=$individual_number,gen=${gen},batch_size=$batch_size \
	   --job-name=${RunName} --time=${job_time} $job_file 
