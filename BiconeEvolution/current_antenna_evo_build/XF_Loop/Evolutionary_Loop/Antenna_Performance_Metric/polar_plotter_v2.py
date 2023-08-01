## File name: polar_plotter.py
## Author: Alex Machtay (machtay.1@osu.edu)
## Date: 07/19/21
## Editors: Audrey Zinn (zinn.60@osu.edu), Bailey Stephens (stephens.761@osu.edu)
## Edit Date: 04/05/22
## Purpose:
##	This script is designed to read in the results from XF and plot the gain patterns.
##	It will plot each of the antennas given (in a range) at a specific (given) frequency.
##	These will show the gain at zenih angles, since the patterns are azimuthally symmetric
##
##
##
## Instructions:
## 		To run, give the following arguments
##			source directory, destination directory, frequency number, # of individuals per generation, generation #
##
## 		Example:
##			python polar_plotter.py Length_Tweak Length_Tweak 60 10 0
## 				This will plot the antennas for the length tweak from number 1-10
##				(which is all of them) at the highest frequency number (1067 MHz) and
##				will place the image inside the Length_Tweak directory.

## Imports
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import argparse
import csv
import matplotlib.cm as cm

## Arguments
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory", type=str)
parser.add_argument("freq_num", help="Frequency number (1-60) to plot", type=int)
parser.add_argument("npop", help="Number of individuals in a generation (ex: 10)", type=int)
parser.add_argument("gen", help="Generation number (ex: 0)", type=int)
parser.add_argument("symmetry", help="Symmetry of antenna (ex: 2)", type=int)
g=parser.parse_args()

sims_per_antenna = 1
if g.symmetry == 0:
    sims_per_antenna = 2

pop_size = g.npop * sims_per_antenna

## Loop over files
# Declare list for each file's gain list
gains = []
for individual in range(1, pop_size+1):
	## Open the file to read
	## NOTE: Looks for folder in source that contains a folder with name "gen_#"
	with open(g.source + "/" + str(individual) + "/" + str(g.gen) + "_" + str(individual) + "_" + str(g.freq_num) + ".uan", "r") as f:
		## Read in the file
		uan_read = csv.reader(f, delimiter = ' ')
		## Declare list to hold azimuth gains
		azimuth_gain = []
		for m, row in enumerate(uan_read):
			## skip the header
			if m >= 18:
				## Let's just add the azimuthal angles
				azimuth_gain.append(float(row[2]))
	f.close()
	## Declare temporary zenith gains
	zenith_gains = []
	## Loop over the zenith angles
	for j in range(1, 36):
		## Declare temporary azimuth means
		azimuth_mean = []
		## Loop over the azimuth angles
		k = j*73
		while k < ((j+1)*73):
			azimuth_mean.append(azimuth_gain[k])
			## Remember to increment!
			k += 1
		zenith_gains.append(np.mean(azimuth_mean))
		## Remember to increment!
	## Append the list of mean azimuth gains at each zenith to the gains list
	gains.append(zenith_gains)
	
### Opens temporary .csv files holding index of individuals of interest
f1 = open("temp_best.csv", "r")
f2 = open("temp_mid.csv", "r")
f3 = open("temp_worst.csv", "r")

### Saves these indices to variables
### Each individual has 2 files, so the index is multiplied by 2 and subtracted by 1
max_index = int(f1.readline()) * sims_per_antenna - 1
mid_index = int(f2.readline()) * sims_per_antenna - 1
min_index = int(f3.readline()) * sims_per_antenna - 1

### Closes the temporary files
f1.close()
f2.close()
f3.close()

### Delcares a list of the above indices and corresponding labels
indiv_list=[min_index, mid_index, max_index]
indiv_list2=[min_index+1, mid_index+1, max_index+1]
rank_list=['Min', 'Mid', 'Max']

### Declares lists of colors and linestyles used to distinguish individuals
linestyles = ['dotted', 'dashed', 'solid']
colors = ['blue', 'green', 'red']

## Plotting
# Make a list for the zenith angles
zenith_angles = []
for i in range(1, 36):
	zenith_angles.append(i*5*np.pi/180)

## Declare a figure
fig, ax = plt.subplots(subplot_kw={'projection': 'polar'}, figsize = (10, 8))
ax.set_theta_zero_location("N")
ax.set_rlabel_position(225)
ax.tick_params(axis='both', which='major', labelsize=11.5)

### Iterates over the three individuals above (best, worst, and mid performing)
for i in range(len(indiv_list)):
    
    ### Plots the gain pattern for one individual
	LabelName = "{}".format(str(rank_list[i]) + ": " + str(int((indiv_list[i]+1)/2)))
	ax.plot(zenith_angles, gains[indiv_list[i]], color = colors[i%3], linestyle = linestyles[i%3], alpha = 0.6, linewidth=3, label = LabelName)

### Creates legend and title for plot, then saves as an image
ax.legend(loc = 'lower right', bbox_to_anchor=(1.27, -0.12), title='Individual Number (Gen ' + str(g.gen)+ ')', fontsize=17)
plt.title("Antennas at Frequency number {} MHz (Vertical Polarization)".format(round(200 + 10*(g.freq_num-1), 6)), fontsize = 18)
plt.savefig(g.destination + "/polar_plot_" + str(round(200 + 10 * (g.freq_num-1), 3)) + "_Vpol.png")

## plot the second antenna ###################
if g.symmetry == 0:
	## Declare a figure
	fig, ax = plt.subplots(subplot_kw={'projection': 'polar'}, figsize = (10, 8))
	ax.set_theta_zero_location("N")
	ax.set_rlabel_position(225)
	ax.tick_params(axis='both', which='major', labelsize=11.5)

	### Iterates over the three individuals above (best, worst, and mid performing)
	for i in range(len(indiv_list2)):
		
		### Plots the gain pattern for one individual
		LabelName = "{}".format(str(rank_list[i]) + ": " + str(int((indiv_list2[i]+1)/2)))
		ax.plot(zenith_angles, gains[indiv_list2[i]], color = colors[i%3], linestyle = linestyles[i%3], alpha = 0.6, linewidth=3, label = LabelName)

	### Creates legend and title for plot, then saves as an image
	ax.legend(loc = 'lower right', bbox_to_anchor=(1.27, -0.12), title='Individual Number (Gen ' + str(g.gen)+ ')', fontsize=17)
	plt.title("Antennas at Frequency number {} MHz (Horizontal Polarization)".format(round(200 + 10*(g.freq_num-1), 6)), fontsize = 18)
	plt.savefig(g.destination + "/polar_plot_" + str(round(200 + 10 * (g.freq_num-1), 3)) + "_Hpol.png")
