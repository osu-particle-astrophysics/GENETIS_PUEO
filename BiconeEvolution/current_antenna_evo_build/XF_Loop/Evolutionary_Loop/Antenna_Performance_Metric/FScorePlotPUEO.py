import numpy as np
import matplotlib.pyplot as plt
import argparse
import csv
import matplotlib.cm as cm
import seaborn as sns
import pandas as pd
 
#---------GLOBAL VARIABLES----------GLOBAL VARIABLES----------GLOBAL VARIABLES----------GLOBAL VARIABLES

# We need to grab the three arguments from the bash script or user. These arguments in order are [the name of the source folder of the fitness scores], [the name of the destination folder for the plots], and [the number of generations]
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory (no end dash)", type=str)
parser.add_argument("NPOP", help="Number of individuals per generation", type=int)
parser.add_argument("numGens", help="Number of generations the code is running for (no end dash)", type=int)
g = parser.parse_args()

# The name of the plot that will be put into the destination folder, g.destination
Plot2DName = "/FScorePlot2D.png"
ViolinPlotName="/ViolinPlot.png"


#----------STARTS HERE----------STARTS HERE----------STARTS HERE----------STARTS HERE
fileReadTemp = []
fScoresGen = []
fScoresInd = []


#Load in the Fitnesses

tempFitnesses = []
FitnessesArray = []
for ind in range(1, g.NPOP+1):
    lineNum = ind + 1 #the line in the csv files that the individual data is in 
    #we need to loop over all the generations, since the gen is in the file names
    for gen in range(0, g.numGens+1):
        #we need to give the changeable filenames we're gonna read
        fitnesses = "{}_fitnessScores.csv".format(gen)
        #for each generation, we need to get all the fitnesses
        with open(g.source + "/" + fitnesses, "r") as fr: #fr for fitnesses read
            f_read = csv.reader(fr, delimiter=',') #reading fr as a csv
            for i, row in enumerate(f_read): #loop over the rows 
                if i == lineNum: #skipping the header
                    fitness = float(row[0]) #lineNum contains the fitness score
                    #print(fitness)
        fr.close()
        #fill the generation individual values into arrays to hold them temporarily
        tempFitnesses.append(fitness)
    #The temporary files contain the same individual at different generations
    #we want to store these now in the arrays containing all the data
    FitnessesArray.append(tempFitnesses)
    tempFitnesses = []
    
# Load in the max, min, and max error
maxFits, minFits, maxErrors = np.loadtxt(g.location + "/plottingData.csv", delimiter=',', skiprows=0, unpack=True)
maxFit = maxFits.max()
minFit = minFits.min()
maxError = maxErrors.max()


genAxis = np.linspace(0,g.numGens,g.numGens+1,endpoint=True)

''' Put in the average psim when we get it 
Veff_ARA = []
Err_plus_ARA = []
Err_minus_ARA = []
Veff_ARA_Ref = []

filenameActual = "/AraOut_ActualBicone.txt"
fpActual = open(g.source + filenameActual)

for line in fpActual:
    if "test Veff(ice) : " in line:
        Veff_ARA = float(line.split()[5]) #changed from 3 to 5 for switching to km^3 from m^3
        #print(Veff_ARA)
    elif "And Veff(water eq.) error plus :" in line:
        Err_plus_ARA = float(line.split()[6])
        Err_minus_ARA = float(line.split()[11])
#    line = fpActual.readline()
    #print(line)
'''

## Adding line of average fitness score
MeanFitness = []
MedianFitness = []
FlippedFitness = np.transpose(FitnessesArray)
#print(FlippedFitness)
for ind in range(g.numGens+1):	
    mean = sum(FlippedFitness[ind])/g.NPOP
    MeanFitness.append(mean)	
    MedianFitness.append(FlippedFitness[ind][int(g.NPOP/2)])



plt.figure(figsize=(10, 8))

#plt.axhline(y=Veff_ARA, linestyle = '--', color = 'k')

colors = cm.rainbow(np.linspace(0, 1, g.NPOP))
plt.axis([-1, g.numGens+1, minFit - maxError, maxFit + maxError])


for ind in range(g.NPOP):
    LabelName = "Individual {}".format(ind+1)
    plt.plot(genAxis, FitnessesArray[ind], label = LabelName, marker = 'o', color = colors[ind], linestyle='', alpha = 0.4, markersize = 11)
    plt.plot(genAxis, MeanFitness, label = LabelName, linestyle='-', alpha = 1, markersize = 15)
plt.xlabel('Generation', size = 26)
plt.ylabel('Fitness Score (km$^3$str)', size = 26)
plt.title("Fitness Score over Generations (0 - {})".format(int(g.numGens)), size = 30)

#plt.legend()
plt.savefig(g.destination + Plot2DName)

#create a violin plot of the fitness scores
#Create a new figure
plt.figure(figsize=(10, 8))
#Plot the mean and median fitnesses
plt.plot(genAxis, MeanFitness, linestyle='-', alpha = 1, markersize = 25, color='red')
plt.plot(genAxis, MedianFitness, linestyle='dashed', alpha = 1, markersize =20, color='green')
#We need to create a dataframe in the form of (gen, fitness) for each individual fitness 
violinArray = []
for unit in FitnessesArray:
    for j in range(len(unit)):
        violinArray.append([j, unit[j]])
violinArray = np.array(violinArray)
df0 = pd.DataFrame(violinArray, columns = ['Generation','Fitness Score'])
#add the violinplot to the figure
violinplot = sns.violinplot(data=df0, x="Generation", y="Fitness Score", color='lightcyan', width=0.25)
fig = violinplot.get_figure()
plt.xlabel('Generation', size = 26)
plt.ylabel('Fitness Score (km$^3$str)', size = 26)
plt.title("Fitness Score over Generations (0 - {})".format(int(g.numGens)), size = 30)
plt.legend(["Mean", "Median"])
fig.savefig(g.destination+ViolinPlotName) 
