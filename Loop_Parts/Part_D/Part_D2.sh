#This is a version of Part_D2 for PUEO

#variables
WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/RunData/$RunName/setup.sh

cd $WorkingDir/Run_Outputs/$RunName/PUEOFlags

nFiles=0

totPop=$( expr $NPOP \* $Seeds )

while [ "$nFiles" != "$totPop" ]
do
	echo "Waiting for PUEOsim jobs to finish..."
	sleep 20
	nFiles=$(ls -1 --file-type | grep -v '/$' | wc -l) # update nFiles
done

cd ..
rm -f $WorkingDir/Run_Outputs/$RunName/PUEOFlags/*
rm -f $WorkingDir/Run_Outputs/$RunName/PUEOConfirmed/*

wait

cd $WorkingDir/Antenna_Performance_Metric
