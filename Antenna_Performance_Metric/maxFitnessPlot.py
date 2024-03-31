import matplotlib.pyplot as plt
import matplotlib as mpl
import argparse
import csv
import re

#---------GLOBAL VARIABLES----------GLOBAL VARIABLES----------GLOBAL VARIABLES----------GLOBAL VARIABLES
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory (no end dash)", type=str)
g = parser.parse_args()

#load in the data from maxFitnessScores.csv
fitnesses = []
with open(g.source + "/maxFitnessScores.csv", "r") as fr:
    f_read = csv.reader(fr, delimiter=',')
    for i, row in enumerate(f_read):
        fitness = re.findall(r'\d+', *row)
        fitnesses.append(float('.'.join([fitness[1], fitness[2]])))
fr.close()



mpl.rcParams['text.usetex'] = True
plt.figure(figsize=(10,10))
#plt.style.use('seaborn')
genAxis = range(0, len(fitnesses))
plt.plot(genAxis, fitnesses, linewidth=2, color='black')
plt.xlabel("Generation")
plt.ylabel("Max Fitness Score")
plt.title("Max Fitness Score vs. Generation")
plt.legend(["Max Fitness Score"])
plt.savefig(g.destination + "/maxFitnessPlot.png")
plt.close()


            
