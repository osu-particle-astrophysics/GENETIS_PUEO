############### Execute our initial genetic algorithm #####################
#
#
#   This part of the Loop:
#
#   1. Runs the genetic algorithm
#
#   2. Moved GA outputs and renames the .csv file so it isn't overwritten
#
#
############################################################################
#variables
WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/RunData/$RunName/setup.sh

cd $WorkingDir

g++ -std=c++11 GA/Shared-Code/GA/SourceFiles/New_GA.cpp -o GA/New_GA.exe
./GA/New_GA.exe PUEO $gen $NPOP $rank_no $roulette_no $tournament_no $reproduction_no $crossover_no $mutationRate $sigma

cp generationDNA.csv Generation_Data/generationDNA.csv
cp Generation_Data/generationDNA.csv Run_Outputs/$RunName/Generation_Data/${gen}_generationDNA.csv
mv Generation_Data/generators.csv Run_Outputs/$RunName/Generation_Data/${gen}_generators.csv 2>/dev/null

if [ $gen -gt 0 ]
then
	cp parents.csv Generation_Data/parents.csv
	mv Generation_Data/parents.csv Run_Outputs/$RunName/Generation_Data/${gen}_parents.csv
fi
chmod -R 775 Generation_Data/
