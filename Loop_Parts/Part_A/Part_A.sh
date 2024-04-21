############### Execute our initial genetic algorithm #####################
#
#
#   This part of the Loop:
#
#   1. Runs the genetic algorithm
#
############################################################################
#variables
WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/Run_Outputs/$RunName/setup.sh

cd $WorkingDir

# Make GA take in a run directory to source the data from
g++ -std=c++11 GA/Shared-Code/GA/SourceFiles/New_GA.cpp -o GA/New_GA.exe
./GA/New_GA.exe PUEO $gen $NPOP $rank_no $roulette_no $tournament_no $reproduction_no $crossover_no $mutationRate $sigma $WorkingDir/Run_Outputs/$RunName

#chmod -R 775 Generation_Data/
