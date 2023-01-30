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
GeoGactor=$5

cd $WorkingDir
if [ $gen -eq 0 ]
then
	#run initial GA

else
	#run continuous GA

fi

cp Generation_Data/generationDNA.csv Run_Outputs/$RunName/${gen}_generationDNA.csv
mv Generation_Data/generators.csv Run_Outputs/$RunName/${gen}_generators.csv
if [ $gen -gt 0 ]
then
	mv Generation_Data/parents.csv Run_Outputs/$RunName/${gen}_parents.csv
	mv Generation_Data/genes.csv Run_Outputs/$RunName/${gen}_genes.csv
	mv Generation_Data/mutations.csv Run_Outputs/$RunName/${gen}_mutations.csv
fi


