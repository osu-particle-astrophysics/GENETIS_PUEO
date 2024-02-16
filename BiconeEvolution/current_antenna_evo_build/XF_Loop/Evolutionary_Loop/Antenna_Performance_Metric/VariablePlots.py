# Author: Unknown, Changes for PUEO by Dylan Wells
import numpy as np		
import matplotlib.pyplot as plt		
import argparse			
import matplotlib as mpl


# We need to grab the three arguments from the bash script or user. These arguments in order are [the name of the source folder of the fitness scores], [the name of the destination folder for the plots], and [the number of generations] #why is is number of generations and not gen number??
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory", type=str)
parser.add_argument("numGens", help="Number of generations the code is running for", type=int)
parser.add_argument("NPOP", help="Number of individuals in a population", type=int)
parser.add_argument("GeoScalingFactor", help="The number by which we are scaling the antenna dimensions", type=float)
g = parser.parse_args()

# The name of the plot that will be put into the destination folder, g.destination
PlotName = "VariablePlot"
variablePlotNames = ["S", "H", "Xi", "Yi", "Yf", "Zf", "beta"]

#----------DEFINITIONS HERE----------DEFINITIONS HERE----------DEFINITIONS HERE----------DEFINITIONS HERE
#----------STARTS HERE----------STARTS HERE----------STARTS HERE----------STARTS HERE 

# let me make an array holding each generation number
# I'm going to add small random numbers to these so that we can spread apart the data points a bit
np.random.seed(1) # seed the random number generator so each generation looks the same each time we recreated the plot
gen_array = []
for i in range(g.NPOP):
	gen_num = []
	for j in range(g.numGens):
		gen_num.append(j+np.random.uniform(-1/10,1/10,1))

	gen_array.append(gen_num)

# READ DATA (runData.csv)

# runData.csv contains every antenna's DNA and fitness score for all generations. 
# Format for each individual is radius, length, angle, fitness score (I call these characteristics).

# First, grab each line of the runData.csv as one element in a 1D list.
runDataRaw =[]
with open(g.source+"/runData.csv", "r") as runDataFile:
	runDataRaw=runDataFile.readlines()

# This list has each element terminating with '\n', so we use rstrip to remove '\n' from each string
for i in range(len(runDataRaw)):
	runDataRaw[i] = runDataRaw[i].rstrip()
# Now, we want to store this data in a 2D numpy array. As we'll see, this is a fairly complex process! First, make a new 2D list that contains only the numbers.
runDataRawOnlyNumb =[]
for i in range(len(runDataRaw)):
	# We want to skip the empty line and the 'Generation :' line
	if i%(g.NPOP+2) != 0 and i%(g.NPOP+2) != 1:
	
		runDataRawOnlyNumb.append(runDataRaw[i].split(','))#.a

# Now convert it to a numpy array and roll it up
runData = []
runData = np.array(runDataRawOnlyNumb)

runData = np.array(runDataRawOnlyNumb).astype(np.float)

#8 is for NVars + 1 where the 1 is the fitness score
runData = runData.reshape((g.numGens, g.NPOP, 10))

# PLOT DATA
# variables are S, H, Xi, Yi, Zf, Yf, beta 
variables = {
    "S": [runData[:,:, 0].flatten(), []],
    "H": [runData[:,:, 1].flatten(), []],  
    "Xi": [runData[:,:, 2].flatten(), []],
    "Yi": [runData[:,:, 3].flatten(), []],
    "Yf": [runData[:,:, 4].flatten(), []],
    "Zf": [runData[:,:, 5].flatten(), []],
    "beta": [runData[:,:, 6].flatten(), []],
    "fitness": [runData[:,:, 7].flatten(), []]
}

def fillArray(array, var):
    temp = []
    for ind in range(g.NPOP):
        for l in range(0,len(array),g.NPOP):
            temp.append(g.GeoScalingFactor*array[l+ind])
        var.append(temp)
        temp = []
    return var

for var in variables:
    variables[var][1] = fillArray(variables[var][0], variables[var][1])
 
# Plot!
#Create figure and subplots
mpl.rcParams['text.usetex'] = True
fig = plt.figure(figsize=(40, 8))
plt.style.use('seaborn')
axS = fig.add_subplot(1,7,1)
axH = fig.add_subplot(1,7,2)
axXi = fig.add_subplot(1,7,3)
axYi = fig.add_subplot(1,7,4)
axYf = fig.add_subplot(1,7,5)
axZf = fig.add_subplot(1,7,6)
axBeta = fig.add_subplot(1,7,7)
# increase the space between the subplots
plt.subplots_adjust(wspace = 0.5)
axes = [axS, axH, axXi, axYi, axZf, axYf, axBeta]
axToVar = {axS: "S", axH: "H", axXi: "Xi", axYi: "Yi", axZf: "Zf", axYf: "Yf", axBeta: "beta"}
axToUnits = {axS: "cm", axH: "cm", axXi: "cm", axYi: "cm", axZf: "cm", axYf: "cm", axBeta: "curvature"}
varToDisplayName = {"S": "Side Length", "H": "Height", "Xi": "Initial X", "Yi": "Initial Y", "Zf": "Final Z", "Yf": "Final Y", "beta": "beta"}
# Loop through each individual and plot each array


# Color each individual according to its fitness score
# First, find the minimum and maximum fitness scores
minFitness = min(variables["fitness"][0])
maxFitness = max(variables["fitness"][0])
# Now, create a list of colors for each individual
colors = ['#00429d', '#3e67ae', '#618fbf', '#85b7ce', '#b1dfdb', '#ffcab9', '#fd9291', '#e75d6f', '#c52a52', '#93003a']
# now we need to create 10 colors between the min and max fitness scores
# we can do this by creating a list of 10 numbers between 0 and 1 and then scaling them to the min and max fitness scores
fitnessColors = []
for i in range(10):
    fitnessColors.append(minFitness + i*(maxFitness-minFitness)/9)
# now we can loop through each individual and assign it a color based on its fitness score

for ind in range(g.NPOP):
    #assign a color based on fitness score
    color = colors[0]
    for i in range(10):
        if variables["fitness"][0][ind] <= fitnessColors[i]:
            #LabelName = "Individual {} (Fitness: {:.2f})".format(ind+1, variables["fitness"][0][ind])
            color = colors[i]
            break
    for ax in axes:
        ax.plot(gen_array[ind], variables[axToVar[ax]][1][ind], marker = 'o', color = color, linestyle = '', alpha = 0.6, markersize=10)

for ax in axes:
    ax.set_xlim(-1, g.numGens)
    ax.set_ylim(0.9*min(variables[axToVar[ax]][0]), 1.1*max(variables[axToVar[ax]][0]))
    ax.tick_params(axis='both', which='major', labelsize=14)
    ax.set_xlabel("Generation", size = 18)
    ax.set_ylabel("{} [{}]".format(varToDisplayName[axToVar[ax]], axToUnits[ax]), size = 18)
    ax.set_title("{} over Generations (0 - {})".format(varToDisplayName[axToVar[ax]], int(g.numGens-1)), size = 20)
    ax.grid()
    ax.yaxis.grid(linestyle = '--', linewidth = 0.5)
    ax.xaxis.grid(linestyle = '--', linewidth = 0.5)
    # plot the mean of each generation
    ax.plot(np.mean(gen_array, axis = 0), np.mean(variables[axToVar[ax]][1], axis = 0), color = 'black', linestyle = '--', linewidth = 3, label = "Mean")
    extent = ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted())
    #add the mean to the legend
    ax.legend(loc = 'upper left', prop={'size': 14})
    plt.savefig(g.destination + "/" + axToVar[ax] + "Plot", bbox_inches=extent.expanded(1.55, 1.2), dpi=480)

#save the plot
plt.savefig(g.destination + "/" + PlotName)
