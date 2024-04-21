######### XF output conversion code (C)  ###########################################################################################
#
#
#         1. Converts .uan file from XF into a readable .dat file that Arasim can take in.
#
#
####################################################################################################################################
#variables
WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/Run_Outputs/$RunName/setup.sh

module load python/3.7-2019.10


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
for i in $(seq 1 $NPOP)
do
	cp $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/hv_0_toyon ../Test_Outputs/hv_0_${gen}_${i}
	cp $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/vh_0_toyon ../Test_Outputs/vh_0_${gen}_${i}
done

chmod -R 777 $WorkingDir/Test_Outputs