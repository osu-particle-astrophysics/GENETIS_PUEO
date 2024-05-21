#!/bin/bash
##############################################################
# Run the output xmacro for a single individual finished in XF
##############################################################
individual_number=$1
WorkingDir=$2   
RunName=$3
gen=$4
source $WorkingDir/Run_Outputs/$RunName/setup.sh

indiv_in_pop=$((individual_number - 1))
indiv_in_pop=$((indiv_in_pop % NPOP))

cd $XmacrosDir
mkdir -p -m775 $RunDir/uan_files/${gen}_uan_files/$indiv_in_pop
mkdir -p -m775 $RunDir/Gain_Files/$gen/$indiv_in_pop

# Remove the output xmacro if it already exists
rm -f $RunXMacrosDir/output.xmacro

# Create the output xmacro
echo "var NPOP = 1;" >> $RunXMacrosDir/output.xmacro
echo "var popsize = $NPOP;" >> $RunXMacrosDir/output.xmacro
echo "var workingdir = \"$WorkingDir\";" >> $RunXMacrosDir/output.xmacro
echo "var run_name = \"$RunName\";" >> $RunXMacrosDir/output.xmacro
echo "var rundir = workingdir + \"/Run_Outputs/\" + run_name;" >> $RunXMacrosDir/output.xmacro
echo "var gen = $gen;" >> $RunXMacrosDir/output.xmacro
echo "for (var k = $individual_number; k <= $individual_number; k++){" >> $RunXMacrosDir/output.xmacro
cat shortened_outputmacroskeleton.js >> $RunXMacrosDir/output.xmacro


# Run the output xmacro
module load xfdtd/7.10.2.3 #7.9.2.2
module load cuda

xfdtd $XFProj --execute-macro-script=$RunXMacrosDir/output.xmacro || true --splash=false

echo "finished output.xmacro"

# Create the gain files
cd $WorkingDir/Antenna_Performance_Metric

#indiv_in_pop=$((individual_number - 1))
#indiv_in_pop=$((indiv_in_pop % NPOP))
echo "indiv_in_pop: $indiv_in_pop"
echo "individual_number: $individual_number"

module load python/3.6-conda5.2

python XFintoPUEO_Symmetric.py $NPOP $WorkingDir $RunName $gen $RunDir/Gain_Files/$gen/$indiv_in_pop --single=$indiv_in_pop

cd $RunDir/Gain_Files

chmod -R 777 $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/* 2>/dev/null

echo "Moved individual ${indiv_in_pop}'s gain files to pueoSim directory"
echo " "
echo " "
echo " "
