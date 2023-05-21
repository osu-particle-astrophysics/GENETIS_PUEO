
########  Plotting (F)  ############################################################################################################################ 
#
#
#      1. Plots in 3D and 2D of current and all previous generation's scores. Saves the 2D plots. Extracts data from $RunName folder in all of the i_generationDNA.csv files. Plots to same directory.
#
#
#################################################################################################################################################### 
# variables
NPOP=$1
WorkingDir=$2
RunName=$3
gen=$4
Seeds=$5
#chmod -R 777 /fs/ess/PAS1960/BiconeEvolutionOSC/BiconeEvolution/

# Current Plotting Software

cd $WorkingDir


#cp AraOut_ActualBicone_10_18.txt Run_Outputs/$RunName/AraOut_ActualBicone.txt
#cp ARA_Bicone_Data/AraOut_Actual_Bicone_Fixed_Polarity_2.9M_NNU.txt Run_Outputs/$RunName/AraOut_ActualBicone.txt

cd Antenna_Performance_Metric

source set_plotting_env.sh

#this is for the rainbow plot
module load python/3.9-2022.05

python DataConverter_PUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data
python Rainbow_Plotter_PUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data

module load python/3.7-2019.10

# Format is source directory (where is generationDNA.csv), destination directory (where to put plots), npop
python FScorePlotPUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $WorkingDir/Run_Outputs/$RunName/Generation_Data $NPOP $gen

python3 color_plotsPUEO.py $WorkingDir/Run_Outputs/$RunName/Generation_Data $WorkingDir/Run_Outputs/$RunName/Generation_Data $NPOP $gen

./image_maker.sh $WorkingDir/Run_Outputs/$RunName/Generation_Data $WorkingDir/Run_Outputs/$RunName/Antenna_Images/${gen} $WorkingDir/Run_Outputs/$RunName $gen $WorkingDir $RunName $NPOP

cd $WorkingDir/Run_Outputs/$RunName
mail -s "FScore_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < FScorePlot2D.png
mail -s "FScore_Color_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < Fitness_Scores_RG.png
mail -s "Veff_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < Veff_plot.png
mail -s "Veff_Color_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < Veffectives_RG.png
mail -s "Violin_Plot_${RunName}_Gen_${gen}" dropbox.2dwp1o@zapiermail.com < ViolinPlot.png
mv -f *.csv Generation_Data/

cd "$WorkingDir"
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
