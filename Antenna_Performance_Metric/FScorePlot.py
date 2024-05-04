"""Create the Fitness Score Plots"""
import numpy as np
import argparse
import csv
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns
import pandas as pd

from pathlib import Path
 
# Arguments

parser = argparse.ArgumentParser()
parser.add_argument("source", help="Path of source dir to data", type=Path)
parser.add_argument("destination", help="Path of dest folder", type=Path)
parser.add_argument("npop", help="Population size", type=int)
parser.add_argument("num_gens", help="number of generations", type=int)
parser.add_argument("working_dir", help="Path to working dir", type=Path)
g = parser.parse_args()

# The name of the plot that will be put into the destination folder
plot_name = "FScorePlot2D"
violin_plot_name="ViolinPlot"

# Create small deviations in the x axis so we can see the data points
np.random.seed(1) 
gen_array = []
for i in range(g.npop):
	gen_num = []
	for j in range(g.num_gens+1):
		gen_num.append(float(j+np.random.uniform(-2/10,2/10,1)))
	gen_array.append(gen_num)

# Load in the fitnesses and errors
fit_df = pd.DataFrame()
err_plus_df = pd.DataFrame()
err_minus_df = pd.DataFrame()
mean_fits = np.zeros(g.num_gens+1)
median_fits = np.zeros(g.num_gens+1)

for gen in range(0, g.num_gens+1):
    fits = np.loadtxt(g.source / f"{gen}_fitnessScores.csv", 
                      delimiter=',', skiprows=0, unpack=True)
    errs = np.loadtxt(g.source / f"{gen}_errorBars.csv", 
                      delimiter=',', skiprows=0, unpack=True)
    fit_df[gen] = fits
    err_plus_df[gen] = errs[0]
    err_minus_df[gen] = errs[1]
    
    mean_fits[gen] = np.mean(fits)
    median_fits[gen] = np.median(fits)
    
fit_df = fit_df.T
err_plus_df = err_plus_df.T
err_minus_df = err_minus_df.T


# Load in the max, min, and max error
max_fits, min_fits, max_errs = np.loadtxt(g.source / "plottingData.csv", 
                                          delimiter=',', skiprows=0,
                                          unpack=True)
max_fit = max_fits.max()
min_fit = min_fits.min()
max_error = max_errs.max()
diff_fit = max_fit - min_fit


gen_axis = np.linspace(0, g.num_gens, g.num_gens+1, endpoint=True)
gen_axis = [int(i) for i in gen_axis]

#Importing the Toyon Data
veff_toyon = 0
veff_toyon_err_plus = 0
veff_toyon_err_minus = 0

with open(g.working_dir / "Toyon_Outs_Skimmed" /
          "0_fitnessScores.csv", "r") as fp:
    # read in the value in the first line to veff_toyon
    veff_toyon = float(fp.readline())

toyon_errors_file = pd.read_csv(g.working_dir / "Toyon_Outs_Skimmed" / 
                                "0_errorBars.csv", header=None)
veff_toyon_err_plus = toyon_errors_file[0][0]
veff_toyon_err_minus = toyon_errors_file[1][0]

# Setting style variables for the plots
major = 5.0
minor = 3.0
mpl.rcParams['text.usetex'] = True
plt.figure(figsize=(10, 8))
plt.style.use('seaborn')
colors = cm.rainbow(np.linspace(0, 1, g.npop))

# Testing our colorblind friendly colors
colors2 = ['#00429d', '#3e67ae', '#618fbf', '#85b7ce', '#b1dfdb', 
           '#ffcab9', '#fd9291', '#e75d6f', '#c52a52', '#93003a']

# Scale to include the toyon data
if veff_toyon > (max_fit + (diff_fit * 0.25)):
    max_y = veff_toyon + (diff_fit * 0.25)
else:
    max_y = max_fit + (diff_fit * 0.25)

# Plotting the mean and median fitness scores
plt.axis([-1, g.num_gens+1, min_fit - (diff_fit * 0.25) , max_y])
plt.plot(gen_axis, mean_fits, linestyle='dotted', 
         alpha=1, markersize=15, zorder=9)
plt.plot(gen_axis, median_fits, linestyle='dashed', 
         alpha=1, markersize=15, zorder=9)

styles = dict(alpha=1, markersize=15, zorder=10)
# Plotting the Toyon Data
plt.axhline(y=veff_toyon, color='black', linestyle='solid', **styles)

# Plotting the Toyon Error Bars
plt.axhline(y=veff_toyon + veff_toyon_err_plus, color='gray', 
            linestyle='dotted', **styles)
plt.axhline(y=veff_toyon - veff_toyon_err_minus, color='gray', 
            linestyle='dotted', **styles)

#plotting with small deviations in the x axis so we can see the data points
for ind in range(g.npop):
    plt.errorbar(gen_array[ind], fit_df[ind], 
                 yerr=[err_plus_df[ind], err_minus_df[ind]], marker='o', 
                 color=colors2[ind%10], linestyle='', alpha=0.6, 
                 markersize=7, capsize=3, capthick=1)

plt.xlabel('Generation', size=23)
plt.ylabel('Fitness Score (km$^3$str)', size=23)
plt.legend(["Mean", "Median", "Toyon", 
            "Toyon +Err", "Toyon -Err", "Individuals"], 
           loc='upper left', prop={'size': 10}, framealpha=1, 
           bbox_to_anchor=(1.05, 1), frameon=True, fancybox=True, shadow=True)

plt.subplots_adjust(right=0.81)
plt.xticks(gen_axis, size=12)
plt.yticks(size=12)
plt.title(f"Fitness Score over Generations (0 - {g.num_gens})", size=28)
plt.savefig(g.destination / f"{plot_name}.png", dpi=300)
plt.savefig(g.destination / f"{plot_name}.pdf")


#Create a new figure for the violin plot
plt.figure(figsize=(10, 8))
plt.style.use('seaborn')

plt.axis([-1, g.num_gens+1, min_fit - (diff_fit * 0.25) , max_y])

plt.plot(gen_axis, mean_fits, linestyle='dotted', 
         alpha=1, markersize=25, color='#00429d')
plt.plot(gen_axis, median_fits, linestyle='dashed', 
         alpha=1, markersize=20, color='#93003a')

# Plotting the Toyon Data
plt.axhline(y=veff_toyon, color='black', linestyle='solid', 
            alpha=1, markersize=15, zorder=10)

# Plotting the Toyon Error Bars
plt.axhline(y=veff_toyon + veff_toyon_err_plus, color='gray', 
            linestyle='dotted', alpha=1, markersize=15, zorder=10)
plt.axhline(y=veff_toyon - veff_toyon_err_minus, color='gray', 
            linestyle='dotted', alpha=1, markersize=15, zorder=10)

# Plotting the violin plot
transposed_df = fit_df.T
violinplot = sns.violinplot(data=transposed_df, color='lightcyan', width=0.25)
fig = violinplot.get_figure()

plt.xlabel('Generation', size=23)
plt.ylabel('Fitness Score (km$^3$str)', size=23)
plt.title(f"Fitness Score over Generations (0 - {g.num_gens})", size=28)
plt.xticks(gen_axis, size=12)
plt.yticks(size=12)
plt.legend(["Mean", "Median", "Toyon", "Toyon Errs"], loc = 'upper left', 
           prop={'size': 10}, framealpha=1, bbox_to_anchor=(1.05, 1), 
           frameon=True, fancybox=True, shadow=True)
plt.subplots_adjust(right=0.81)
fig.savefig(g.destination / f"{violin_plot_name}.png", dpi=300)
fig.savefig(g.destination / f"{violin_plot_name}.pdf")
