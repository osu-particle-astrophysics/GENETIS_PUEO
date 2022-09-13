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
	# we need to base the counter off of the new flags
	# these are in the AraSimConfirmed directory
	nFiles=$(ls -1 --file-type ../AraSimConfirmed | grep -v '/$' | wc -l) # update nFiles 
	
	# I'm adding a second set of flags
	# The first set of flags indicates that the job finished
	# The second set indicates that the job was successful
	# If the job sas unsuccessful, we'll read the flag file to know which job to resubmit
	for file in *
	do

		#echo $file


		#If there are not files, then it will look at the literal name given in the for loop (gen_*)
		# we need to exclude that, since it's not a real file
		if [ "$file" != "*" ] && [ "$file" != "" ] # both are necessary
		# We don't want it to think * in the for loop is an actual file
		# Also, I've found that it also checks the empty file name "" for some reason
		then
			current_generation=$(head -n 1 $file) # what gen (should be this one)
			current_individual=$(head -n 2 $file | tail -n 1) # which individual?
			current_seed=$(head -n 3 $file | tail -n 1) # which seed of the individual

			#current_file="${gen}_${current_individual}_${current_seed}"
			current_file="IceMC_$(($((${current_individual}-1))*${Seeds}+${current_seed}))"

			# now we need to check the error file produced for that job
			# the error file is in Run_Name/${gen}_AraSim_Outputs

			#echo $current_file
			if grep "segmentation violation" ../IceMC_Errors/${current_file}.error || grep "DATA_LIKE_OUTPUT" ../IceMC_Errors/${current_file}.error || grep "CANCELLED" ../IceMC_Errors/${current_file}.error
			then
				# we need to remove the output and error file associated with that
				# otherwise, this loop will keep seing it and keep resubmitting
				rm -f ../IceMC_Errors/${current_file}.error
				rm -f ../IceMC_Outputs/${current_file}.output

				echo "segmentation violation/DATA_LIKE_OUTPUT/CANCELLED error!"

				#now we can resubmit the job
				cd $WorkingDir
				output_name=/fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/IceMC_Outputs/${current_file}.output
				error_name=/fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/IceMC_Errors/${current_file}.error
				sbatch --export=ALL,gen=$gen,num=${current_individual},WorkingDir=$WorkingDir,RunName=$RunName,Seeds=${current_seed},IceMCDir=$IceMCExec --job-name=IcemCCall_Array_$gen_${current_individual}_${current_seed}.run --output=$output_name --error=$error_name Batch_Jobs/IceMCCall_Array.sh

				cd RunOutputs/$RunName/IceMCFlags/
	
				# since we need to rerun, we need to remove the flag
				rm -f ${current_individual}_${current_seed}.txt
	
			else
				# we need to add the second flag to denote that all is well if there was not error		
				if [ "$current_individual" != "" ] && [ "$current_seed" != "" ]
				then
					echo "This individual succeeded" > ../IceMCConfirmed/${current_individul}_${current_seed}_confirmation.txt
				fi
			fi
		fi
	done
done

rm -f $WorkingDir/Run_Outputs/$RunName/IceMCFlags/*
rm -f $WorkingDir/Run_Outputs/$RunName/IceMCConfirmed/*
#rm -f $WorkingDir/Run_Outputs/$RunName/AraSim_Outputs/*
#rm -f $WorkingDir/Run_Outputs/$RunName/AraSim_Errors/*
wait

cd "$WorkingDir"/Antenna_Performnance_Metric

if [$gen -eq 10000 ]
then
	#cp $WorkingDir/Antenna_Performance_Metric/AraOut_ActualBicone.txt $WorkingDir/Run_Outputs/$RunName/AraOut_ActualBicone.txt
	#ask about this
fi

