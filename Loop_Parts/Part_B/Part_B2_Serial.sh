#!/bin/bash

########    XF Simulation Software (B)     ########################################################################################## 
#
#
#     1. Prepares output.xmacro with generic parameters such as :: 
#             I. Antenna type
#             II. Population number
#             III. Grid size
#
#
#     2. Prepares simulation_PEC.xmacro with information such as:
#             I. Each generation antenna parameters
#
#
#     3. Runs XF and loads XF with both xmacros. 
#
#
###################################################################################################################################### 
# varaibles
WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/RunData/$RunName/setup.sh

## We need the loop to pause until all the XF jobs are done
## To do this, we'll just count the flag files

cd $WorkingDir/Run_Outputs/$RunName/GPUFlags/
flag_files=$(ls | wc -l) #$(ls -l --file-type | grep -v '/$' | wc -l)

#Now we need to repeat that for the rest of the jobs
while [[ $flag_files -lt $XFCOUNT ]] #we need to loop until flag_files reaches totPop
do
	sleep 1m
	echo $flag_files
	flag_files=$(ls | wc -l) #$(ls -l --file-type | grep -v '/$' | wc -l)
done

rm -f $WorkingDir/Run_Outputs/$RunName/GPUFlags/*

echo $flag_files
echo "Done!"

# First, remove the old .xmacro files
#when do that, we end up making the files only readable; we should just overwrite them
#alternatively, we can just set them as rwe when the script makes them
cd $XmacrosDir
 
rm -f output.xmacro

#echo "var m = $i;" >> output.xmacro
echo "var NPOP = $NPOP;" >> output.xmacro
echo "for (var k = $(($gen * $XFCOUNT + 1)); k <= $(($gen * $XFCOUNT + $XFCOUNT)); k++){" >> output.xmacro

if [ $NSECTIONS -eq 1 ] # if 1, then the cone is symmetric
then
	cat shortened_outputmacroskeleton.txt >> output.xmacro
else
	cat shortened_outputmacroskeleton_Asym.txt >> output.xmacro
fi


sed -i "s+fileDirectory+${WorkingDir}+" output.xmacro

module load xfdtd/7.10.2.3 #7.9.2.2
xfdtd $XFProj --execute-macro-script=$XmacrosDir/output.xmacro || true --splash=false


cd $WorkingDir/Antenna_Performance_Metric
for i in $(seq $(($gen*$XFCOUNT + $indiv)) $(($gen*$XFCOUNT+$XFCOUNT)))
do
	pop_ind_num=$(($i - $gen*$XFCOUNT))
	for freq in $(seq 1 131)
	do
		mv ${i}_${freq}.uan "$WorkingDir"/Run_Outputs/$RunName/${gen}_${pop_ind_num}_${freq}.uan
	done
done

#I'm going to move the detector photos to the run directory
cd $XmacrosDir
chmod 775 *

mkdir -m775 $WorkingDir/Run_Outputs/$RunName/Antenna_Images/${gen}
for i in $(seq $NPOP)
do
	mv antenna_images/${i}_detector.png $WorkingDir/Run_Outputs/$RunName/Antenna_Images/${gen}/${i}_detector.png
done


