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
mkdir -p -m775 $RunDir/Plots/Generation_${gen}

# Define variables
gendir=$RunDir/Generation_Data
plotdir=$RunDir/Plots/Generation_${gen}
next_gen=$(($gen+1))

# Make the physics/polar plots. Organize the best antenna pictures
cd $WorkingDir/Antenna_Performance_Metric

echo 'Starting max min plotter portion...'
./max_min_plotter.sh $WorkingDir $RunName $gen

source $WorkingDir/Environments/set_plotting_env.sh

# Make fscore and variable plots
module load python/3.7-2019.10
python VariablePlots.py $gendir $plotdir $next_gen $NPOP $GeoFactor
python FScorePlot.py $gendir $plotdir $NPOP $gen $WorkingDir

# Make Rainbow plots
module load python/3.9-2022.05
python DataConverter.py $gendir
python Rainbow_Plotter.py $gendir $plotdir

chmod -R 775 $RunDir/Generation_Data

echo 'Congrats on getting some nice plots!'
