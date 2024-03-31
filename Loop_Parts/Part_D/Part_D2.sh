#This is a version of Part_D2 for PUEO

#variables
gen=$1
NPOP=$2
WorkingDir=$3
RunName=$4
Seeds=$5
PSIMDIR=$6


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
