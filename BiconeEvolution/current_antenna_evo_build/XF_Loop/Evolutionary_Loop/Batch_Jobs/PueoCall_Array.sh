#!/bin/bash
## This job is designed to be submitted by an array batch submission
## Here's the command:
## sbatch --array=1-NPOP*SEEDS%max --export=ALL,(variables) PueoCall_Array.sh
#SBATCH -A PAS1960
#SBATCH -t 03:00:00
#SBATCH -N 1
#SBATCH -n 40
#SBATCH --output=Run_Outputs/%x/PUEO_Outputs/PUEOsim_%a.output
#SBATCH --error=Run_Outputs/%x/PUEO_Errors/PUEOsim_%a.error

#variables
#gen=$1
#WorkingDir=$2
#RunName=$3
#Seeds=$4
#PSIMDIR=$5
#NPOP=$6
#NNT=$7
#Exp=$8

threads=40

num=$(($((${SLURM_ARRAY_TASK_ID}-1))/${Seeds}+1))
seed=$(($((${SLURM_ARRAY_TASK_ID}-1))%${Seeds}+1))

# run number is the unique identifier for each pueoSim Process
# 40 processes are run per generation per seed
run_num=$(((NPOP * gen + num) * 1000 + seed * 40))


# set up environment
cd $PSIMDIR
source set_env.sh

# copy simulation exe to TMPDIR
cp pueoBuilder/build/components/pueoSim/simulatePueo $TMPDIR/simulatePueo
cp pueoBuilder/components/pueoSim/config/pueo.conf $TMPDIR/pueo.conf

cd $TMPDIR
touch pueoout.txt

echo "Running PSIM"
for ((i=$run_num; i<$((threads + run_num)); i++))
do
    # Run 40 processes of pueoSim 
    ./simulatePueo -i pueo.conf -o $TMPDIR -r $i -n $NNT -e $Exp > pueoout.txt &
done

echo "started PSIMs"
wait
echo "PSIMS finished"

# move the root files
for ((i=$run_num; i<$((threads + run_num)); i++))
do
    mv $TMPDIR/run${i}/IceFinal_${i}_skimmed.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/IceFinal_skimmed_${gen}_${num}_${i}.root
    mv $TMPDIR/run${i}/IceFinal_${i}_allTree.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/IceFinal_allTree_${gen}_${num}_${i}.root
    mv $TMPDIR/run${i}/IceFinal_${i}_passTree0.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/IceFinal_passTree_${gen}_${num}_${i}_0.root
done

# move pueoout for debugging
mv peuoout.txt $PSIMDIR/outputs/${RunName}/${gen}_outputs/${SLURM_ARRAY_TASK_ID}/run${run_num}

echo $gen > $TMPDIR/${num}_${seed}.txt
echo $num >> $TMPDIR/${num}_${seed}.txt
echo $seed >> $TMPDIR/${num}_${seed}.txt

# move the flag file
mv $TMPDIR/${num}_${seed}.txt $WorkingDir/Run_Outputs/$RunName/PUEOFlags

cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags

cp ${num}_${seed}.txt.* ${num}_${seed}.txt
rm ${num}_${seed}.txt.*

