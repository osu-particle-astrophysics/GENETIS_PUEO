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
indiv=$1
gen=$2
NPOP=$3
WorkingDir=$4
RunName=$5
XmacrosDir=$6
XFProj=$7
GeoFactor=$8
num_keys=$9
NSECTIONS=${10}
XFCOUNT=${11}

#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/

## Lines for output.xmacro files ##
## I've commented these out because we needed to put them inside of a loop in the macroskeleton ##
## Currently these are hardcoded outputmacroskeleton_GPU.xmacro ##
#line1='var query = new ResultQuery();'
#line2='///////////////////////Get Theta and Phi Gain///////////////'
#line3='query.projectId = App.getActiveProject().getProjectDirectory();'
freqlist="20000 21000 22000 23000 24000 25000 26000 27000 28000 29000 30000 31000 32000 33000 34000 35000 36000 37000 38000 39000 40000 41000 42000 43000 44000 45000 46000 47000 48000 49000 50000 51000 52000 53000 54000 55000 56000 57000 58000 59000 60000 61000 62000 63000 64000 65000 66000 67000 68000 69000 70000 71000 72000 73000 74000 75000 76000 77000 78000 79000 80000 81000 82000 83000 84000 85000 86000 87000 88000 89000 90000 91000 92000 93000 94000 95000 96000 97000 98000 99000 100000 101000 102000 103000 104000 105000 106000 107000 108000 109000 110000 111000 112000 113000 114000 115000 116000 117000 118000 119000 120000 121000 122000 123000 124000 125000 126000 127000 128000 129000 130000 131000 132000 133000 134000 135000 136000 137000 138000 139000 140000 141000 142000 143000 144000 145000 146000 147000 148000 149000 150000"
#The list of frequencies, scaled up by 100 to avoid float operation errors in bash
#we have to wait to change the frequencies since we're going to be changing them as we append them to simulation_PEC.xmacro (which is removed below before being remade)

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
# When we use the sed command, anything can be the delimiter between each of the arguments; usually, we use /, but since there are / in the thing we are trying to substitute in ($WorkingDir), we need to use a different delimiter that doesn't appear there


module load xfdtd/7.10.2.3 #7.9.2.2
xfdtd $XFProj --execute-macro-script=$XmacrosDir/output.xmacro || true --splash=false

#Xvnc :5 &  DISPLAY=:5 xfdtd $XFProj --execute-macro-script=$XmacrosDir/simulation_PEC.xmacro || true


cd $WorkingDir/Antenna_Performance_Metric
for i in `seq $(($gen*$XFCOUNT + $indiv)) $(($gen*$XFCOUNT+$XFCOUNT))`
do
	pop_ind_num=$(($i - $gen*$XFCOUNT))
	for freq in `seq 1 131`
	do
		mv ${i}_${freq}.uan "$WorkingDir"/Run_Outputs/$RunName/${gen}_${pop_ind_num}_${freq}.uan
	done
done


#I'm going to move the detector photos to the run directory
cd $XmacrosDir
chmod 775 *

#FinalIndex=$(($NPOP-1))

mkdir -m775 $WorkingDir/Run_Outputs/$RunName/Antenna_Images/${gen}
for i in `seq $NPOP`
do
	mv antenna_images/${i}_detector.png $WorkingDir/Run_Outputs/$RunName/Antenna_Images/${gen}/${i}_detector.png
done

#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/
