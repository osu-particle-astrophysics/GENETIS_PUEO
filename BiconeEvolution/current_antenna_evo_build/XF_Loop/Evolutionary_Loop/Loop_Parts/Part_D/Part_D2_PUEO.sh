#This is a version of Part_D2 for PUEO

#variables
gen=$1
NPOP=$2
WorkingDir=$3
RunName=$4
Seeds=$5
ArasimExec=$6

cd $WorkingDir/RunOutputs/$RunName/AraSimFlags/
nFiles=0

totPop=$( expr $NPOP \* $Seeds )

while [ "$nFiles" != "$totPop" ]
do
	echo "Waiting for IceMC jobs to finish..."
	sleep 20
#Add more from here
