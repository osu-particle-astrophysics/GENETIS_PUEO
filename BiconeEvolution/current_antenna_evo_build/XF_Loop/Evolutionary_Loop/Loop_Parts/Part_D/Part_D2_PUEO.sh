#This is a version of Part_D2 for PUEO

#variables
gen=$1
NPOP=$2
WorkingDir=$3
RunName=$4
Seeds=$5
IceMCExec=$6



cd $WorkingDir/Run_Outputs/$RunName

nFiles=0

totPop=$( expr $NPOP \* 2 )

while [ "$nFiles" != "$totPop" ]
do
	echo "Waiting for IceMC jobs to finish..."
	sleep 20
	nFiles=$(ls -1 --file-type | grep ".txt" | wc -l) # update nFiles

done


rm -f $WorkingDir/Run_Outputs/$RunName/IceMCFlags/*
rm -f $WorkingDir/Run_Outputs/$RunName/IceMCConfirmed/*
#rm -f $WorkingDir/Run_Outputs/$RunName/AraSim_Outputs/*
#rm -f $WorkingDir/Run_Outputs/$RunName/AraSim_Errors/*
wait

cd "$WorkingDir"/Antenna_Performnance_Metric

if [$gen -eq 10000 ]
then
	#Will need to change this
	cp $WorkingDir/Antenna_Performance_Metric/IceMCActual/ $WorkingDir/Run_Outputs/$RunName/IceMCActual/
fi

