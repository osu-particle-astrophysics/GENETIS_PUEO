#!/bin/bash

individual_number=$1
WorkingDir=$2   
XmacrosDir=$3
XFProj=$4
RunName=$5
gen=$6
NPOP=$7
PSIMDIR=$8

cd $XmacrosDir

rm -f output.xmacro
touch output.xmacro
echo "var NPOP = 1;" >> output.xmacro
echo "for (var k = $individual_number; k <= $individual_number; k++){" >> output.xmacro

cat shortened_outputmacroskeleton.txt >> output.xmacro

sed -i "s+fileDirectory+${WorkingDir}+" output.xmacro

module load xfdtd/7.9.2.2
module load cuda

xfdtd $XFProj --execute-macro-script=$XmacrosDir/output.xmacro || true --splash=false

echo "finished output.xmacro"

cd $WorkingDir/Antenna_Performance_Metric

#echo "files in Antenna_Performance_Metric:"
#ls

for freq in $(seq 1 131)
do
	mv ${individual_number}_${freq}.uan $WorkingDir/Run_Outputs/$RunName/${gen}_${individual_number}_${freq}.uan
done


module load python/3.6-conda5.2
python XFintoPUEO_Symmetric.py $NPOP $WorkingDir $RunName $gen $WorkingDir/Test_Outputs --single=$individual_number

chmod 777 $WorkingDir/Test_Outputs/*

mkdir -p -m775 $WorkingDir/Run_Outputs/$RunName/uan_files/${gen}_uan_files/$individual_number
mv $WorkingDir/Run_Outputs/$RunName/${gen}_${individual_number}_*.uan $WorkingDir/Run_Outputs/$RunName/uan_files/${gen}_uan_files/$individual_number

cd $WorkingDir/Test_Outputs
# mod individual_number by NPOP
indiv_in_gen=$((individual_number % NPOP))
run_num=$((NPOP * gen + indiv_in_gen))
cp hh_0_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_0_Toyon${run_num}
cp hv_0_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hv_0_Toyon${run_num}
cp vv_0_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_0_Toyon${run_num}
cp vh_0_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vh_0_Toyon${run_num}
cp hh_el_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_el_Toyon${run_num}
cp hh_az_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_az_Toyon${run_num}
cp vv_el_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_el_Toyon${run_num}
cp vv_az_${gen}_${individual_number} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_az_Toyon${run_num}

cd $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated
#ls

chmod -R 777 $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/* 2>/dev/null

echo "Moved individual ${individual_number}'s gain files to pueoSim directory"
echo " "
echo " "
echo " "
