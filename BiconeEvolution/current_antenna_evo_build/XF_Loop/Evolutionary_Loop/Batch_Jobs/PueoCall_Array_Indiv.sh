#!/bin/bash
## This job is designed to be submitted by an array batch submission
## Here's the command:
## sbatch --array=1-NPOP*SEEDS%max --export=ALL,(variables) PueoCall_Array.sh
#SBATCH -A PAS1960
#SBATCH -t 00:30:00
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

seed=$((SLURM_ARRAY_TASK_ID-1))
num=$indiv

# run number is the unique identifier for each pueoSim Process
# 40 processes are run per generation per seed
run_num=$(((NPOP * gen + num) * 10000 + seed * 40))


# set up environment
cd $PSIMDIR
source set_env.sh

# copy simulation exe to TMPDIR
cp pueoBuilder/build/components/pueoSim/simulatePueo $TMPDIR/simulatePueo
cp pueoBuilder/components/pueoSim/config/pueo.conf $TMPDIR/pueo.conf

cd $TMPDIR

echo "Running PSIM"
for ((i=$run_num; i<$((threads + run_num)); i++))
do
    # Run 40 processes of pueoSim 
    touch pueoout${i}.txt
    ./simulatePueo -i pueo.conf -o $TMPDIR -r $i -n $NNT -e $Exp > pueoout${i}.txt &
done

echo "started PSIMs"
wait
echo "PSIMS finished"

mkdir -p -m775 $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/$num
mkdir -p -m775 $WorkingDir/Run_Outputs/$RunName/PUEOFlags/$num
# move the root files
for ((i=$run_num; i<$((threads + run_num)); i++))
do
    mv $TMPDIR/run${i}/IceFinal_${i}_skimmed.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/$num/IceFinal_skimmed_${gen}_${num}_${i}.root
    #mv $TMPDIR/run${i}/IceFinal_${i}_allTree.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/$num/IceFinal_allTree_${gen}_${num}_${i}.root
    #mv $TMPDIR/run${i}/IceFinal_${i}_passTree0.root $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files/IceFinal_passTree_${gen}_${num}_${i}_0.root
    #mkdir -p -m775 $PSIMDIR/outputs/${RunName}/${gen}_outputs/${SLURM_ARRAY_TASK_ID}/run${run_num}
    #mv peuoout${i}.txt $PSIMDIR/outputs/${RunName}/${gen}_outputs/${SLURM_ARRAY_TASK_ID}/run${run_num}
done

echo $gen > $TMPDIR/${run_num}.txt
echo $num >> $TMPDIR/${run_num}.txt
echo $seed >> $TMPDIR/${run_numd}.txt

# move the flag file
mv $TMPDIR/${run_num}.txt $WorkingDir/Run_Outputs/$RunName/PUEOFlags/$num

cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags/$num

cp ${run_num}.txt.* ${run_num}.txt
rm ${run_num}.txt.*

#if there are 49 flags in the PUEOFlags/$num directory, run the root analysis
flag_count=$(ls | wc -l)
if [ $flag_count -eq 49 ]
then
    module load python/3.6-conda5.2
    module unload python/3.6-conda5.2
    source $PSIMDIR/set_env.sh
    cd $WorkingDir/Antenna_Performance_Metric
    mkdir -p -m775 $WorkingDir/Run_Outputs/$RunName/Generation_Data/$num
    python rootAnalysis.py $gen $num $Exp $WorkingDir/Run_Outputs/${RunName}/Generation_Data/$num $RunName $WorkingDir $NNT
    echo "finished rootAnalysis" >> $WorkingDir/Run_Outputs/$RunName/ROOTFlags/${num}.txt
fi