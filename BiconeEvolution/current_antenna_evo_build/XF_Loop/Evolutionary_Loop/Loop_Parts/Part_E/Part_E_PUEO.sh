
########  Fitness Score Generation (E)  ######################################################################################################### 
#
#
#      1. Takes the root files from the generation and runs rootAnalysis.py on them to get the fitness scores
#
#      2. Then gensData.py extracts useful information from generationDNA.csv and fitnessScores.csv, and writes to maxFitnessScores.csv and runData.csv
#
#      3. Copies each .uan file from the Antenna_Performance_Metric folder and moves to Run_Outputs/$RunName folder
#
#
#################################################################################################################################################### 

#variables
gen=$1
NPOP=$2
WorkingDir=$3
RunName=$4
ScaleFactor=$5
indiv=$6
Seeds=$7
GeoFactor=$8
IceMCExec=$9
XFProj=${10}
PSIMDIR=${11}
exp=${12}
ParallelXFPUEO=${13}

echo 'Starting fitness function calculating portion...'

module load python/3.6-conda5.2
if [ $ParallelXFPUEO -eq 0 ]
then
	#The rootAnalysis script only works with the base python, so unload 3.6
	module unload python/3.6-conda5.2

	source $PSIMDIR/set_env.sh

	cd $WorkingDir/Antenna_Performance_Metric

	for i in `seq 1 $NPOP`
	do
		python rootAnalysis.py $gen $i $exp $WorkingDir/Run_Outputs/${RunName}/Generation_Data $RunName $WorkingDir
	done

else
	cd $WorkingDir/Antenna_Performance_Metric
	python fitFix.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $NPOP $gen
	cd $WorkingDir/Run_Outputs/$RunName/Generation_Data
	for i in `seq 1 $NPOP`
	do
		rm -Rf $i
	done
fi


if [ $gen -gt 0 ]
then
	python newCombineErrors.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $gen $NPOP
fi

cd $WorkingDir/Run_Outputs/$RunName/Generation_Data
echo "The Ohio State University GENETIS Data." > $WorkingDir/Generation_Data/fitnessScores.csv
echo "Current generation's fitness scores:" >> $WorkingDir/Generation_Data/fitnessScores.csv
cat ${gen}_fitnessScores.csv >> $WorkingDir/Generation_Data/fitnessScores.csv
cd -

cp $WorkingDir/Generation_Data/fitnessScores.csv $WorkingDir/fitnessScores.csv

cp ../Generation_Data/generationDNA.csv $WorkingDir/Run_Outputs/$RunName/Generation_Data/${gen}_generationDNA.csv

cd $WorkingDir
source Antenna_Performance_Metric/set_plotting_env.sh

if [ $gen -eq 0 ]
then
	rm -f Generation_Data/runData.csv
fi

if [ $indiv -eq $NPOP ]
then
	cp Generation_Data/runData.csv $WorkingDir/Run_Outputs/$RunName/Generation_Data/runData_$gen.csv
fi
# changing this to correct version of gensData, couldn't overwrite the current file in the Data_Generators directory. this may have caused the issue initially
# I have updated gensData to read from the run directory, as using the GenerationData directory didn't make much sense to me.
python Antenna_Performance_Metric/gensDataPUEO.py $gen $WorkingDir/Run_Outputs/$RunName/Generation_Data  

echo 'Congrats on getting a fitness score!'

cd $WorkingDir

mv -f Generation_Data/parents.csv Run_Outputs/$RunName/Generation_Data/${gen}_parents.csv
mv -f Generation_Data/genes.csv Run_Outputs/$RunName/Generation_Data/${gen}_genes.csv 2>/dev/null
mv -f Generation_Data/mutations.csv Run_Outputs/$RunName/Generationa_Data/${gen}_mutations.csv 2>/dev/null
mv -f Generation_Data/generators.csv Run_Outputs/$RunName/Generation_Data/${gen}_generators.csv 2>/dev/null

cd $WorkingDir/Run_Outputs/$RunName
if [ $gen -eq 0 ]
then
	mkdir -m775 Plotting_Outputs
	mkdir -m775 Plotting_Errors
fi


