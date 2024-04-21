###########################################################################################
#
#    Part F: Plotting and visualizing the fitness scores
#
#
##########################################################################################
WorkingDir=$1
RunName=$2
gen=$3
source $WorkingDir/Run_Outputs/$RunName/setup.sh

echo "exp: $exp"
cd $WorkingDir

cd Antenna_Performance_Metric

echo 'Starting image maker portion...'
./image_maker.sh $WorkingDir $RunName $gen

source set_plotting_env.sh

next_gen=$(($gen+1))

module load python/3.7-2019.10

python VariablePlots.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $WorkingDir/Run_Outputs/$RunName/Generation_Data $next_gen $NPOP $GeoFactor

#this is for the rainbow plot
module load python/3.9-2022.05

python DataConverter_PUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data
python Rainbow_Plotter_PUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data

module load python/3.7-2019.10

# Format is source directory (where is generationDNA.csv), destination directory (where to put plots), npop
python FScorePlotPUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $WorkingDir/Run_Outputs/$RunName/Generation_Data $NPOP $gen $WorkingDir

cd $WorkingDir/Run_Outputs/$RunName

mv -f *.csv Generation_Data/ 2> /dev/null

cd $WorkingDir/Run_Outputs/$RunName
chmod -R 775 Generation_Data

#Move the plots to the Plots folder and corresponding generation folder (could probably just make this the destination)
if [ ${gen} -eq 0 ]
then
    mkdir -m775 Plots 
fi

mkdir -m775 Plots/Generation_${gen}
mv -f Generation_Data/*.png Plots/Generation_${gen}

echo 'Congrats on getting some nice plots!'


