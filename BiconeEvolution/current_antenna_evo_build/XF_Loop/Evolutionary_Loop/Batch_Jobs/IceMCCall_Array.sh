#!/bin/bash
## This job is designed to be submitted by an array batch submission
## Here's the command:
## sbatch --array=1-NPOP*SEEDS%max --export=ALL,(variables) AraSimCall_Array.sh
#SBATCH -A PAS1960
#SBATCH -t 10:00:00
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --output=/fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/%x/AraSim_Outputs/AraSim_%a.output
#SBATCH --error=/fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/%x/AraSim_Errors/AraSim_%a.error

#variables
#gen=$1
#WorkingDir=$2
#RunName=$3

source /fs/ess/PAS1960/BiconeEvolutionOSC/new_root/new_root_setup.sh

cd $IceMCDir
'''

Need to change IceMC to read in the correct gain files for each run 

'''

#this is the command in the XF script although I don't know if we can pass in variables from that script
#into this one like i and WorkingDir
#if in the job call we have 

num=$(($((${SLURM_ARRAY_TASK_ID}-1))/${Seeds}+1))
seed=$(($((${SLURM_ARRAY_TASK_ID}-1))%${Seeds}+1))

echo a_${num}_${seed}.txt
chmod -R 777 $IceMCDir/build/components/icemc/outputs/
#input is stored in $IceMCExec/components/icemc/setup.conf
cd build/components/icemc
./icemc -i $IceMCDir/components/icemc/setup.conf -o outputs/ -r "_${gen}_${num}" > $TMPDIR/


cd outputs/
mv veff_${gen}_${num}.txt $WorkingDir/Run_Outputs
mv output_${gen}_${num}.txt $WorkingDir/Run_Outputs

cd $TMPDIR
mv * $WorkingDir/Run_Outputs/$RunName/IceMcFlags
#cd $WorkingDir/Run_Outputs/$RunName/AraSimFlags
#echo ${num}_${Seeds} > ${num}_${Seeds}.txt
echo $gen > $TMPDIR/${num}_${seed}.txt
echo $num >> $TMPDIR/${num}_${seed}.txt
echo $seed >> $TMPDIR/${num}_${seed}.txt


# we need to go fix the file names from the jobs
cd $WorkingDir/Antenna_Performance_Metric

cp veff_${gen}_${num}.txt.* veff_${gen}_${num}.txt

# now do the flag files
cd $WorkingDir/Run_Outputs/$RunName/IceMCFlags

cp ${num}_${Seeds}.txt.* ${num}_${Seeds}.txt
rm ${num}_${Seeds}.txt.*

