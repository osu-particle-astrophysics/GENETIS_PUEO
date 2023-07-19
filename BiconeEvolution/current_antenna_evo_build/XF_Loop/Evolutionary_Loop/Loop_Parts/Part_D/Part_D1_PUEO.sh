##########   IceMC Execution (D)  ################################################################################################################## 
#
#
#       1. Moves the gain patters for each antenna into the folder pueoSim accesses
#
#       2. For each individual ::
#           I. Run pueoSim (Seeds * 40) times for each antenna
#           II. Move the outputted root files to the Root_Files directory
#
#
################################################################################################################################################## 
#variables
gen=$1
NPOP=$2
WorkingDir=$3
PSIMDIR=$4
exp=$5
NNT=$6
RunName=$7
Seeds=$8
DEBUG_MODE=$9
XFProj=${10}
XFCOUNT=${11}
SpecificSeed=32000

echo "Entering Part D1 PUEO!"

# Making directories
cd $WorkingDir
mkdir -m775 ${XFProj}/XF_models_${gen}
mkdir -m775 Run_Outputs/${RunName}/Root_Files/${gen}_Root_Files
mkdir -m775 Run_Outputs/${RunName}/uan_files/${gen}_uan_files
mkdir -m775 ${PSIMDIR}/outputs/${RunName}/${gen}_outputs

#Move the gain files into the correct place for PSIM to read them in
for i in `seq 1 $NPOP`
do
	run_num=$((NPOP * gen + i))
	cp Test_Outputs/hh_0_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_0_Toyon${run_num}
	cp Test_Outputs/hv_0_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hv_0_Toyon${run_num}
	cp Test_Outputs/vv_0_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_0_Toyon${run_num}
	cp Test_Outputs/vh_0_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vh_0_Toyon${run_num}
	cp Test_Outputs/hh_el_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_el_Toyon${run_num}
	cp Test_Outputs/hh_az_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/hh_az_Toyon${run_num}
	cp Test_Outputs/vv_el_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_el_Toyon${run_num}
	cp Test_Outputs/vv_az_${gen}_${i} $PSIMDIR/pueoBuilder/components/pueoSim/data/antennas/simulated/vv_az_Toyon${run_num}
done

#record the gain data
cp Test_Outputs/* $XFProj/XF_models_${gen}/

if [ ${gen} -eq 0 ]
then
	mkdir -m775 Run_Outputs/${RunName}/PUEO_Outputs
	mkdir -m775 Run_Outputs/${RunName}/PUEO_Errors
fi

source $PSIMDIR/set_env.sh

if [ $DEBUG_MODE -eq 0 ]
then
	cd $WorkingDir
	numJobs=$((NPOP*Seeds))
	maxJobs=252 
	# Each job will simulate pueosim 40 times for NNT neutrinos each
	sbatch --array=1-${numJobs}%${maxJobs} --export=ALL,gen=$gen,WorkingDir=$WorkingDir,RunName=$RunName,Seeds=$Seeds,PSIMDIR=$PSIMDIR,NPOP=$NPOP,NNT=$NNT,Exp=$exp --job-name=${RunName} Batch_Jobs/PueoCall_Array.sh

# Currently Debug=1 is not implemented for PUEO @todo
else
	# pass
	:
fi

# Let's move the uan files to a directory

cd $WorkingDir/Run_Outputs/${RunName}/uan_files
for i in `seq 1 $XFCOUNT`
do
	mkdir -m775 ${gen}_uan_files/${i}
	mv ../${gen}_${i}_*.uan ${gen}_uan_files/${i}/
done

