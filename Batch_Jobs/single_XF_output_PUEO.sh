#!/bin/bash
##############################################################
# Run the output xmacro for a single individual finished in XF
##############################################################
individual_number=$1
WorkingDir=$2   
RunName=$3
gen=$4
source $WorkingDir/Run_Outputs/$RunName/setup.sh

cd $XmacrosDir
mkdir -p -m775 $WorkingDir/Run_Outputs/$RunName/uan_files/${gen}_uan_files/$indiv_in_pop

# Remove the output xmacro if it already exists
rm -f output.xmacro

# Create the output xmacro
echo "var NPOP = 1;" >> output.xmacro
echo "var workingdir = \"$WorkingDir\";" >> output.xmacro
echo "var run_name = \"$RunName\";" >> output.xmacro
echo "var rundir = workingdir + \"/Run_Outputs/\" + run_name;" >> output.xmacro
echo "var gen = $gen;" >> output.xmacro
echo "for (var k = $individual_number; k <= $individual_number; k++){" >> output.xmacro
cat shortened_outputmacroskeleton.js >> output.xmacro


# Run the output xmacro
module load xfdtd/7.10.2.3 #7.9.2.2
module load cuda

xfdtd $XFProj --execute-macro-script=$XmacrosDir/output.xmacro || true --splash=false

echo "finished output.xmacro"


# Create the gain files
cd $WorkingDir/Antenna_Performance_Metric

indiv_in_pop=$((individual_number - 1))
indiv_in_pop=$((indiv_in_pop % NPOP))
echo "indiv_in_pop: $indiv_in_pop"
echo "individual_number: $individual_number"


module load python/3.6-conda5.2

python XFintoPUEO_Symmetric.py $NPOP $WorkingDir $RunName $gen $WorkingDir/Run_Outputs/$RunName/GainFiles --single=$indiv_in_pop

cd $WorkingDir/Run_Outputs/$RunName/Gain_Files

# Copy gain files into pueosim directory
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

chmod -R 777 $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/* 2>/dev/null

echo "Moved individual ${indiv_in_pop}'s gain files to pueoSim directory"
echo " "
echo " "
echo " "
