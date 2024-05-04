#!/bin/bash
##### Script runs the plots that need specific antenna indices #######
#
#       Get Images of the Best, Mid, and Worst Detectors
#
#       Run the Polar Plotter
#
#       Run the Physics of Results Plotter
#
######################################################################
module load python/3.7-2019.10

WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/Run_Outputs/$RunName/setup.sh


# Define and Make Directories
fitnessSourceDir=$RunDir/Generation_Data
photoSourceDir=$RunDir/Antenna_Images/${gen}
destinationDir=$RunDir
mkdir -m775 $RunDir/Plots/Gain_Plots/${gen}_Gain_Plots
mkdir -p ${destinationDir}/LabelledDetectorPhotos/${gen}_labelled_photos

cd $WorkingDir/Antenna_Performance_Metric

# Get the indices of the best, mid, and worst detectors
indices=$(python index_finder.py $fitnessSourceDir $gen)
best=$(echo $indices | cut -d' ' -f1)
mid=$(echo $indices | cut -d' ' -f2)
worst=$(echo $indices | cut -d' ' -f3)

### Makes directory for this generation's photos, then moves the indicated photos into it
echo "copying best detector photos"
cp ${photoSourceDir}/${best}_detector.png ${destinationDir}/LabelledDetectorPhotos/${gen}_labelled_photos/${gen}_${best}_detector_max.png
cp ${photoSourceDir}/${mid}_detector.png ${destinationDir}/LabelledDetectorPhotos/${gen}_labelled_photos/${gen}_${mid}_detector_mid.png
cp ${photoSourceDir}/${worst}_detector.png ${destinationDir}/LabelledDetectorPhotos/${gen}_labelled_photos/${gen}_${worst}_detector_min.png


# gainNum corresponds to the frequency in which we want to see the gain pattern
# A value X corresponds to (200 MHz + 10 MHz * X) frequency
freqNum=11

echo "starting gain plots"

#python polar_plotter_v2.py $RunDir/uan_files/${gen}_uan_files $RunDir/Plots/Gain_Plots/${gen}_Gain_Plots $freqNum $NPOP $gen $SYMMETRY

echo "finished gain plots"



module unload python/3.7-2019.10
source $PSIMDIR/set_env.sh

echo "starting Physics of Results Plots"

#python physicsOfResultsPUEO.py $RunDir/Root_Files/${gen}_Root_Files $RunDir/Plots/Generation_${gen} $max_index $exp

echo "finished Physics of Results Plots"
