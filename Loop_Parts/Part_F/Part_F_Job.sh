#!/bin/bash
## This Job submits the plotting software for the PUEO loop
#SBATCH --account=PAS1960
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --output=Plot.output
#SBATCH --error=Plot.error

#variables
#NPOP=$1
#WorkingDir=$2
#RunName=$3
#gen=$4
#Seeds=$5
#exp=$6
#GeoFactor=$7
#PSIMDIR=$8
#SYMMETRY=$9

source $WorkingDir/Run_Outputs/$RunName/setup.sh

echo "exp: $exp"
cd $WorkingDir

cd Antenna_Performance_Metric

echo 'Starting image maker portion...'
./image_maker.sh $WorkingDir/Run_Outputs/$RunName/Generation_Data $WorkingDir/Run_Outputs/$RunName/Antenna_Images/${gen} $WorkingDir/Run_Outputs/$RunName $gen $WorkingDir $RunName $NPOP $PSIMDIR $exp $SYMMETRY

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
python FScorePlotPUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $WorkingDir/Run_Outputs/$RunName/Generation_Data $NPOP $gen

#python3 color_plotsPUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $WorkingDir/Run_Outputs/$RunName/Generation_Data $NPOP $gen

cd $WorkingDir/Run_Outputs/$RunName
#mail -s "FScore_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < FScorePlot2D.png
#mail -s "FScore_Color_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < Fitness_Scores_RG.png
#mail -s "Veff_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < Veff_plot.png
#mail -s "Veff_Color_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < Veffectives_RG.png
#mail -s "Violin_Plot_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < ViolinPlot.png
mv -f *.csv Generation_Data/

#open permissions on the data files
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

#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/
