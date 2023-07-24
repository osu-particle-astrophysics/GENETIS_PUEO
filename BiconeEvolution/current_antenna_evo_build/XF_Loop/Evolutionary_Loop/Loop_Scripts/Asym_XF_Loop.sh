#!/bin/bash
#This is a functionized version of the loop using savestates that also has seeded versions of AraSim
#Evolutionary loop for antennas.
#Last update: Nov 18, 2021 by Julie R. 
#OSU GENETIS Team
#SBATCH -e /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loops/Evolutionary_Loop/scriptEOFiles
#SBATCH -o /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loops/Evolutionary_Loop/scriptEOFiles

###########################################################################################################################################
#### THIS COPY SUBMITS XF SIMS AS A JOB AND REQUESTS A GPU FOR THE JOB ####
# This loop contains 8 different parts. 
# Each part is its own function and is contained in its own bash script(Part_A to Part_F, with there being 2 part_D scripts and 2 part_B scripts). 
# When the loop is finished running through, it will restart for a set number of generations. 
# The code is optimised for a dynamic choice of NPOP UP TO fitnessFunction.exe. From there on, it has not been checked.
################################################################################################################################################


#make sure we're using python3
module load python/3.6-conda5.2

####### VARIABLES: LINES TO CHECK OVER WHEN STARTING A NEW RUN ###############################################################################################
RunName='2023_07_24_test1'	## This is the name of the run. You need to make a unique name each time you run.
TotalGens=100			## number of generations (after initial) to run through
NPOP=10			## number of individuals per generation; please keep this value below 99
Seeds=1			## This is how many AraSim jobs will run for each individual## the number frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)
FREQ=60				## the number frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)
NNT=2000			## Number of Neutrinos Thrown in AraSim   
exp=19				## exponent of the energy for the neutrinos in AraSim
ScaleFactor=1.0			## ScaleFactor used when punishing fitness scores of antennae larger than the drilling holes
GeoFactor=1			## This is the number by which we are scaling DOWN our antennas. This is passed to many files
num_keys=4			## how many XF keys we are letting this run use
database_flag=0			## 0 if not using the database, 1 if using the database
				## These next 3 define the symmetry of the cones.
PUEO=1				## IF 1, we evolve the PUEO quad-ridged horn antenna, if 0, we evolve the Bicone
SYMMETRY=1		## IF 1, then PUEO antenna is square symmetric and only simulate each antenna once
RADIUS=1			## If 1, radius is asymmetric. If 0, radius is symmetric		
LENGTH=1			## If 1, length is asymmetric. If 0, length is symmetric
ANGLE=1				## If 1, angle is asymmetric. If 0, angle is symmetric
CURVED=1			## If 1, evolve curved sides. If 0, sides are straight
A=1				## If 1, A is asymmetric
B=1				## If 1, B is asymmetric
SEPARATION=0    		## If 1, separation evolves. If 0, separation is constant
NSECTIONS=2 			## The number of chromosomes
DEBUG_MODE=0			## 1 for testing (ex: send specific seeds), 0 for real runs
				## These next variables are the values passed to the GA
REPRODUCTION=1			## Number (not fraction!) of individuals formed through reproduction
CROSSOVER=8 #84			## Number (not fraction!) of individuals formed through crossover
MUTATION=1 #16 #1		## Number (not fraction!) of individuals formed through crossover	
SIGMA=5 #5				## Standard deviation for the mutation operation (divided by 100)
ROULETTE=1 #20			## Number (not fraction!) of individuals formed through crossover
TOURNAMENT=1 #20		## Number (not fraction!) of individuals formed through crossover
RANK=8 #60				## Number (not fraction!) of individuals formed through crossover
ELITE=0				## Elite function on/off (1/0)

JobPlotting=0        ## 1 to submit a job to plot the fitness scores, 0 to not submit a job to plot the fitness scores
ParallelXFPUEO=1	## 1 to run pueosim for each antenna as the XF jobs finish, 0 to not
#####################################################################################################################################################

######## Check For Errors in Variables ################################################################################################################


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

########  INITIALIZATION OF DIRECTORIES  ###############################################################################################################
#BEOSC=/users/PAS1960/dylanwells1629/developing/PUEO2/
BEOSC=/fs/ess/PAS1960/HornEvolutionTestingOSC/GENETIS_PUEO/
#BEOSC=/fs/ess/PAS1960/HornEvolutionOSC/GENETIS_PUEO/
WorkingDir=`pwd` ## this is where the loop is; on OSC this is /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build_XF_Loop/Evolutionary_Loop
echo $WorkingDir
XmacrosDir=$WorkingDir/../Xmacros 
XFProj=$WorkingDir/Run_Outputs/${RunName}/${RunName}.xf  ## Provide path to the project directory in the 'single quotes'
echo $XFProj
#AraSimExec="/fs/ess/PAS1960/BiconeEvolutionOSC/AraSim"  ##Location of AraSim.exe
AraSimExec="${WorkingDir}/../../../../AraSim"
#$BEOSC/AraSim ## Location of AraSim directory
#PSIMDIR="/fs/ess/PAS1960/buildingPueoSim" 
PSIMDIR="/users/PAS1960/dylanwells1629/buildingPueoSim"
##Source araenv.sh for AraSim libraries##
#source /fs/ess/PAS1960/BiconeEvolutionOSC/araenv.sh
if [ $PUEO -eq 1 ]
then
	source ${PSIMDIR}/set_env.sh	
	if [ $SYMMETRY -eq 0 ]
	then
		XFCOUNT=$((NPOP*2))
	else
		XFCOUNT=$NPOP
	fi
	echo "XF jobs: " $XFCOUNT
else
	source $WorkingDir/../../../../araenv.sh
	source /fs/ess/PAS1960/BiconeEvolutionOSC/new_root/new_root_setup.sh
	source /cvmfs/ara.opensciencegrid.org/trunk/centos7/setup.sh
fi
module load python/3.6-conda5.2
#####################################################################################################################################################




######## SAVE STATE #################################################################################################################################
##Check if saveState exists and if not then create one at 0,0
saveStateFile="${RunName}.savestate.txt"

## This is our savestate that allows us to pick back up if we interrupt the loop ##
echo "${saveStateFile}"
cd saveStates
if ! [ -f "${saveStateFile}" ]; then
    echo "saveState does not exist. Making one and starting new run"
	
    echo 0 > $RunName.savestate.txt
    echo 0 >> $RunName.savestate.txt
    echo 1 >> $RunName.savestate.txt
fi
cd ..

## Read current state of loop ##
line=1
InititalGen=0
state=0
indiv=0
while read p; do
	if [ $line -eq 1 ]
	then
		InitialGen=$p 

	fi
	
	if [ $line -eq 2 ]
	then
		state=$p
	        
	fi
	
	if [ $line -eq 3 ]
	then
	        indiv=$p
		
	fi
	
	if [ $line -eq 2 ]
	then
		line=3

	fi

	if [ $line -eq 1 ]
	then
		line=2

	fi

       	
done <saveStates/$saveStateFile ## this outputs to the state of the loop to the savestate file
###########################################################################################################################################


##################### THE LOOP ###########################################################################################################
echo "${InitialGen}"
echo "${state}"
echo "${indiv}"
#state=`echo ${state} | bc`
#InitialGen=${gen}

for gen in `seq $InitialGen $TotalGens`
do	
	genstart=`date +%s`
	#read -p "Starting generation ${gen} at location ${state}. Press any key to continue... " -n1 -s
	

	## This only runs if starting new run ##
	if [[ $gen -eq 0 && $state -eq 0 ]]
	then
	        read -p "Starting generation ${gen} at location ${state}. Press any key to continue... " -n1 -s
		# Make the run name directory
		mkdir -p -m777 $WorkingDir/Run_Outputs/$RunName
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/AraSimFlags
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/AraSimConfirmed
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/GPUFlags
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/XFGPUOutputs
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/uan_files
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/Gain_Plots
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/Antenna_Images
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/AraOut
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/Generation_Data
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/PUEOFlags
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/PUEO_Outputs
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/PUEO_Errors
		mkdir -m775 $WorkingDir/Run_Outputs/$RunName/Root_Files
		mkdir -m775 $WorkingDir/Run_Outputs/$RunName/ROOTFlags
		mkdir -m775 $PSIMDIR/outputs/${RunName}
		touch $WorkingDir/Run_Outputs/$RunName/time.txt

		head -n 53 Loop_Scripts/Asym_XF_Loop.sh | tail -n 33 > $WorkingDir/Run_Outputs/$RunName/run_details.txt
		# Create the run's date and save it in the run's directory
		python Data_Generators/dateMaker.py
		mv "runDate.txt" "$WorkingDir/Run_Outputs/$RunName/" -f
		state=1
	fi


	## Part A ##
	##Here, we are running the genetic algorithm and moving the outputs to csv files 
	if [ $state -eq 1 ]
	then
		echo "Times for generation ${gen}" >> $WorkingDir/Run_Outputs/$RunName/time.txt
		start=`date +%s`
		if [ $PUEO -eq 0 ]
		then
			if [ $CURVED -eq 0 ] #Evolve straight sides
			then
				./Loop_Parts/Part_A/Part_A_With_Switches.sh $gen $NPOP $NSECTIONS $WorkingDir $RunName $GeoFactor $RADIUS $LENGTH $ANGLE $SEPARATION $NSECTIONS
			else #Evolve curved sides
				./Loop_Parts/Part_A/Part_A_Curved.sh $gen $NPOP $NSECTIONS $WorkingDir $RunName $GeoFactor $RADIUS $LENGTH $A $B $SEPARATION $NSECTIONS $REPRODUCTION $CROSSOVER $MUTATION $SIGMA $ROULETTE $TOURNAMENT $RANK $ELITE
			fi
		else
			./Loop_Parts/Part_A/Part_A_PUEO.sh $gen $NPOP $WorkingDir $RunName $GeoFactor $RANK $ROULETTE $TOURNAMENT $REPRODUCTION $CROSSOVER $MUTATION $SIGMA
		fi
		state=2
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=`date +%s`
		runtime=$((end-start))
		echo "Part A took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi


	## Part B1 ##
	if [ $state -eq 2 ]
	then
		start=`date +%s`
		if [ $PUEO -eq 1 ]
		then
			./Loop_Parts/Part_B/Part_B_PUEO.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys $SYMMETRY $XFCOUNT $ParallelXFPUEO
		else
			if [ $CURVED -eq 0 ]
			then
				if [ $NSECTIONS -eq 1 ]
				then
					if [ $database_flag -eq 0 ]
					then
						./Loop_Parts/Part_B/Part_B_GPU_job1.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys

					else
						./Loop_Parts/Part_B/Part_B_GPU_job1_database.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys

					fi

				else
					if [ $database_flag -eq 0 ]
					then
						./Loop_Parts/Part_B/Part_B_job1_sep.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys 
					else
						./Loop_Parts/Part_B/Part_B_GPU_job1_asym_database.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys

					fi
				fi
			else
				./Loop_Parts/Part_B/Part_B_Curved_1.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys
				#./Loop_Parts/Part_B/Part_B_Curved_Constant_Quadratic_1.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys
			fi
		fi
		state=3
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=`date +%s`
		runtime=$((end-start))
		echo "Part B1 took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi
		

	## Part B2 ##
	if [ $state -eq 3 ]
	then
		start=`date +%s`
		if [ $PUEO -eq 1 ]
		then
			if [ $ParallelXFPUEO -eq 0 ]
			then
				./Loop_Parts/Part_B/Part_B_job2_PUEO.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys $NSECTIONS $XFCOUNT
			else
				./Loop_Parts/Part_B/Part_B2_Parallel_Pueo.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys $NSECTIONS $XFCOUNT $PSIMDIR $SYMMETRY $exp $NNT $Seeds
			fi
		else
			if [ $database_flag -eq 0 ]
			then
			#./Loop_Parts/Part_B/Part_B_GPU_job2_asym.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys $NSECTIONS
			./Loop_Parts/Part_B/Part_B_GPU_job2_asym_array.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys $NSECTIONS
			else
			./Loop_Parts/Part_B/Part_B_GPU_job2_asym_database.sh $indiv $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $GeoFactor $num_keys $NSECTIONS
			fi
		fi
		state=4

		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=`date +%s`
		runtime=$((end-start))
		echo "Part B2 took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part C ##
	if [ $state -eq 4 ]
	then
		start=`date +%s`
		indiv=1
		if [ $PUEO -eq 0 ]
		then
			./Loop_Parts/Part_C/Part_C.sh $NPOP $WorkingDir $RunName $gen $indiv
		else
			if [ $ParallelXFPUEO -eq 0 ]
			then
				./Loop_Parts/Part_C/Part_C_PUEO.sh $NPOP $WorkingDir $RunName $gen $indiv $SYMMETRY $PSIMDIR
			fi
		fi
		state=5
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=`date +%s`
		runtime=$((end-start))
		echo "Part C took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part D1 ##
	if [ $state -eq 5 ]
	then
		start=`date +%s`
	        #The reason here why Part_D1.sh is run after the save state is changed is because all Part_D1 does is submit AraSim jobs which are their own jobs and run on their own time
		#We need to make a new AraSim job script which takes the runname as a flag 
		#./Loop_Parts/Part_D/Part_D1_AraSeed.sh $gen $NPOP $WorkingDir $AraSimExec $exp $NNT $RunName $Seeds $DEBUG_MODE
		#./Loop_Parts/Part_D/Part_D1_AraSeed_Notif.sh 
		if [ $PUEO -eq 0 ]
		then
			./Loop_Parts/Part_D/Part_D1_Array.sh $gen $NPOP $WorkingDir $AraSimExec $exp $NNT $RunName $Seeds $DEBUG_MODE
		else
			if [ $ParallelXFPUEO -eq 0 ]
			then
				./Loop_Parts/Part_D/Part_D1_PUEO.sh $gen $NPOP $WorkingDir $PSIMDIR $exp $NNT $RunName $Seeds $DEBUG_MODE $XFProj $XFCOUNT
			fi
		fi
		state=6

		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=`date +%s`
		runtime=$((end-start))
		echo "Part D1 took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part D2 ##
	if [ $state -eq 6 ]
	then
		start=`date +%s`
		#./Part_D2_AraSeed.sh 
		if [ $PUEO -eq 0 ]
		then
			./Loop_Parts/Part_D/Part_D2_Array.sh $gen $NPOP $WorkingDir $RunName $Seeds $AraSimExec
			#./Loop_Parts/Part_D/Part_D2_AraSeed_Notif.sh $gen $NPOP $WorkingDir $RunName $Seeds $AraSimExec
		else
			if [ $ParallelXFPUEO -eq 0 ]
			then
				./Loop_Parts/Part_D/Part_D2_PUEO.sh $gen $NPOP $WorkingDir $RunName $Seeds $PSIMDIR
			fi
		fi
		state=7
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=`date +%s`
		runtime=$((end-start))
		echo "Part D2 took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part E ##
	## Concatenates the AraSim data files into a string so that it's usable for getting scores
	## Gets important information on the fitness scores and generation DNA
	## moves the .uan files from Antenna Performance Metric to RunOutputs/$RunName folder
	if [ $state -eq 7 ]
	then
		start=`date +%s`
		if [ $PUEO -eq 0 ]
		then
			if [ $CURVED -eq 0 ]	# Evolve straight sides
			then
				./Loop_Parts/Part_E/Part_E_Asym.sh $gen $NPOP $WorkingDir $RunName $ScaleFactor $indiv $Seeds $GeoFactor $AraSimExec $XFProj $NSECTIONS $SEPARATION
			else			# Evolv curved sides
				./Loop_Parts/Part_E/Part_E_Curved.sh $gen $NPOP $WorkingDir $RunName $ScaleFactor $indiv $Seeds $GeoFactor $AraSimExec $XFProj $NSECTIONS $SEPARATION $CURVED
			fi
		else
			./Loop_Parts/Part_E/Part_E_PUEO.sh $gen $NPOP $WorkingDir $RunName $ScaleFactor $indiv $Seeds $GeoFactor $PSIMDIR $XFProj $PSIMDIR $exp $ParallelXFPUEO
		fi
		state=8
		./SaveState_Prototype.sh $gen $state $RunName $indiv 
		end=`date +%s`
		runtime=$((end-start))
		echo "Part E took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi

	## Part F ##
	if [ $state -eq 8 ]
	then
		start=`date +%s`
		if [ $PUEO -eq 0 ]
		then
			if [ $CURVED -eq 0 ]
			then
				./Loop_Parts/Part_F/Part_F_asym.sh $NPOP $WorkingDir $RunName $gen $Seeds $NSECTIONS
			else
				./Loop_Parts/Part_F/Part_F_Curved.sh $NPOP $WorkingDir $RunName $gen $Seeds $NSECTIONS
			fi
		else
			if [ $JobPlotting -eq 0 ]
			then
				./Loop_Parts/Part_F/Part_F_PUEO.sh $NPOP $WorkingDir $RunName $gen $Seeds $exp $ScaleFactor $PSIMDIR $SYMMETRY
			else
				sbatch --export=ALL,NPOP=$NPOP,WorkingDir=$WorkingDir,RunName=$RunName,gen=$gen,Seeds=$Seeds,exp=$exp,GeoFactor=$ScaleFactor,PSIMDIR=$PSIMDIR,SYMMETRY=$SYMMETRY --job-name=Plotting_${RunName}_${gen}  ./Loop_Parts/Part_F/Part_F_PUEO.sh
			fi
		fi
		state=1
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		end=`date +%s`
		runtime=$((end-start))
		echo "Part F took ${runtime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
	fi
	genend=`date +%s`
	genruntime=$((genend-genstart))
	echo "Generation ${gen} took ${genruntime} seconds" >> $WorkingDir/Run_Outputs/$RunName/time.txt
done

cp generationDNA.csv "$WorkingDir"/Run_Outputs/$RunName/FinalGenerationParameters.csv
mv runData.csv Antenna_Performance_Metric

#########################################################################################################################
###Moving the Veff AraSim output for the actual ARA bicone into the $RunName directory so this data isn't lost in     ###
###the next time we start a run. Note that we don't move it earlier since (1) our plotting software and fitness score ###
###calculator expect it where it is created in "$WorkingDir"/Antenna_Performance_Metric, and (2) we are only creating ###
###it once on gen 0 so it's not written over in the looping process.                                                  ###
########################################################################################################################
cd "$WorkingDir"
mv AraOut_ActualBicone.txt "$WorkingDir"/Run_Outputs/$RunName/AraOut_ActualBicone.txt


