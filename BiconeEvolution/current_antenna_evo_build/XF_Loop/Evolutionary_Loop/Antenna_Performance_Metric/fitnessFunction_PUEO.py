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
def ReadVeff(NSEEDS, antenna_file):
	veff_list = []
	out_list = []
	with open(antenna_file, newline = '') as out_file:
		out_reader = csv.reader(out_file, delimiter='\t')
		for output in out_reader:
			out_list.append(str(output))
	chunks = [[0 for x in range(6)] for y in range(len(out_list))]
	for i in range(len(out_list)):
		chunks[i] = re.split(' +', out_list[i])
	for i in range(len(out_list)):
		veff_list.append(float(chunks[i][1]))
	veff_sum = sum(veff_list)
	veff = veff_sum/NSEEDS
	return veff

#Writes the fitnessScores data into a csv file
def WriteFitness(f_scores):
	with open('fitnessScores.csv', 'w') as csv_file:
		csv_file.write("The Ohio State University GENETIS Data.\n")
		csv_file.write("Current generation's fitness scores:\n")
		for i in range(g.NPOP):
			csv_file.write(str(f_scores[i])+"\n")
def main(): #Loops through the antennas,calculates their fitness, and writes them to a csv
	for i in range(g.NPOP):
		fitness = ReadVeff(g.NSEEDS, g.antennaFile+"_"+str(i+1)+".txt")
		fitnessScores.append(fitness)
	print(fitnessScores)
	WriteFitness(fitnessScores)
#calls the main function
main()
