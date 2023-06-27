##########   IceMC Execution (D)  ################################################################################################################## 
#
#
#       1. Moves each .dat file individually into a folder that IceMC can access while changing to file that IceMC can use
#
#       2. For each individual ::
#           I. Run IceMC for that file
#           III. Moves the IceMC output into the Antenna_Performance_Metric folder
#
#
################################################################################################################################################## 
#variables
gen=$1
NPOP=$2
WorkingDir=$3
PSIMDIR=$4
exp=$5
NNT=$6
RunName=$7
Seeds=$8
DEBUG_MODE=$9
XFProj=${10}
XFCOUNT=${11}
SpecificSeed=32000

echo "Entering Part D1 PUEO!"
echo $XFProj
cd $WorkingDir
cd $XFProj
pwd
mkdir -m775 XF_models_${gen}
cd ../Root_Files
mkdir -m775 ${gen}_Root_Files
cd $PSIMDIR/outputs
mkdir -m775 ${gen}_outputs
cd $WorkingDir

#Move the gain files into the correct place for PSIM to read them in
for i in `seq 1 $NPOP`
do
	run_num=$((NPOP * gen + i))
	cp Test_Outputs/hh_0_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_0_Toyon${run_num}
	cp Test_Outputs/hv_0_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hv_0_Toyon${run_num}
	cp Test_Outputs/vv_0_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_0_Toyon${run_num}
	cp Test_Outputs/vh_0_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vh_0_Toyon${run_num}
	cp Test_Outputs/hh_el_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_el_Toyon${run_num}
	cp Test_Outputs/hh_az_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_az_Toyon${run_num}
	cp Test_Outputs/vv_el_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_el_Toyon${run_num}
	cp Test_Outputs/vv_az_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_az_Toyon${run_num}
done
#record the gain data
cp Test_Outputs/* $XFProj/XF_models_${gen}/

if [ ${gen} -eq 0 ]
then
	mkdir -m775 Run_Outputs/${RunName}/PUEO_Outputs
	mkdir -m775 Run_Outputs/${RunName}/PUEO_Errors
fi


cd Antenna_Performance_Metric

echo "Resuming..."
cd $PSIMDIR


#Let's make sure we're sourcing the correct files
#source /fs/ess/PAS1960/BiconeEvolutionOSC/new_root/new_root_setup.sh
#put a copy of this in the repository
#Probably change this in the future
source $PSIMDIR/set_env.sh

#If we're doing a real run, we only need to change the setup.txt file once
#Although we need to be careful, since maybe eventually we'll want to run multiple times at once?
if [ $DEBUG_MODE -eq 0 ]
then

	#Shouldn't need this as we input these as paramaters into the simulatePueo call
	#sed -e "s/Number of neutrinos: 200/Number of neutrinos: ${NNT}/" -e "s/Energy exponent: 20/Energy exponent: $exp/" ${PSIMDIR}/pueoBuilder/components/pueoSim/config/pueo.conf > ${PSIMDIR}/pueoBuilder/components/pueoSim/config/setup.conf
	
	# Now we just need to run IceMC from the setup file
	# Instead of a for loop, we can use a single command
	# We need the jobs to go form 1 to NPOP*NSEEDS
	# For the job name, make it the RunName
	# This will help for directing the output/error files
	cd $WorkingDir
	numJobs=$((NPOP*Seeds))
	maxJobs=252 #for now, maybe make this a variable in the main script
	sbatch --array=1-${numJobs}%${maxJobs} --export=ALL,gen=$gen,WorkingDir=$WorkingDir,RunName=$RunName,Seeds=$Seeds,PSIMDIR=$PSIMDIR,NPOP=$NPOP,NNT=$NNT,Exp=$exp --job-name=${RunName} Batch_Jobs/PueoCall_Array.sh
	cd $PSIMDIR

# If we're testing with the seed, use DEBUG_MODE=1
#For now DEBUG mode doesn't work for PUEO
else
	for i in `seq 1 $NPOP`
	do
		for j in `seq 1 $Seeds`
		do
		# ask about this 
		# I think we want to use the below commented out version
		# but I'm commenting it out for testing purposes
		SpecificSeed=$(expr $j + 32000)
		#SpecificSeed=32000
		
		sed -e "s/Number of neutrinos: 2000000/Number of neutrinos: ${NNT}/" -e "s/Energy exponent: 20/Energy exponent: $exp/" -e "s/Random seed: 65546/Random seed: $SpecificSeed/" ${PSIMDIR}/inputs.conf > ${PSIMDIR}/setup.conf
		
		#We will want to call a job here to do what this AraSim call is doing so it can run in parallel
		cd $WorkingDir
		output_name=/users/PAS1960/dylanwells1629/GNETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/IceMC_Outputs/${gen}_${i}_${j}.output
		error_name=/users/PAS1960/dylanwells1629/GNETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/IceMC_Errors/${gen}_${i}_${j}.error
		sbatch --export=ALL,gen=$gen,num=$i,WorkingDir=$WorkingDir,RunName=$RunName,Seeds=$j,PSIMDIR=$PSIMDIR --job-name=PueoCall_Array_${gen}_${i}_${j}.run --output=$output_name --error=$error_name Batch_Jobs/PueoCall_Array.sh
		# We are going to implement a notification system
		# This will require being able to know the job IDs
		# We'll print this to a file and then read it in D2

		cd $PSIMDIR
		rm -f outputs/*.root
		done
	done

fi


#This submits the job for the actual PUEO antenna. Veff depends on ENergy and we need this to run once per run to compare it.
if [ $gen -eq 10000 ]
then
	#sed -e "s/num_nnu/100000" /fs/ess/PAS1960/BiconeEvolutionOSC/AraSim/setup_dummy_araseed.txt > /fs/ess/PAS1960/BiconeEvolutionOSC/AraSim/setup.txt
	sbatch --export=ALL,WorkingDir=$WorkingDir,RunName=$RunName,PSIMDIR=$PSIMDIR,NNT=$NNT Batch_Jobs/PueoActual.sh

fi
## Let's move the uan files to a directory

cd $WorkingDir/Run_Outputs/${RunName}/uan_files
mkdir -m775 ${gen}_uan_files
for i in `seq 1 $XFCOUNT`
do
	mkdir -m775 ${gen}_uan_files/${i}
	mv ../${gen}_${i}_*.uan ${gen}_uan_files/${i}/
done

