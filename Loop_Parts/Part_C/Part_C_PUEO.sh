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
SYMMETRY=$6
PSIMDIR=$7
#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/

module load python/3.7-2019.10

cd $WorkingDir/Test_Outputs
## We need to remove the files in the Test_Outputs directory
## I'm doing it very carefully to avoid deleting files in a different location
##	in the event $WorkindDir has some issue
rm vv* 2>/dev/null
rm hh* 2>/dev/null
rm vh* 2>/dev/null
rm hv* 2>/dev/null
cd $WorkingDir/Antenna_Performance_Metric

chmod -R 777 $WorkingDir/Antenna_Performance_Metric
if [ $SYMMETRY -eq 0 ]
then
	python XFintoPUEO.py $NPOP $WorkingDir $RunName $gen $indiv
else
	python XFintoPUEO_Symmetric.py $NPOP $WorkingDir $RunName $gen $WorkingDir/Test_Outputs
fi
#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/

## Temporary fix for cross-pols being low!!!
for i in `seq 1 $NPOP`
do
	cp $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/hv_0_toyon ../Test_Outputs/hv_0_${gen}_${i}
	cp $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/vh_0_toyon ../Test_Outputs/vh_0_${gen}_${i}
done

chmod -R 777 $WorkingDir/Test_Outputs