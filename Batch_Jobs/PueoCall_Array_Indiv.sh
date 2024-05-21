#!/bin/bash
## This job is designed to be submitted by an array batch submission
## Here's the command:
## sbatch --array=1-NPOP*SEEDS%max --export=ALL,(variables) PueoCall_Array.sh
#SBATCH -A PAS1960
#SBATCH -t 01:00:00
#SBATCH -N 1
#SBATCH -n 40
#SBATCH --output=Run_Outputs/%x/Errs_And_Outs/PUEO_Outputs/PUEOsim_%a.output
#SBATCH --error=Run_Outputs/%x/Errs_And_Outs/PUEO_Errors/PUEOsim_%a.error

#variables
#gen=$1
#WorkingDir=$2
#RunName=$3
#NNT_per_sim=$4
#indiv=$5
#max_jobs=$6

source $WorkingDir/Run_Outputs/$RunName/setup.sh

echo "Num jobs: ${num_jobs}"
echo "NNT: ${NNT}"
echo "NNT per sim: ${NNT_per_sim}"
echo "indiv: ${indiv}"


threads=40

seed=$((SLURM_ARRAY_TASK_ID-1))
num=$indiv

# run number is the unique identifier for each pueoSim Process
# 40 processes are run per generation per seed
run_num=$(((NPOP * gen + num) * 10000 + seed * 40))

echo "run_num: $run_num"

# set up environment
cd $PSIMDIR
source set_env.sh

# copy simulation exe to TMPDIR
cp build/components/pueoSim/simulatePueo $TMPDIR/simulatePueo
cp components/pueoSim/config/pueo.conf $TMPDIR/pueo.conf

cd $TMPDIR

echo "Running PSIM"
for ((i=$run_num; i<$((threads + run_num)); i++))
do
    # Run 40 processes of pueoSim 
    echo "starting pueoSim ${i}"
    touch pueoout${i}.txt
    ./simulatePueo -i pueo.conf -o $TMPDIR -r $i -n $NNT_per_sim -e $exp -g "$gen" -d "$RunDir" -m "$num" > pueoout${i}.txt &
done

echo "started PSIMs"
wait
echo "PSIMS finished"

mkdir -p -m775 $RunDir/Root_Files/${gen}_Root_Files/$num
mkdir -p -m775 $RunDir/Flags/PUEOFlags/$num

# move the root files
for ((i=$run_num; i<$((threads + run_num)); i++))
do
    mv $TMPDIR/run${i}/IceFinal_${i}_skimmed.root $RunDir/Root_Files/${gen}_Root_Files/$num/IceFinal_skimmed_${gen}_${num}_${i}.root
done
mv *.txt $RunDir/Errs_And_Outs/psimouts

echo $gen > $TMPDIR/${run_num}.txt
echo $num >> $TMPDIR/${run_num}.txt
echo $seed >> $TMPDIR/${run_num}.txt

# move the flag file
mv $TMPDIR/${run_num}.txt $RunDir/Flags/PUEOFlags/$num

cd $RunDir/Flags/PUEOFlags/$num

# if there are $num_jobs flags in the PUEOFlags/$num directory, run the root analysis
flag_count=$(ls | wc -l)
echo $flag_count
echo $num_jobs


if [ $flag_count -eq $num_jobs ]
then
    echo "--------------- running rootAnalysis ----------------------"
    module load python/3.6-conda5.2
    module unload python/3.6-conda5.2
    source $PSIMDIR/set_env.sh
    cd $WorkingDir/Antenna_Performance_Metric
    mkdir -p -m775 $RunDir/Generation_Data/temp_gen_files/$num 2> /dev/null
    python rootAnalysis.py $gen $num $exp $WorkingDir/Run_Outputs/${RunName}/Generation_Data/temp_gen_files/$num $RunName $WorkingDir $NNT_per_sim
    touch $RunDir/Flags/ROOTFlags/${num}.txt
    echo "finished rootAnalysis" >> $RunDir/Flags/ROOTFlags/${num}.txt
else 
    echo "Not all flags are present"
fi