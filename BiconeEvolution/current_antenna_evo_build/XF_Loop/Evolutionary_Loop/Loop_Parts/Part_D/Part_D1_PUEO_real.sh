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
IceMCExec=$4
exp=$5
NNT=$6
RunName=$7
Seeds=$8
DEBUG_MODE=$9
SpecificSeed=32000

cd $WorkingDir

if [ ${gen} -eq 0 ]
then
        mkdir -m775 Run_Outputs/${RunName}/IceMC_Outputs
        mkdir -m775 Run_Outputs/${RunName}/IceMC_Errors
fi


cd Antenna_Performance_Metric
for i in `seq 1 $NPOP`
do
        mv evol_antenna_model_${i}.dat $IceMCExec/a_${i}.txt
done

echo "Resuming..."
cd "$IceMCExec"

#Let's make sure we're sourcing the correct files
source /fs/ess/PAS1960/BiconeEvolutionOSC/new_root/new_root_setup.sh
#ask about this source. source Anita?
#source /cvmfs/ara.opensciencegrid.org/trunk/centos7/setup.sh

#If we;re doing a real run, we only need to change the setup.txt file once
#Although we need to be careful, since maybe eventually we'll want to run multiple times at once?
if [ $DEBUG_MODE -eq 0 ]
then

	sed -e "s/Number of neutrinos: 2000000/Number of neutrinos: ${NNT}/" -e "s/Energy exponent: 20/Energy exponent: $exp/" -e "s/Random seed: 65546/Random seed: $SpecificSeed/" ${IceMCExec}/inputs.conf > ${IceMCExec}/setup.conf
	
	# Now we just need to run IceMC from the setup file
	# Instead of a for loop, we can use a single command
	# We need the jobs to go form 1 to NPOP*NSEEDS
	# For the job name, make it the RunName
	# This will help for directing the output/error files
	cd $WorkingDir
	maxJobs=$((NPOP*Seeds))
	maxJobs=252 #for now, maybe make this a variable in the main script
	sbatch --array=1-${numJobs}%${maxJobs} --export=ALL,gen=$gen,WorkingDir=$WorkingDir,RunName=$RunName,Seeds=$Seeds,IceMCDir=$IceMCDir --job-name=${RunName} Batch_Jobs/IceMCCall_Array.sh
	cd $IceMCExec

# If we're testing with the seed, use DEBUG_MODE=1
# Then, we'll change the setup file for each job
# If we're using the DEBUG mode, we'll do it the original way
# This should be ok, since we'll be using few jobs in such instances
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
		
		sed -e "s/Number of neutrinos: 2000000/Number of neutrinos: ${NNT}/" -e "s/Energy exponent: 20/Energy exponent: $exp/" -e "s/Random seed: 65546/Random seed: $SpecificSeed/" ${IceMCExec}/inputs.conf > ${IceMCExec}/setup.conf
		
		#We will want to call a job here to do what this AraSim call is doing so it can run in parallel
		cd $WorkingDir
		output_name=/users/PAS1960/dylanwells1629/GNETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/IceMC_Outputs/${gen}_${i}_${j}.output
	error_name=/users/PAS1960/dylanwells1629/GNETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/IceMC_Errors/${gen}_${i}_${j}.error
	sbatch --export=ALL,gen=$gen,num=$i,WorkingDir=$WorkingDir,RunName=$RunName,Seeds=$j,IceMCDir=$IceMCExec --job-name=IceMCCall_Array_${gen}_${i}_${j}.run --output=$output_name --error=$error_name Batch_Jobs/IceMCCall_Array.sh
		# We are going to implement a notification system
		# This will require being able to know the job IDs
		# We'll print this to a file and then read it in D2

		cd $IceMCExec
		rm -f outputs/*.root
		done
	done

fi

#ask about this
#This submits the job for the actual ARA bicone. Veff depends on Energy and we need this to run once per run to compare it to. 
if [ $gen -eq 10000 ]
then
        #sed -e "s/num_nnu/100000" /fs/ess/PAS1960/BiconeEvolutionOSC/AraSim/setup_dummy_araseed.txt > /fs/ess/PAS1960/BiconeEvolutionOSC/AraSim/setup.txt
        sbatch --export=ALL,WorkingDir=$WorkingDir,RunName=$RunName,AraSimDir=$AraSimExec Batch_Jobs/AraSimBiconeActual_Prototype.sh

fi
## Let's move the uan files to a directory

cd $WorkingDir/RunOutputs/${RunName}/uan_files
mkdir -m775 ${gen}_uan_files
for i in `seq 1 $NPOP`
do
	mkdir -m775 ${gen}_uan_files/${i}
	mv ../${gen}_${i}*.uan ${gen}_uan_files/${i}/
done

