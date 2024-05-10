#!/bin/bash
###################### Main Bash Script, PUEO ############################################

################## Load Modules ##########################################################
module load python/3.7-2019.10
################## Initialize Run Variables ##############################################
RunName=$1   	## Unique id of the run
setupfile="${2:-setup.sh}"
WorkingDir=$(pwd)
RunDir=$WorkingDir/Run_Outputs/$RunName

mkdir -m777 $WorkingDir/Run_Outputs 2> /dev/null
mkdir -m777 $WorkingDir/saveStates 2> /dev/null

echo "Setup file is ${setupfile}"
############################### SAVE STATE ##############################################
saveStateFile="${RunName}.savestate.txt"

## This is our savestate that allows us to pick back up if we interrupt the loop ##
echo "${saveStateFile}"

if ! [ -f "saveStates/${saveStateFile}" ]; then
    echo "saveState does not exist. Making one and starting new run"
	
	echo "0" > saveStates/${saveStateFile}
	echo "0" >> saveStates/${saveStateFile}
	echo "1" >> saveStates/${saveStateFile}
	chmod -R 777 saveStates/${saveStateFile}

	mkdir -m777 $RunDir

	source $WorkingDir/$setupfile

	cp $WorkingDir/$setupfile $RunDir/setup.sh

	XFProj=$WorkingDir/Run_Outputs/${RunName}/${RunName}.xf
	XmacrosDir=$WorkingDir/XMacros
	RunXMacrosDir=$RunDir/XMacros
	echo "" >> $RunDir/setup.sh
	echo "RunDir=${RunDir}" >> $RunDir/setup.sh
	echo "XFProj=${XFProj}" >> $RunDir/setup.sh
	echo "XmacrosDir=${XmacrosDir}" >> $RunDir/setup.sh
	echo "RunXMacrosDir=${RunXMacrosDir}" >> $RunDir/setup.sh
	
	if [ $SYMMETRY -eq 0 ]
	then
		XFCOUNT=$((NPOP*2))
	else
		XFCOUNT=$NPOP
	fi
	echo "XFCOUNT=${XFCOUNT}" >> $RunDir/setup.sh
else
	source $RunDir/setup.sh
fi

####################  CHECKING GA STATUS  ###############################################

check_exit_status() {
    if [ $? -ne 0 ]; then
        echo "Script Failed, Exiting"
		exit 1
    fi
}

##################### THE LOOP ##########################################################
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
		echo ""
		
		# Initialize the Run Directories
		mkdir -p -m777 $RunDir
		mkdir -m777 $RunDir/Flags
		mkdir -m777 $RunDir/Flags/GPUFlags
		mkdir -m777 $RunDir/Flags/TMPGPUFlags
		mkdir -m775 $RunDir/Flags/ROOTFlags
		mkdir -m777 $RunDir/Flags/PUEOFlags

		mkdir -m777 $RunDir/Errs_And_Outs
		mkdir -m777 $RunDir/Errs_And_Outs/XFGPUOutputs
		mkdir -m777 $RunDir/Errs_And_Outs/PUEO_Outputs
		mkdir -m777 $RunDir/Errs_And_Outs/psimouts
		mkdir -m777 $RunDir/Errs_And_Outs/PUEO_Errors
		mkdir -m775 $RunDir/Errs_And_Outs/XF_Outputs
		mkdir -m775 $RunDir/Errs_And_Outs/XF_Errors
		mkdir -m775 $RunDir/Errs_And_Outs/XFintoPUEOOuts
		if [ $JobPlotting -eq 1 ]
		then
			mkdir -m775 $RunDir/Errs_And_Outs/Plotting_Outputs
			mkdir -m775 $RunDir/Errs_And_Outs/Plotting_Errors
		fi

		mkdir -m777 $RunDir/uan_files
		mkdir -m777 $RunDir/Antenna_Images
		mkdir -m777 $RunDir/Generation_Data
		mkdir -m775 $RunDir/Root_Files
		mkdir -m775 $RunDir/Gain_Files
		mkdir -m775 $RunDir/Plots
		mkdir -m775 $RunDir/Plots/Gain_Plots
		mkdir -m775 $RunDir/XMacros
		touch $RunDir/time.txt
		date > $RunDir/date.txt

		state=1
	fi

	## Part A ##
	if [ $state -eq 1 ]
	then
		echo "Times for generation ${gen}" >> $RunDir/time.txt
		start=$(date +%s)

		./Loop_Parts/Part_A/Part_A.sh $InputVars
		check_exit_status

		state=2
		./Loop_Scripts/SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part A took ${runtime} seconds" >> $RunDir/time.txt
	fi

	## Part B1 ##
	if [ $state -eq 2 ]
	then
		start=$(date +%s)

		./Loop_Parts/Part_B/Part_B1.sh $InputVars $indiv
		
		state=3
		./Loop_Scripts/SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part B1 took ${runtime} seconds" >> $RunDir/time.txt
	fi

	## Part B2 ##
	if [ $state -eq 3 ]
	then
		start=$(date +%s)

		if [ $ParallelXFPUEO -eq 0 ]
		then
			./Loop_Parts/Part_B/Part_B2_Serial.sh $InputVars
		else
			./Loop_Parts/Part_B/Part_B2_Parallel.sh $InputVars
		fi

		state=4

		./Loop_Scripts/SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part B2 took ${runtime} seconds" >> $RunDir/time.txt
	fi

	## Part C ##
	if [ $state -eq 4 ]
	then

		start=$(date +%s)
		indiv=1

		if [ $ParallelXFPUEO -eq 0 ]
		then
			./Loop_Parts/Part_C/Part_C.sh $InputVars
		fi

		state=5
		./Loop_Scripts/SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part C took ${runtime} seconds" >> $RunDir/time.txt
	fi

	## Part D1 ##
	if [ $state -eq 5 ]
	then
		start=$(date +%s)

		if [ $ParallelXFPUEO -eq 0 ]
		then
			./Loop_Parts/Part_D/Part_D1.sh $InputVars
		fi
		state=6

		./Loop_Scripts/SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part D1 took ${runtime} seconds" >> $RunDir/time.txt
	fi

	## Part D2 ##
	if [ $state -eq 6 ]
	then
		start=$(date +%s)
		if [ $ParallelXFPUEO -eq 0 ]
		then
			./Loop_Parts/Part_D/Part_D2.sh $InputVars
		fi
		state=7
		./Loop_Scripts/SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part D2 took ${runtime} seconds" >> $RunDir/time.txt
	fi

	## Part E ##
	if [ $state -eq 7 ]
	then
		start=$(date +%s)

		./Loop_Parts/Part_E/Part_E.sh $InputVars
		check_exit_status

		state=8
		./Loop_Scripts/SaveState_Prototype.sh $gen $state $RunName $indiv 
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part E took ${runtime} seconds" >> $RunDir/time.txt
	fi

	## Part F ##
	if [ $state -eq 8 ]
	then
		start=$(date +%s)

		if [ $JobPlotting -eq 0 ]
		then
			./Loop_Parts/Part_F/Part_F.sh $InputVars
		else
			sbatch --export=ALL,WorkingDir=$WorkingDir,RunName=$RunName,gen=$gen\
				   --job-name=Plotting_${RunName}_${gen}  ./Loop_Parts/Part_F/Part_F_Job.sh
		fi

		state=1
		./Loop_Scripts/SaveState_Prototype.sh $gen $state $RunName $indiv
		end=$(date +%s)
		runtime=$((end-start))
		echo "Part F took ${runtime} seconds" >> $RunDir/time.txt
	fi
	genend=$(date +%s)
	genruntime=$((genend-genstart))
	echo "Generation ${gen} took ${genruntime} seconds" >> $RunDir/time.txt
done

echo "Congrats :)"
