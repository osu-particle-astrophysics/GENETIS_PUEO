#!/bin/bash
## We want to submit the XFsolver as a job array to GPUs
## We'll submit up to 4 at a time (based on number of XF keys)
## Here's the submission command:
## sbatch --array=1-$NPOP%$batch_size --export=ALL,(variables) GPU_XF_job.sh
#SBATCH -A PAS1960
#SBATCH -t 3:00:00
#SBATCH -N 1
#SBATCH -n 40
#SBATCH -G 2
#SBATCH --output=Run_Outputs/%x/XF_Outputs/XF_%a.output
#SBATCH --error=Run_Outputs/%x/XF_Errors/XF_%a.error
#SBATCH --mem-per-gpu=178gb

module load xfdtd/7.9.2.2
module load cuda

## We need to get the individual number
## This will be based on the number in the array
if [ $SYMMETRY -eq 0 ]
then
	individual_number=$((${gen}*${NPOP}*2+${SLURM_ARRAY_TASK_ID}))
else
	individual_number=$((${gen}*${NPOP}+${SLURM_ARRAY_TASK_ID}))
fi

## Based on the individual number, we need the right parent directory
## This involves checking the individual number being submitted
## This is complicated--the individual number should be the number in the job array
## To do this, we'll have to call the array number (see above)
if [ $individual_number -lt 10 ]
then
	indiv_dir_parent=$XFProj/Simulations/00000$individual_number/
elif [[ $individual_number -ge 10 && $individual_number -lt 100 ]]
then
	indiv_dir_parent=$XFProj/Simulations/0000$individual_number/
elif [[ $individual_number -ge 100 && $individual_number -lt 1000 ]]
then
	indiv_dir_parent=$XFProj/Simulations/000$individual_number/
elif [ $individual_number -ge 1000 ]
then
	indiv_dir_parent=$XFProj/Simulations/00$individual_number/
fi

## Now we need to get into the Run0001 directory inside the parent directory
indiv_dir=$indiv_dir_parent/Run0001

cd $indiv_dir
xfsolver --use-xstream=true --xstream-use-number=2 --num-threads=2 -v

echo "finished XF solver"

cd $TMPDIR
mkdir -m775 $TMPDIR/Antenna_Performance_Metric

touch output.xmacro
echo "var NPOP = 1;" >> output.xmacro
echo "for (var k = $individual_number; k <= $individual_number; k++){" >> output.xmacro

cat $XmacrosDir/shortened_outputmacroskeleton.txt >> output.xmacro

sed -i "s+fileDirectory+${TMPDIR}+" output.xmacro

xfdtd $XFProj --execute-macro-script=$TMPDIR/output.xmacro || true --splash=false

echo "finished output.xmacro"

cd $TMPDIR/Antenna_Performance_Metric

echo "files in Antenna_Performance_Metric:"
ls

for freq in `seq 1 131`
do
	mv ${individual_number}_${freq}.uan $WorkingDir/Run_Outputs/$RunName/${gen}_${individual_number}_${freq}.uan
done

cp $WorkingDir/Antenna_Performance_Metric/XFintoPUEO_Symmetric.py $TMPDIR/Antenna_Performance_Metric/XFintoPUEO_Symmetric.py

module load python/3.6-conda5.2
mkdir -m775 $TMPDIR/gain_files
python XFintoPUEO_Symmetric.py $NPOP $WorkingDir $RunName $gen $TMPDIR/gain_files --single=$individual_number

mkdir -p -m775 $WorkingDir/Run_Outputs/$RunName/uan_files/${gen}_uan_files/$individual_number
cp $WorkingDir/Run_Outputs/$RunName/${gen}_${individual_number}_*.uan $WorkingDir/Run_Outputs/$RunName/uan_files/${gen}_uan_files/$individual_number

cd $TMPDIR/gain_files
run_num=$((NPOP * gen + individual_number))
cp hh_0_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_0_Toyon${run_num}
cp hv_0_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hv_0_Toyon${run_num}
cp vv_0_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_0_Toyon${run_num}
cp vh_0_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vh_0_Toyon${run_num}
cp hh_el_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_el_Toyon${run_num}
cp hh_az_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_az_Toyon${run_num}
cp vv_el_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_el_Toyon${run_num}
cp vv_az_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_az_Toyon${run_num}

chmod -R 777 $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/* 2>/dev/null

cd $WorkingDir/Run_Outputs/$RunName/TMPGPUFlags

echo "done"

echo "The GPU job is done!" >> Part_B_GPU_Flag_${individual_number}.txt 
