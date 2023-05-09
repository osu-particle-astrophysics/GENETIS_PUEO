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
#rm -f $WorkingDir/Run_Outputs/$RunName/AraSim_Outputs/*
#rm -f $WorkingDir/Run_Outputs/$RunName/AraSim_Errors/*
wait

cd $WorkingDir/Antenna_Performance_Metric

if [ $gen -eq 10000 ]
then
	#Will need to change this
	cp $WorkingDir/Antenna_Performance_Metric/PUEOActual/ $WorkingDir/Run_Outputs/$RunName/PUEOActual/
fi

