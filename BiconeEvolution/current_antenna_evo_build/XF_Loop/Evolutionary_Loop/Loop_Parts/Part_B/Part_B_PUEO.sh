########### XF Simulation Software #######################################
#
#      This script will:
#
#      1. Prepare output.xmacro with genetic parameters such as:
#      		I. Antenna Type
#			II. Population number
#			II. Grid size
#
#	2. Prepares simulation_PEC.xmacro with information such as:
#			I. Each generation antenna parameters
#
#	3. Runs XF and loads XF with both xmacros.
#
###########################################################################
# variables
indiv=$1
gen=$2
NPOP=$3
WorkingDir=$4
RunName=$5
XmacrosDir=$6
XFProj=$7
GeoFactor=$8
num_keys=$9
SYMMETRY=${10}
XFCOUNT=${11}

echo $SYMMETRY
echo $XFCOUNT

## If we're in the 0th generation, we need to make the directory for the XF jobs
if [ ${gen} -eq 0 ]
then
	mkdir -m775 $WorkingDir/Run_Outputs/$RunName/XF_Outputs
	mkdir -m775 $WorkingDir/Run_Outputs/$RunName/XF_Errors
fi

# we need to check if directories we're going to write to already exist
# this would occur if already ran this part but went back to rerun the same generation
# the directories are the simulation directories from gen*NPOP+1 to gen*NPOP+10
# Note that for PUEO, we need TWO XF simulation per individual
# This is because we need to do the VPol and Hpol
for i in `seq 1 $XFCOUNT`
do
        # first, declare the number of the individual we are checking
	individual_number=$(($gen*$XFCOUNT + $i))

        # next, write the potential directories corresponding to that individual
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

        # now delete the directory if it exists
	if [ -d $indiv_dir_parent ]
	then
		rm -rf $indiv_dir_parent
	fi

done

# the number of the next simulation directory is held in a hidden file in the Simulations directory 
# the file is names .nextSimulationNumber

if [[ $gen -ne 0 ]]
then
	echo $(($gen*$XFCOUNT + 1)) > $XFProj/Simulations/.nextSimulationNumber
fi


chmod -R 777 $XmacrosDir

cd $XmacrosDir
# POSSIBLY CHANGE IF THIS IS ARA SPECIFIC
#freqlist="8333 10000 11667 13333 15000 16667 18334 20000 21667 23334 25000 26667 28334 30000 31667 33334 35000 36667 38334 40001 41667 43334 45001 46667 48334 50001 51668 53334 55001 56668 58334 60001 61668 63334 65001 66668 68335 70001 71668 73335 75001 76668 78335 80001 81668 83335 85002 86668 88335 90002 91668 93335 95002 96668 98335 100000 101670 103340 105000 106670"
#For PUEO
freqlist="20000 21000 22000 23000 24000 25000 26000 27000 28000 29000 30000 31000 32000 33000 34000 35000 36000 37000 38000 39000 40000 41000 42000 43000 44000 45000 46000 47000 48000 49000 50000 51000 52000 53000 54000 55000 56000 57000 58000 59000 60000 61000 62000 63000 64000 65000 66000 67000 68000 69000 70000 71000 72000 73000 74000 75000 76000 77000 78000 79000 80000 81000 82000 83000 84000 85000 86000 87000 88000 89000 90000 91000 92000 93000 94000 95000 96000 97000 98000 99000 100000 101000 102000 103000 104000 105000 106000 107000 108000 109000 110000 111000 112000 113000 114000 115000 116000 117000 118000 119000 120000 121000 122000 123000 124000 125000 126000 127000 128000 129000 130000 131000 132000 133000 134000 135000 136000 137000 138000 139000 140000 141000 142000 143000 144000 145000 146000 147000 148000 149000 150000"
#get rid of the simulation_PEC.xmacro that already exists
rm -f simulation_PEC.xmacro

echo "var NPOP = $NPOP;" > simulation_PEC.xmacro
echo "var indiv = $indiv;" >> simulation_PEC.xmacro
chmod -R 775 simulation_PEC.xmacro
#now we can write the frequencies to simulation_PEC.xmacro
#now let's change our frequencies by the scale factor (and then back down by 100)

#first we need to declare the variable for the frequency lists
#the below commands write the frequency scale factor and "var freq =" to simulation_PEC.xmacro
echo "//Factor of $GeoFactor frequency" >> simulation_PEC.xmacro
echo "var freq " | tr "\n" "=" >> simulation_PEC.xmacro

###CHANGE IF FREQ LIST IS DIFFERENT FOR PUEO
#here's how we change our frequencies and put them in simulation_PEC.xmacro
for i in $freqlist; #iterating through all values in our list
do
	if [ $i -eq 20000 ] #we need to start with a bracket
	then
		echo " " | tr "\n" "[" >> simulation_PEC.xmacro
                #whenever we append to a file, it adds what we append to a new line at the end
                #the tr command replaces the new line (\n) with a bracket (there's a space at the start; that will separate the = from the list by a space)
	fi

        #now we're ready to start appending our new frequencies
        #we start by changing our frequencies by the scale factor; we'll call this variable k
	k=$(($GeoFactor*$i))
        #now we'll append our frequencies
        #the frequencies we're appending are divided by 100, since the original list was scaled up by 100
        #IT'S IMPORTANT TO DO IT THIS WAY
        #we can't just set k=$((scale*$i/100)) because of how bash handles float operations
        #instead, we need to echo it with the | bc command to allow float quotients
	if [ $i -ne 150000 ]
	then
		echo "scale=2 ; $k/100 " | bc | tr "\n" "," >> simulation_PEC.xmacro
		echo "" | tr "\n" " " >> simulation_PEC.xmacro #gives spaces between commas and numbers
        #we have to be careful! we want commas between numbers, but not after our last number
        #hence why we replace \n with , above, but with "]" below
	else
		echo "scale=2 ; $k/100 " | bc | tr "\n" "]" >> simulation_PEC.xmacro
		echo " " >> simulation_PEC.xmacro
	fi

done

###

if [[ $gen -eq 0 && $indiv -eq 1 ]]
then
	echo "if(indiv==1){" >> simulation_PEC.xmacro
	echo "App.saveCurrentProjectAs(\"$WorkingDir/Run_Outputs/$RunName/$RunName\");" >> simulation_PEC.xmacro
	echo "}" >> simulation_PEC.xmacro
fi

#we cat things into the simulation_PEC.xmacro file, so we can just echo the list to it before catting other files

cat PUEO_skeleton.txt >> simulation_PEC.xmacro
# Replace the number of times we simulate based on the symmetry
# Annoying because we need to count to the the opposite of $SYMMETRY
if [ $SYMMETRY -eq 1 ]
then
	vim -c ':%s/SYMMETRY/0' + -c ':wq!' simulation_PEC.xmacro
else
	vim -c ':%s/SYMMETRY/1' + -c ':wq!' simulation_PEC.xmacro
fi
#cat simulationPECmacroskeleton_PUEO.txt >> simulation_PEC.xmacro
#cat simulationPECmacroskeleton2_PUEO.txt >> simulation_PEC.xmacro
# Would like to just be able to import to XF with a command in the xmacros
# And then I only need to cat in a handful of scripts into simulation_PEC.xmacro
# According Walter Janusz at Remcom, this isn't possible yet. So we'll just have to 
# 	concatenate everything into a fil ourselves

cat headerPUEO.xmacro >> simulation_PEC.xmacro
cat functionCallsPUEO_reordered.xmacro >> simulation_PEC.xmacro
#cat functionCallsPUEO.xmacro >> simulation_PEC.xmacro
cat buildWalls.xmacro >> simulation_PEC.xmacro
cat buildRidges.xmacro >> simulation_PEC.xmacro
cat CreatePEC.xmacro >> simulation_PEC.xmacro
cat CreateAntennaSource.xmacro >> simulation_PEC.xmacro
cat CreateGrid.xmacro >> simulation_PEC.xmacro
cat CreateSensors.xmacro >> simulation_PEC.xmacro
cat CreateAntennaSimulationData.xmacro >> simulation_PEC.xmacro
cat QueueSimulation.xmacro >> simulation_PEC.xmacro
cat MakeImage.xmacro >> simulation_PEC.xmacro


#we need to change the gridsize by the same factor as the antenna size
#the gridsize in the macro skeleton is currently set to 0.1
#we want to make it scale in line with our scalefactor

initial_gridsize=0.1
new_gridsize=$(bc <<< "scale=6; $initial_gridsize/$GeoFactor")
sed -i "s/var gridSize = 0.1;/var gridSize = $new_gridsize;/" simulation_PEC.xmacro

sed -i "s+fileDirectory+${WorkingDir}/Generation_Data+" simulation_PEC.xmacro
#the above sed command substitute for hardcoded words and don't use a dummy file
#that's ok, since we're doing this after the simulation_PEC.xmacro file has been written; it gets deleted and rewritten from the macroskeletons, so it's ok for us to make changes this way here (as opposed to the way we do it for arasim in parts D1 and D2)

if [[ $gen -ne 0 && $i -eq 1 ]]
then
	cd $XFProj
	rm -rf Simulations
fi

echo
echo
echo 'Opening XF user interface...'
echo '*** Please remember to save the project with the same name as RunName! ***'
echo
echo '1. Import and run simulation_PEC.xmacro'
echo '2. Import and run output.xmacro'
echo '3. Close XF'

module load xfdtd/7.9.2.2

xfdtd $XFProj --execute-macro-script=$XmacrosDir/simulation_PEC.xmacro || true

chmod -R 775 $WorkingDir/../Xmacros

cd $WorkingDir

if [ $XFCOUNT -lt $num_keys ]
then
	batch_size=$XFCOUNT
else
	batch_size=$num_keys
fi

## We'll make the run name the job name
## This way, we can use it in the SBATCH commands
#I think this should work for PUEO too
sbatch --array=1-${XFCOUNT}%${batch_size} --export=ALL,WorkingDir=$WorkingDir,RunName=$RunName,XmacrosDir=$XmacrosDir,XFProj=$XFProj,NPOP=$NPOP,indiv=$individual_number,indiv_dir=$indiv_dir,gen=${gen} --job-name=${RunName} Batch_Jobs/GPU_XF_Job.sh



