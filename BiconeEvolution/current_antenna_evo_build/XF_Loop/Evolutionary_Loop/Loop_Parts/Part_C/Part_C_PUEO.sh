######### XF output conversion code (C)  ###########################################################################################
#
#
#         1. Converts .uan file from XF into a readable .dat file that Arasim can take in.
#
#
####################################################################################################################################
#variables
NPOP=$1
WorkingDir=$2
RunName=$3
gen=$4
indiv=$5

#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/

cd $WorkingDir
cd Antenna_Performance_Metric

 

chmod -R 777 $WorkingDir/Antenna_Performance_Metric
python XFintoPUEO.py $NPOP $WorkingDir $RunName $gen $indiv

#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/


