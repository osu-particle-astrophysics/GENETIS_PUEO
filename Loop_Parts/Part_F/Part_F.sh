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

# Make Plotting Directories
cd $WorkingDir/Run_Outputs/$RunName

if [ ${gen} -eq 0 ]
then
    mkdir -m775 Plots 
fi

mkdir -m775 Plots/Generation_${gen}
mv -f Generation_Data/*.png Plots/Generation_${gen}

# Define variables
gendir=$WorkingDir/Run_Outputs/$RunName/Generation_Data
plotdir=$WorkingDir/Run_Outputs/$RunName/Generation_Data/Plots/Generation_${gen}
next_gen=$(($gen+1))

# Make the physics/polar plots. Organize the best antenna pictures
cd $WorkingDir/Antenna_Performance_Metric

echo 'Starting max min plotter portion...'
./max_min_plotter.sh.sh $WorkingDir $RunName $gen

source $WorkingDir/Environments/set_plotting_env.sh

# Make fscore and variable plots
module load python/3.7-2019.10
python VariablePlots.py $gendir $plotdir $next_gen $NPOP $GeoFactor
python FScorePlotPUEO.py $gendir $plotdir $NPOP $gen $WorkingDir

# Make Rainbow plots
module load python/3.9-2022.05
python DataConverter_PUEO.py $gendir
python Rainbow_Plotter_PUEO.py $gendir $plotdir

cd $WorkingDir/Run_Outputs/$RunName
chmod -R 775 Generation_Data

echo 'Congrats on getting some nice plots!'
