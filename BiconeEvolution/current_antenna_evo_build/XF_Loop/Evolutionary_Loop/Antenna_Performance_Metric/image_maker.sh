#!/bin/bash
#
## Files name: image_maker.sh
## Authors: Bailey Stephens (stephens.761), Audrey Zinn
## Date: 2/5/2022
## Purpose: 
##      This script serves two functions: run a Python script that identifies
##      the best-, middle-, and worst-performing detectors in a generation, and
##      and saves those photos into a labelled folder.
##
## Instructions:
##          To run, give the following arguments:
##                  .uan source directory, photo source directory, destination directory, generation #
##
## Example:
##          ./image_maker.sh fitnessSourceDir photoSourceDir destinationDir 23
##                  This will use fitness scores for generation 23 from fitnessSourceDir
##                  and save the best-, middle-, and worst-performing detector
##                  photos from photoSourceDir in destinationDir
#
fitnessSourceDir=$1
photoSourceDir=$2
destinationDir=$3
gen=$4
WorkingDir=$5
RunName=$6
NPOP=$7
PSIMDIR=$8
exp=$9
SYMMETRY=${10}
#
#echo $fitnessSourceDir
#echo $photoSourceDir
#echo $destinationDir
#echo $RunName
#
cd $WorkingDir/Antenna_Performance_Metric
### Creates a temporary file to hold the index of the best detector
touch temp_best.csv
touch temp_mid.csv
touch temp_worst.csv
#
echo "touched temp files"
### Runs a Python script that identifies the index of the best detector
python3 image_finder.py $fitnessSourceDir $gen
#
echo "found best detectors"
### Stores the indices of the best, middle, and worst individuals in variables
max_index=`cat temp_best.csv`
mid_index=`cat temp_mid.csv`
min_index=`cat temp_worst.csv`
#
### Makes directory for this generation's photos, then moves the indicated photos into it
#make sure the correct python is loaded (default 2.7)
module load python/3.7-2019.10
module unload python/3.7-2019.10
source $PSIMDIR/set_env.sh
#source $PSIMDIR/set_env.sh

echo "starting Physics of Results Plots"
#ls -alrt

#echo "max index: $max_index"
#echo "exp: $exp"

python physicsOfResultsPUEO.py $WorkingDir/Run_Outputs/$RunName/Root_Files/${gen}_Root_Files $WorkingDir/Run_Outputs/$RunName/Generation_Data $max_index $exp

echo "finished Physics of Results Plots"

echo "copying best detector photos"

mkdir -p ${destinationDir}/LabelledDetectorPhotos/${gen}_labelled_photos
cp ${photoSourceDir}/${max_index}_detector.png ${destinationDir}/LabelledDetectorPhotos/${gen}_labelled_photos/${gen}_${max_index}_detector_max.png
cp ${photoSourceDir}/${mid_index}_detector.png ${destinationDir}/LabelledDetectorPhotos/${gen}_labelled_photos/${gen}_${mid_index}_detector_mid.png
cp ${photoSourceDir}/${min_index}_detector.png ${destinationDir}/LabelledDetectorPhotos/${gen}_labelled_photos/${gen}_${min_index}_detector_min.png
#

# gainNum corresponds to the frequency in which we want to see the gain pattern
# A value X corresponds to (200 MHz + 10 MHz * X) frequency
freqNum=11

mkdir -m775 $WorkingDir/Run_Outputs/$RunName/Gain_Plots/${gen}_Gain_Plots

module load python/3.7-2019.10

echo "starting gain plots"

python polar_plotter_v2.py $WorkingDir/Run_Outputs/$RunName/uan_files/${gen}_uan_files $WorkingDir/Run_Outputs/$RunName/Gain_Plots/${gen}_Gain_Plots $freqNum $NPOP $gen $SYMMETRY

echo "finished gain plots"
#
### Removes temporary files
rm temp_best.csv
rm temp_mid.csv
rm temp_worst.csv
