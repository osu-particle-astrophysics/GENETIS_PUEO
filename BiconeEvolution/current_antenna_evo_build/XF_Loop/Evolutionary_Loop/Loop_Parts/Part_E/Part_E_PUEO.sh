
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

#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/

module load python/3.7-2019.10

#cd $WorkingDir
# put the actual bicone results in the run name directory
#cp ARA_Bicone_Data/AraOut_Actual_Bicone_Fixed_Polarity_2.9M_NNU.txt Run_Outputs/$RunName/AraOut_ActualBicone.txt

cd Antenna_Performance_Metric/

echo 'Starting fitness function calculating portion...'

mv *.root "$WorkingDir/Run_Outputs/$RunName/RootFilesGen${gen}/"


python fitnessFunction_PUEO.py $NPOP $Seeds "$WorkingDir/Run_Outputs/veff_${gen}" 
cp fitnessScores.csv "$WorkingDir"/Run_Outputs/$RunName/${gen}_fitnessScores.csv
cp fitnessScores.csv "$WorkingDir"/Run_Outputs/$RunName/${gen}_vEffectives.csv
mv fitnessScores.csv $WorkingDir/Generation_Data/

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


#Plotting software for Veff(for each individual) vs Generation
python Veff_Plotting.py "$WorkingDir"/Run_Outputs/$RunName "$WorkingDir"/Run_Outputs/$RunName $gen $NPOP $Seeds

cd $WorkingDir

if [ $gen -eq 0 ]
then
	rm -f Generation_Data/runData.csv
fi

if [ $indiv -eq $NPOP ]
then
	cp Generation_Data/runData.csv $WorkingDir/Run_Outputs/$RunName/runData_$gen.csv
fi

python Data_Generators/gensData.py $gen Generation_Data 
cd Antenna_Performance_Metric
next_gen=$(($gen+1))


cd $WorkingDir/Antenna_Performance_Metric

python3 avg_freq.py $XFProj $XFProj 10 $NPOP

cd $XFProj
mv gain_vs_freq.png gain_vs_freq_gen_$gen.png

echo 'Congrats on getting a fitness score!'

cd $WorkingDir

mv Generation_Data/parents.csv Run_Outputs/$RunName/${gen}_parents.csv
mv Generation_Data/genes.csv Run_Outputs/$RunName/${gen}_genes.csv
mv Generation_Data/mutations.csv Run_Outputs/$RunName/${gen}_mutations.csv
mv Generation_Data/generators.csv Run_Outputs/$RunName/${gen}_generators.csv

#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/
