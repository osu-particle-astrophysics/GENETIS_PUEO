## File name: fitnessFunction_PUEO.py
## Author: Dylan Wells (wells.1629@osu.edu)
## Date: 10/31/22
## Purpose:
##   This script will read the output veff data from iceMC for each antenna and
##   write veff (equivalent to the fitness score) to fitnessScores.csv
# 
## Imports
import argparse
import pandas as pd
import numpy as np
## Arguments
#scaleFactor and GeoScaleFactor are used in the AraSim Loop, not currently utilized for PUEO.
parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="Population size.", type=int)
parser.add_argument("NSEEDS", help="number of seeds", type=int)
#parser.add_argument("scaleFactor", help=" scaling variable for the exponent in the constraint", type=float)
parser.add_argument("antennaFile", help="path to antenna file", type=str)
#parser.add_argument("GeoScaleFactor", help="Factor by which we scale dwon the antenna dimensions", type=float)
g=parser.parse_args()
fitnessScores = []
#fitnessScores = [NPOP, 0.0]
print(g.NPOP, g.NSEEDS, g.antennaFile)
#Reads the veff output file for the antenna, returns the average veff
def read_veff(NSEEDS, antenna_file):
    veff_list = pd.read_csv(antenna_file, header=None)
    veff_list = np.array(veff_list)
    veff_list = veff_list.flatten()
    total = sum(veff_list)
    total = total/NSEEDS
    return total

def write_fitness(f_scores):
    """Write the fitness scores data into a csv file."""
    with open('fitnessScores.csv', 'w') as csv_file:
        csv_file.write("The Ohio State University GENETIS Data.\n")
        csv_file.write("Current generation's fitness scores:\n")
        for i in range(g.NPOP):
            csv_file.write(f'{f_scores[i]}\n')
def main(): #Loops through the antennas,calculates their fitness, and writes them to a csv
    for i in range(g.NPOP):
        fitness = read_veff(g.NSEEDS, f'{g.antennaFile}_{i+1}.csv')
        fitnessScores.append(fitness)
    write_fitness(fitnessScores)
#calls the main function
main()
