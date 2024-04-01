#!/bin/bash

individual_number=$1
WorkingDir=$2   
RunName=$3
gen=$4


source $WorkingDir/RunData/$RunName/setup.sh

cd $XmacrosDir

rm -f output.xmacro
touch output.xmacro
echo "var NPOP = 1;" >> output.xmacro
echo "for (var k = $individual_number; k <= $individual_number; k++){" >> output.xmacro

cat shortened_outputmacroskeleton.txt >> output.xmacro

sed -i "s+fileDirectory+${WorkingDir}+" output.xmacro

module load xfdtd/7.10.2.3 #7.9.2.2
module load cuda

xfdtd $XFProj --execute-macro-script=$XmacrosDir/output.xmacro || true --splash=false

echo "finished output.xmacro"

cd $WorkingDir/Antenna_Performance_Metric

#echo "files in Antenna_Performance_Metric:"
#ls

indiv_in_pop=$((individual_number - 1))
indiv_in_pop=$((indiv_in_pop % NPOP))
echo "indiv_in_pop: $indiv_in_pop"
echo "individual_number: $individual_number"

mkdir -p -m775 $WorkingDir/Run_Outputs/$RunName/uan_files/${gen}_uan_files/$indiv_in_pop

for freq in $(seq 1 131)
do
	mv ${individual_number}_${freq}.uan $WorkingDir/Run_Outputs/$RunName/uan_files/${gen}_uan_files/$indiv_in_pop/${gen}_${indiv_in_pop}_${freq}.uan
done


module load python/3.6-conda5.2
python XFintoPUEO_Symmetric.py $NPOP $WorkingDir $RunName $gen $WorkingDir/Test_Outputs --single=$indiv_in_pop

chmod 777 $WorkingDir/Test_Outputs/* 2>/dev/null

cd $WorkingDir/Test_Outputs
# mod individual_number by NPOP
run_num=$((NPOP * gen + indiv_in_pop))
echo "run_num: $run_num"
cp hh_0_${gen}_${indiv_in_pop} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_0_Toyon${run_num}
cp hv_0_${gen}_${indiv_in_pop} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hv_0_Toyon${run_num}
cp vv_0_${gen}_${indiv_in_pop} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_0_Toyon${run_num}
cp vh_0_${gen}_${indiv_in_pop} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vh_0_Toyon${run_num}
cp hh_el_${gen}_${indiv_in_pop} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_el_Toyon${run_num}
cp hh_az_${gen}_${indiv_in_pop} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_az_Toyon${run_num}
cp vv_el_${gen}_${indiv_in_pop} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_el_Toyon${run_num}
cp vv_az_${gen}_${indiv_in_pop} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_az_Toyon${run_num}

cd $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated
#ls

chmod -R 777 $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/* 2>/dev/null

echo "Moved individual ${indiv_in_pop}'s gain files to pueoSim directory"
echo " "
echo " "
echo " "
