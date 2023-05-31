#!/bin/bash
## This job is designed to be submitted by an array batch submission
## Here's the command:
## sbatch --array=1-NPOP*SEEDS%max --export=ALL,(variables) PueoCall_Array.sh
#SBATCH -A PAS1960
#SBATCH -t 10:00:00
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --output=/fs/ess/PAS1960/HornEvolutionOSC/GENETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/%x/PUEO_Outputs/PUEOsim_%a.output
#SBATCH --error=/fs/ess/PAS1960/HornEvolutionOSC/GENETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/%x/PUEO_Errors/PUEOsim_%a.error

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
cd outputs/${gen}_outputs
mkdir -m775 $SLURM_ARRAY_TASK_ID
cd ../..
# Need to change IceMC to read in the correct gain files for each run 


#this is the command in the XF script although I don't know if we can pass in variables from that script
#into this one like i and WorkingDir
#if in the job call we have 

num=$(($((${SLURM_ARRAY_TASK_ID}-1))/${Seeds}+1))
seed=$(($((${SLURM_ARRAY_TASK_ID}-1))%${Seeds}+1))

run_num=$(((NPOP * gen + num) * 1000 + seed))

echo a_${num}_${seed}.txt

chmod -R 777 ${PSIMDIR}/outputs/${gen}_outputs/

#./icemc -i ${PSIMDIR}/components/icemc/setup.conf -o outputs/ -r "_${gen}_${num}" > $TMPDIR/

./pueoBuilder/build/components/pueoSim/simulatePueo -i pueo.conf -o ${PSIMDIR}/outputs/${gen}_outputs/$SLURM_ARRAY_TASK_ID -r $run_num -n $NNT -e $Exp > $TMPDIR/out.txt

cd $TMPDIR
echo "After done running PUEOsim"
pwd
ls -alrt
mv out.txt $PSIMDIR/outputs/${gen}_outputs/${SLURM_ARRAY_TASK_ID}/run${run_num}
cd $PSIMDIR/outputs/${gen}_outputs/${SLURM_ARRAY_TASK_ID}/run${run_num}
grep -s "Effective volume: " out.txt | tail -n1 > veff_${run_num}.csv
grep -s "Effective volume: " out.txt
ls -alrt
cat veff_${run_num}.csv >> $WorkingDir/Run_Outputs/$RunName/veff_${gen}_${num}.csv
echo ${seed} >> $WorkingDir/Run_Outputs/$RunName/${gen}_counts.txt #might need to take this in to account to see which veff corresponds to which in the veff file
# PueoSim v1.1.0 outputs 3 IceFinal files for each run
mv IceFinal_${run_num}_allTree.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/IceFinal_allTree_${gen}_${num}_${seed}.root
mv IceFinal_${run_num}_skimmed.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/IceFinal_skimmed_${gen}_${num}_${seed}.root
mv IceFinal_${run_num}_passTree0.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/IceFinal_passTree_${gen}_${num}_${seed}_0.root
# remove the rest of the files (Each takes up multiple GBs)
rm *.root
cd ..
#rm -r run${run_num}

cd $TMPDIR
mv * $WorkingDir/Antenna_Performance_Metric 
#cd $WorkingDir/Run_Outputs/$RunName/AraSimFlags
#echo ${num}_${Seeds} > ${num}_${Seeds}.txt
echo $gen > $TMPDIR/${num}_${seed}.txt
echo $num >> $TMPDIR/${num}_${seed}.txt
echo $seed >> $TMPDIR/${num}_${seed}.txt

mv * $WorkingDir/Run_Outputs/$RunName/PUEOFlags

#cp veff_${gen}_${num}.csv.* veff_${gen}_${num}.csv

# now do the flag files
cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags

cp ${num}_${seed}.txt.* ${num}_${seed}.txt
rm ${num}_${seed}.txt.*

