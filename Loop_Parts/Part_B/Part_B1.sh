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
#	2. Prepares simulation_PEC.xmacro with information such as:
#			I. Each generation antenna parameters
#
#	3. Runs XF and loads XF with both xmacros.
#
###########################################################################
# variables
WorkingDir=$1
RunName=$2
gen=$3
indiv=$4
source $WorkingDir/RunData/$RunName/setup.sh

## If we're in the 0th generation, we need to make the directory for the XF jobs
if [ ${gen} -eq 0 ]
then
	mkdir -m775 $WorkingDir/Run_Outputs/$RunName/XF_Outputs
	mkdir -m775 $WorkingDir/Run_Outputs/$RunName/XF_Errors
fi

# we need to check if directories we're going to write to already exist
# this would occur if already ran this part but went back to rerun the same generation
# the directories are the simulation directories from gen*NPOP+1 to gen*NPOP+10
# Note that for PUEO, we need TWO XF simulation per individual
# This is because we need to do the VPol and Hpol
for i in $(seq 1 $XFCOUNT)
do
    # first, declare the number of the individual we are checking
	individual_number=$(($gen*$XFCOUNT + $i))

	indiv_dir_parent=$XFProj/Simulations/$(printf "%05d" $individual_number)


        # now delete the directory if it exists
	if [ -d $indiv_dir_parent ]
	then
		rm -rf $indiv_dir_parent
	fi

done

# the number of the next simulation directory is held in a hidden file in the Simulations directory 
# the file is names .nextSimulationNumber

if [[ $gen -ne 0 ]]
then
	echo $(($gen*$XFCOUNT + 1)) > $XFProj/Simulations/.nextSimulationNumber
fi


chmod -R 777 $XmacrosDir 2> /dev/null

cd $XmacrosDir

#get rid of the simulation_PEC.xmacro that already exists
rm -f simulation_PEC.xmacro

echo "var NPOP = $NPOP;" > simulation_PEC.xmacro
echo "var indiv = $indiv;" >> simulation_PEC.xmacro
echo "var workingdir = \"$WorkingDir\";" >> simulation_PEC.xmacro
echo "var RunName = \"$RunName\";" >> simulation_PEC.xmacro
echo "var freq_start = $FreqStart;" >> simulation_PEC.xmacro
echo "var freq_step = $FreqStep;" >> simulation_PEC.xmacro
echo "var freq_count = $FREQS;" >> simulation_PEC.xmacro
# bit flip SYMMETRY
if [ $SYMMETRY -eq 1 ]
then
	sym_count=0
else
	sym_count=1
fi
echo "var sym_count = $sym_count;" >> simulation_PEC.xmacro
chmod -R 775 simulation_PEC.xmacro 2> /dev/null

echo "//Factor of $GeoFactor frequency" >> simulation_PEC.xmacro

if [[ $gen -eq 0 && $indiv -eq 1 ]]
then
	echo "if(indiv==1){" >> simulation_PEC.xmacro
	echo "App.saveCurrentProjectAs(\"$WorkingDir/Run_Outputs/$RunName/$RunName\");" >> simulation_PEC.xmacro
	echo "}" >> simulation_PEC.xmacro
fi

#we cat things into the simulation_PEC.xmacro file, so we can just echo the list to it before catting other files

#cat PUEO_skeleton_trapezoids.txt >> simulation_PEC.xmacro
# Would like to just be able to import to XF with a command in the xmacros
# And then I only need to cat in a handful of scripts into simulation_PEC.xmacro
# According Walter Janusz at Remcom, this isn't possible yet. So we'll just have to 
# 	concatenate everything into a fil ourselves

cat headerPUEO.xmacro >> simulation_PEC.xmacro
cat functionCallsPUEO.xmacro >> simulation_PEC.xmacro
cat buildWalls.xmacro >> simulation_PEC.xmacro
cat buildRidges.xmacro >> simulation_PEC.xmacro
cat buildWaveguide.xmacro >> simulation_PEC.xmacro
cat extend_ridges_trapezoid.xmacro >> simulation_PEC.xmacro
cat CreatePEC.xmacro >> simulation_PEC.xmacro
cat CreateAntennaSource.xmacro >> simulation_PEC.xmacro
cat CreateGrid.xmacro >> simulation_PEC.xmacro
cat CreateSensors.xmacro >> simulation_PEC.xmacro
cat CreateAntennaSimulationData.xmacro >> simulation_PEC.xmacro
cat QueueSimulation.xmacro >> simulation_PEC.xmacro
cat MakeImage.xmacro >> simulation_PEC.xmacro

# Replace the number of times we simulate based on the symmetry
# Annoying because we need to count to the the opposite of $SYMMETRY
if [ $SYMMETRY -eq 1 ]
then
	vim -c ':%s/SYMMETRY/0' + -c ':wq!' simulation_PEC.xmacro
else
	vim -c ':%s/SYMMETRY/1' + -c ':wq!' simulation_PEC.xmacro
fi


#we need to change the gridsize by the same factor as the antenna size
#the gridsize in the macro skeleton is currently set to 0.1
#we want to make it scale in line with our scalefactor

initial_gridsize=0.1
new_gridsize=$(bc <<< "scale=6; $initial_gridsize/$GeoFactor")
sed -i "s/var gridSize = 0.1;/var gridSize = $new_gridsize;/" simulation_PEC.xmacro

sed -i "s+fileDirectory+${WorkingDir}/Generation_Data+" simulation_PEC.xmacro
#the above sed command substitute for hardcoded words and don't use a dummy file
#that's ok, since we're doing this after the simulation_PEC.xmacro file has been written; it gets deleted and rewritten from the macroskeletons, so it's ok for us to make changes this way here (as opposed to the way we do it for arasim in parts D1 and D2)

if [[ $gen -ne 0 && $i -eq 1 ]]
then
	cd $XFProj
	rm -rf Simulations
fi

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

cd $WorkingDir

if [ $XFCOUNT -lt $num_keys ]
then
	batch_size=$XFCOUNT
else
	batch_size=$num_keys
fi

## We'll make the run name the job name
## This way, we can use it in the SBATCH commands
#I think this should work for PUEO too

job_file=$WorkingDir/Batch_Jobs/GPU_XF_Job.sh
if [ $ParallelXFPUEO -eq 1 ]
then
	job_file=$WorkingDir/Batch_Jobs/GPU_XF_Job_Parallel.sh
	cd $WorkingDir/Run_Outputs/$RunName
	rm GPUFlags/* 2> /dev/null
	# remove pueo flags recursively
	rm -Rf PUEOFlags/* 2> /dev/null
	rm ROOTFlags/* 2> /dev/null
	cd $WorkingDir
fi

# make sure there are no stray jobs from previous runs
scancel -n ${RunName}

if [ $SingleBatch -eq 1 ]
then
	XFCOUNT=$batch_size
	# set the job time limit to 15 hours
	job_time="15:00:00"
else
	job_time="04:00:00"
fi

mkdir -m775 $WorkingDir/Run_Outputs/$RunName/Antenna_Images/${gen}

echo "Submitting XF jobs with batch size $batch_size"
sbatch --array=1-${XFCOUNT}%${batch_size} --export=ALL,WorkingDir=$WorkingDir,RunName=$RunName,indiv=$individual_number,gen=${gen},SYMMETRY=$SYMMETRY,PSIMDIR=$PSIMDIR,batch_size=$batch_size,SingleBatch=$SingleBatch --job-name=${RunName} --time=${job_time} $job_file 
