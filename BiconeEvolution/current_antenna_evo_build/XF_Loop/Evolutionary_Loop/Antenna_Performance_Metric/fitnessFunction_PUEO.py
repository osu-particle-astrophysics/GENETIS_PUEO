## File name: fitnessFunction_PUEO.py
## Author: Dylan Wells (wells.1629@osu.edu)
## Date: 10/31/22
## Purpose:
##   This script will read the output veff data from iceMC for each antenna and
##   write veff (equivalent to the fitness score) to fitnessScores.csv
# 
## Imports
import argparse
import csv
import re
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
	veff_list = []
	out_list = []
	with open(antenna_file, newline='') as out_file:
		out_reader = csv.reader(out_file, delimiter='\t')
		out_list = list(out_reader)
	chunks = []
	for line in out_list:
		chunks.append(line.split())
	for line in out_list:
		veff_list.append(float(line[1]))
	veff_sum = sum(veff_list)
	veff = veff_sum/NSEEDS
	return veff

def write_fitness(f_scores):
    """Write the fitness scores data into a csv file."""
	with open('fitnessScores.csv', 'w') as csv_file:
		csv_file.write("The Ohio State University GENETIS Data.\n")
		csv_file.write("Current generation's fitness scores:\n")
		for i in range(g.NPOP):
			csv_file.write(f'{f_scores[i]}\n')
def main(): #Loops through the antennas,calculates their fitness, and writes them to a csv
	for i in range(g.NPOP):
		fitness = read_veff(g.NSEEDS, f'{g.antennaFile}_{i+1}.txt')
		fitnessScores.append(fitness)
	print(fitnessScores)
	write_fitness(fitnessScores)
#calls the main function
main()
