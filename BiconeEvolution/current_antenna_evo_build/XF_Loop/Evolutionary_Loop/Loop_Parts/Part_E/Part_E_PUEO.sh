
########  Fitness Score Generation (E)  ######################################################################################################### 
#
#
#      1. Takes AraSim data and cocatenates each file name into one string that is then used to generate fitness scores 
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
#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/


#cd $WorkingDir
# put the actual bicone results in the run name directory
#cp ARA_Bicone_Data/AraOut_Actual_Bicone_Fixed_Polarity_2.9M_NNU.txt Run_Outputs/$RunName/AraOut_ActualBicone.txt

cd $WorkingDir/Antenna_Performance_Metric/

#source set_plotting_env.sh

echo 'Starting fitness function calculating portion...'

mv -f *.root $WorkingDir/Run_Outputs/$RunName/RootFilesGen${gen}/

#python fitnessFunction_PUEO.py $NPOP $Seeds $WorkingDir/Run_Outputs/$RunName/veff_${gen} 

#The rootAnalysis script only works with the base python, so unload 3.6
module load python/3.6-conda5.2
module unload python/3.6-conda5.2

source $PSIMDIR/set_env.sh

for i in `seq 1 $NPOP`
do
	python rootAnalysis.py $gen $i $exp $WorkingDir/Run_Outputs/${RunName}/Generation_Data $RunName
done

module load python/3.6-conda5.2

if [ $gen -gt 0 ]
then
	python newCombineErrors.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $gen $NPOP
fi

cd $WorkingDir/Run_Outputs/$RunName/Generation_Data
echo "The Ohio State University GENETIS Data." > $WorkingDir/Generation_Data/fitnessScores.csv
echo "Current generation's fitness scores:" >> $WorkingDir/Generation_Data/fitnessScores.csv
cat ${gen}_fitnessScores.csv >> $WorkingDir/Generation_Data/fitnessScores.csv
cd -


#cp fitnessScores.csv $WorkingDir/Run_Outputs/$RunName/${gen}_fitnessScores.csv
#cp fitnessScores.csv $WorkingDir/Run_Outputs/$RunName/${gen}_vEffectives.csv
#cp fitnessScores.csv $WorkingDir/Generation_Data/
#cp fitnessScores.csv $WorkingDir/Run_Outputs/$RunName/Generation_Data/${gen}_fitnessScores.csv
#cp fitnessScores.csv $WorkingDir/Run_Outputs/$RunName/Generation_Data/${gen}_vEffectives.csv
#mv ${gen}_errorBars.csv $WorkingDir/Run_Outputs/$RunName/Generation_Data/${gen}_errorBars.csv
cp ../Generation_Data/generationDNA.csv $WorkingDir/Run_Outputs/$RunName/Generation_Data/${gen}_generationDNA.csv



#./fitnessFunction.exe $NPOP $Seeds $ScaleFactor $WorkingDir/Generation_Data/generationDNA.csv $GeoFactor $InputFiles #Here's where we add the flags for the generation
#cp fitnessScores.csv "$WorkingDir"/Run_Outputs/$RunName/${gen}_fitnessScores.csv
#mv fitnessScores.csv $WorkingDir/Generation_Data/

#cp vEffectives.csv "$WorkingDir"/Run_Outputs/$RunName/${gen}_vEffectives.csv
#mv vEffectives.csv $WorkingDir/Generation_Data/

#cp errorBars.csv "$WorkingDir"/Run_Outputs/$RunName/${gen}_errorBars.csv
#mv errorBars.csv $WorkingDir/Generation_Data/


# Let's produce the plot of the gain pattern for each of the antennas
# Start by making a directory to contain the images for the gain patterns of that generation
### NOTE: Moved to Part F in image_maker.sh. Keep this commented for now
#mkdir -m 775 $WorkingDir/Run_Outputs/$RunName/${gen}_Gain_Plots
#python $WorkingDir/Antenna_Performance_Metric/polar_plotter.py $WorkingDir/Run_Outputs/$RunName/${gen}_Gain_Plots $RunName 14 $NPOP $gen

cd $WorkingDir/Antenna_Performance_Metric


source set_plotting_env.sh


cd $WorkingDir

if [ $gen -eq 0 ]
then
	rm -f Generation_Data/runData.csv
fi

if [ $indiv -eq $NPOP ]
then
	cp Generation_Data/runData.csv $WorkingDir/Run_Outputs/$RunName/Generation_Data/runData_$gen.csv
fi
#changing this to correct version of gensData, couldn't overwrite the current file in the Data_Generators directory. this may have caused the issue initially
#I have updated gensData to read from the run directory, as using the GenerationData directory didn't make much sense to me.
python Antenna_Performance_Metric/gensDataPUEO.py $gen $WorkingDir/Run_Outputs/$RunName/Generation_Data  


echo 'Congrats on getting a fitness score!'

cd $WorkingDir

mv -f Generation_Data/parents.csv Run_Outputs/$RunName/Generation_Data/${gen}_parents.csv
mv -f Generation_Data/genes.csv Run_Outputs/$RunName/Generation_Data/${gen}_genes.csv
mv -f Generation_Data/mutations.csv Run_Outputs/$RunName/Generationa_Data/${gen}_mutations.csv
mv -f Generation_Data/generators.csv Run_Outputs/$RunName/Generation_Data/${gen}_generators.csv

cd $WorkingDir/Run_Outputs/$RunName
if [ $gen -eq 0 ]
then
	mkdir -m775 Plotting_Outputs
	mkdir -m775 Plotting_Errors
fi


#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/
