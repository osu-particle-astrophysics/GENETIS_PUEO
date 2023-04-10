#!/bin/bash
#SBATCH -A PAS1960
#SBATCH -t 10:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/
#SBATCH -e /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/

#variables
#RunName=$1
#PSIMDIR=$2
#NNT=$4

cd $PSIMDIR

#source /fs/ess/PAS1960/BiconeEvolutionOSC/new_root/new_root_setup.sh
#source $IceMCDir/../../Anita.sh
source $PSIMDIR/set_env.sh
mkdir 775 Default_Antenna_Outputs/

#./icemc -i $PSIMDIR/components/icemc/inputs.anita4.conf -o outputs_Actual_Antenna/ -r "Actual" > $TMPDIR/IceMCActual

#Store default antenna gains in run 999999
./pueoBuilder/build/components/pueoSim/simulatePueo -i pueo.conf -o /fs/ess/PAS1960/buildingPueoSim/Default_Antenna_Outputs -n $NNT -r 999999

cd Default_Antenna_Outputs/
mv run999999/veff999999.txt $WorkingDir/Antenna_Performance_Metric/PueoActual/default_antenna_veff.txt

cd $TMPDIR

