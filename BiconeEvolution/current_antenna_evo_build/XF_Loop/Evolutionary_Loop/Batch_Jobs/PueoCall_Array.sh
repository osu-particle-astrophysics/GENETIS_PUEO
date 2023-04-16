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
#Seeds=$4
#PSIMDIR=$5
#NPOP=$6
#NNT=$7
#Exp=$8

#source /fs/ess/PAS1960/BiconeEvolutionOSC/new_root/new_root_setup.sh

source /fs/ess/PAS1960/buildingPueoSim/set_env.sh

cd $PSIMDIR

# Need to change IceMC to read in the correct gain files for each run 


#this is the command in the XF script although I don't know if we can pass in variables from that script
#into this one like i and WorkingDir
#if in the job call we have 

num=$(($((${SLURM_ARRAY_TASK_ID}-1))/${Seeds}+1))
seed=$(($((${SLURM_ARRAY_TASK_ID}-1))%${Seeds}+1))

run_num=$(((NPOP * gen + num) * 1000 + seed))

echo a_${num}_${seed}.txt

chmod -R 777 ${PSIMDIR}/${gen}_outputs/

#./icemc -i ${PSIMDIR}/components/icemc/setup.conf -o outputs/ -r "_${gen}_${num}" > $TMPDIR/
./pueoBuilder/build/components/pueoSim/simulatePueo -i ${PSIMDIR}/pueoBuilder/components/pueoSim/config/setup.conf -o ${PSIMDIR}/${gen}_outputs/ -r $run_num -n $NNT -e $Exp > $TMPDIR/

cd ${gen}_outputs/run${run_num}
cat veff${run_num}.csv >> $WorkingDir/Run_Outputs/$RunName/veff_${gen}_${num}.csv
cat {seed} >> $WorkingDir/Run_Outputs/$RunName/${gen}_counts.txt #might need to take this in to account to see which veff corresponds to which in the veff file
mv IceFinal_${run_num}.root $WorkingDir/Run_Outputs/$RunName/IceFinal_${gen}_{num}_{seed}.root
cd ..
rm -r run${run_num}

cd $TMPDIR
mv * $WorkingDir/Run_Outputs/$RunName/PSIMFlags
#cd $WorkingDir/Run_Outputs/$RunName/AraSimFlags
#echo ${num}_${Seeds} > ${num}_${Seeds}.txt
echo $gen > $TMPDIR/${num}_${seed}.txt
echo $num >> $TMPDIR/${num}_${seed}.txt
echo $seed >> $TMPDIR/${num}_${seed}.txt


# we need to go fix the file names from the jobs
cd $WorkingDir/Run_Outputs/$RunName

#cp veff_${gen}_${num}.csv.* veff_${gen}_${num}.csv

# now do the flag files
cd $WorkingDir/Run_Outputs/$RunName/PSIMFlags

cp ${num}_${Seeds}.txt.* ${num}_${Seeds}.txt
rm ${num}_${Seeds}.txt.*

