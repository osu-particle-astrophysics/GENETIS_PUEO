#!/bin/bash
#SBATCH -A PAS1960
#SBATCH -t 10:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/
#SBATCH -e /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/
cd /fs/ess/PAS1960/BiconeEvolutionOSC/IceMC

source /fs/ess/PAS1960/BiconeEvolutionOSC/new_root/new_root_setup.sh

./icemc -i $IceMCDir/components/icemc/inputs.anita4.conf -o outputs_Actual_Antenna/

cd $TMPDIR

