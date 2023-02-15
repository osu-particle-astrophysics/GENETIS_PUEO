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

cd $WorkingDir

g++ -std=c++11 GA/SourceFiles/New_GA.cpp -o GA/Executables/New_GA.exe
./GA/Executables/New_GA.exe "PUEO" $gen $NPOP 60 20 20 10 90 10 7

cp generationDNA.csv Run_Outputs/$RunName/${gen}_generationDNA.csv
mv generators.csv Run_Outputs/$RunName/${gen}_generators.csv

if [ $gen -gt 0 ]
then
	mv parents.csv Run_Outputs/$RunName/${gen}_parents.csv
fi

