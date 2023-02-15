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
gen=$1
NPOP=$2
WorkingDir=$3
RunName=$4
GeoFactor=$5
rank_no=$6
roulette_no=$7
tournament_no=$8
reproduction_no=$9
crossover_no=${10}
mutation-rate=${11}
sigma=${12}

cd $WorkingDir

g++ -std=c++11 GA/SourceFiles/New_GA.cpp -o GA/Executables/New_GA.exe
./GA/Executables/New_GA.exe "PUEO" $gen $NPOP $rank_no $roulette_no $tournament_no $reproduction_no $crossover_no $mutation-rate $sigma

cp generationDNA.csv Run_Outputs/$RunName/${gen}_generationDNA.csv
mv generators.csv Run_Outputs/$RunName/${gen}_generators.csv

if [ $gen -gt 0 ]
then
	mv parents.csv Run_Outputs/$RunName/${gen}_parents.csv
fi

