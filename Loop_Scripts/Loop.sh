#!/bin/bash
########################################## Main Bash Script, PUEO #########################

################## Load Modules ###########################################################
module load python/3.6-conda5.2

################## Initialize Run Variables ###############################################
RunName=$1   	## Unique id of the run
setupfile="${2:-setup.sh}"
WorkingDir=$(pwd)

mkdir -m777 $WorkingDir/Run_Outputs 2> /dev/null
mkdir -m777 $WorkingDir/saveStates 2> /dev/null

echo "Setup file is ${setupfile}"
############################### SAVE STATE ###############################################
saveStateFile="${RunName}.savestate.txt"

## This is our savestate that allows us to pick back up if we interrupt the loop ##
echo "${saveStateFile}"

if ! [ -f "saveStates/${saveStateFile}" ]; then
    echo "saveState does not exist. Making one and starting new run"
	
	echo "0" > saveStates/${saveStateFile}
	echo "0" >> saveStates/${saveStateFile}
	echo "1" >> saveStates/${saveStateFile}
	chmod -R 777 saveStates/${saveStateFile}

	mkdir -m777 $WorkingDir/Run_Outputs/$RunName

	source $WorkingDir/$setupfile
	cp $WorkingDir/$setupfile $WorkingDir/Run_Outputs/$RunName/setup.sh
	XFProj=$WorkingDir/Run_Outputs/${RunName}/${RunName}.xf
	XmacrosDir=$WorkingDir/XMacros
	echo "" >> $WorkingDir/Run_Outputs/$RunName/setup.sh
	echo "XFProj=${XFProj}" >> $WorkingDir/Run_Outputs/$RunName/setup.sh
	echo "XmacrosDir=${XmacrosDir}" >> $WorkingDir/Run_Outputs/$RunName/setup.sh
	if [ $SYMMETRY -eq 0 ]
	then
		XFCOUNT=$((NPOP*2))
	else
		XFCOUNT=$NPOP
	fi
	echo "XFCOUNT=${XFCOUNT}" >> $WorkingDir/Run_Outputs/$RunName/setup.sh
else
	source $WorkingDir/Run_Outputs/$RunName/setup.sh
fi


####################  CHECKING VARIABLES  ################################

if [ $((REPRODUCTION + CROSSOVER + MUTATION)) -gt $NPOP ]
then
	echo "ERROR: reproduction + crossover + mutation must be less than or equal to NPOP"
	exit 1
fi

if [ $((ROULETTE + TOURNAMENT + RANK)) -gt $NPOP ]
then
	echo "ERROR: roulette + tournament + rank must be less than or equal to NPOP"
	exit 1
fi

if [ $((CROSSOVER % 2)) -ne 0 ]
then
	echo "ERROR: crossover must be even"
	exit 1
fi

##################### THE LOOP ###################################################################################
InitialGen=$(sed '1q;d' saveStates/${saveStateFile})
state=$(sed '2q;d' saveStates/${saveStateFile})
indiv=$(sed '3q;d' saveStates/${saveStateFile})

echo "${InitialGen}"
echo "${state}"
echo "${indiv}"

for gen in $(seq $InitialGen $TotalGens)
do	
	genstart=$(date +%s)
	
	InputVars="$WorkingDir $RunName $gen"

	## This only runs if starting new run ##
	if [[ $gen -eq 0 && $state -eq 0 ]]
	then
	    read -p "Starting generation ${gen} at location ${state}. Press any key to continue... " -n1 -s
		
		# Initialize the Run Directories
		mkdir -p -m777 $WorkingDir/Run_Outputs/$RunName
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/GPUFlags
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/XFGPUOutputs
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/uan_files
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/Gain_Plots
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/Antenna_Images
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/Generation_Data
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/PUEOFlags
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/PUEO_Outputs
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/PUEO_Errors
		mkdir -m775 $WorkingDir/Run_Outputs/$RunName/Root_Files
		mkdir -m775 $WorkingDir/Run_Outputs/$RunName/ROOTFlags
		mkdir -m775 $PSIMDIR/outputs/${RunName}
		touch $WorkingDir/Run_Outputs/$RunName/time.txt
		date > $WorkingDir/Run_Outputs/$RunName/date.txt

		state=1
	fi


	## Part A ##
	##Here, we are running the genetic algorithm and moving the outputs to csv files 
	if [ $state -eq 1 ]
	then
		echo "Times for generation ${gen}" >> $WorkingDir/Run_Outputs/$RunName/time.txt
		start=$(date +%s)

		./Loop_Parts/Part_A/Part_A_PUEO.sh $InputVars

		state=2
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part A took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi


	## Part B1 ##
	if [ $state -eq 2 ]
	then
		start=$(date +%s)

		./Loop_Parts/Part_B/Part_B_PUEO.sh $InputVars
		
		state=3
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part B1 took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi
		

	## Part B2 ##
	if [ $state -eq 3 ]
	then
		start=$(date +%s)

		if [ $ParallelXFPUEO -eq 0 ]
		then
			./Loop_Parts/Part_B/Part_B_job2_PUEO.sh $InputVars
		else
			./Loop_Parts/Part_B/Part_B2_Parallel_Pueo.sh $InputVars
		fi

		state=4

		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part B2 took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part C ##
	if [ $state -eq 4 ]
	then

		start=$(date +%s)
		indiv=1

		if [ $ParallelXFPUEO -eq 0 ]
		then
			./Loop_Parts/Part_C/Part_C_PUEO.sh $InputVars
		fi

		state=5
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part C took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part D1 ##
	if [ $state -eq 5 ]
	then
		start=$(date +%s)

		if [ $ParallelXFPUEO -eq 0]
		then
			./Loop_Parts/Part_D/Part_D1_PUEO.sh $InputVars
		fi
		state=6

		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part D1 took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part D2 ##
	if [ $state -eq 6 ]
	then
		start=$(date +%s)
		if [ $ParallelXFPUEO -eq 0]
		then
			./Loop_Parts/Part_D/Part_D2_PUEO.sh $InputVars
		fi
		state=7
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end==$(date +%s)
		runtime=$((end-start))
		echo "Part D2 took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part E ##
	## Concatenates the AraSim data files into a string so that it's usable for getting scores
	## Gets important information on the fitness scores and generation DNA
	## moves the .uan files from Antenna Performance Metric to RunOutputs/$RunName folder
	if [ $state -eq 7 ]
	then
		start=$(date +%s)

		./Loop_Parts/Part_E/Part_E_PUEO.sh $InputVars

		state=8
		./SaveState_Prototype.sh $gen $state $RunName $indiv 
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part E took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part F ##
	if [ $state -eq 8 ]
	then
		start=$(date +%s)

		if [ $JobPlotting -eq 0 ]
		then
			./Loop_Parts/Part_F/Part_F_PUEO.sh $InputVars
		else
			sbatch --export=ALL,WorkingDir=$WorkingDir,RunName=$RunName,gen=$gen --job-name=Plotting_${RunName}_${gen}  ./Loop_Parts/Part_F/Part_F_PUEO.sh
		fi

		state=1
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part F took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi
	genend=$(date +%s)
	genruntime=$((genend-genstart))
	echo "Generation ${gen} took ${genruntime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
done

echo "Congrats :)"
