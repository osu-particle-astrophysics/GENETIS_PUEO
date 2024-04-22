
########  Fitness Score Generation (E)  ######################################################################################################### 
#
#
#      1. Takes the root files from the generation and runs rootAnalysis.py on them to get the fitness scores
#
#      2. Then gensData.py extracts useful information from generationDNA.csv and fitnessScores.csv, and writes to maxFitnessScores.csv and runData.csv
#
#
#################################################################################################################################################### 

#variables
WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/Run_Outputs/$RunName/setup.sh

echo 'Starting fitness function calculating portion...'

module load python/3.6-conda5.2
if [ $ParallelXFPUEO -eq 0 ]
then
	#The rootAnalysis script only works with the base python, so unload 3.6
	module unload python/3.6-conda5.2

	source $PSIMDIR/set_env.sh

	cd $WorkingDir/Antenna_Performance_Metric

	for i in $(seq 0 $((NPOP-1)))
	do
		python rootAnalysis.py $gen $i $exp $WorkingDir/Run_Outputs/${RunName}/Generation_Data $RunName $WorkingDir
	done

else
	# Conglomerate the output files into one csv file
	cd $WorkingDir/Antenna_Performance_Metric
	python fitFix.py $WorkingDir/Run_Outputs/$RunName/Generation_Data/temp_gen_files $NPOP $gen
	cd $WorkingDir/Run_Outputs/$RunName/Generation_Data
	
	# Remove temporary directories
	for i in $(seq 0 $((NPOP-1)))
	do
		rm -Rf temp_gen_files/$i
	done
fi

cd $WorkingDir/Antenna_Performance_Metric

# Combine psim errors if necessary
if [ $gen -gt 0 ]
then
	python newCombineErrors.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $gen $NPOP
fi

python gensData.py $gen $WorkingDir/Run_Outputs/$RunName/Generation_Data  

if [ $gen -eq 0 ]
then
	cd $WorkingDir/Run_Outputs/$RunName
	mkdir -m775 Plotting_Outputs
	mkdir -m775 Plotting_Errors
fi


