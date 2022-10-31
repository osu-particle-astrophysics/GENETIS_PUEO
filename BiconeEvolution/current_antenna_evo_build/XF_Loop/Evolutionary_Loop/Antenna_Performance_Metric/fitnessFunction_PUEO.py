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
## Arguments
#scaleFactor and GeoScaleFactor are used in the AraSim Loop, not currently utilized for PUEO.
parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="Population size.", type=int)
parser.add_argument("NSEEDS", help="number of seeds", type=int)
#parser.add_argument("scaleFactor", help=" scaling variable for the exponent in the constraint", type=float)
parser.add_argument("antennaFile", help="path to antenna file", type=str)
#parser.add_argument("GeoScaleFactor", help="Factor by which we scale dwon the antenna dimensions", type=float)

fitnessScores = []
#fitnessScores = [NPOP, 0.0]
def main(): #Loops through the antennas,calculates their fitness, and writes them to a csv
	for i in range(g.NPOP):
		fitness = ReadVeff(g.NSEEDS, g.antennaFile+"_"+str(i)+".txt")
		fitnessScores.append(fitness)
	WriteFitness()
#calls the main function
main()

#Reads the veff output file for the antenna, returns the average veff
def ReadVeff(NSEEDS, antenna_file):
	veff_list = []
	out_list = []
	with open(antenna_file, newline = '') as out_file:
		out_reader = csv.reader(out_file, delimiter='\t')
		for output in out_reader:
			out_list.append(output)
			
	for i in range(out_list):
		veff_list.append(outList[i][1])
	veff_sum = sum(veffList)
	veff = veff_sum/NSEEDS
	return veff

#Writes the fitnessScores data into a csv file
def WriteFitness(f_scores):
	with open('fitnessScores.csv', 'w') as csv_file:
		f.write("The Ohio State University GENETIS Data.\n")
		f.write("Current generation's fitness scores:\n")
		for i in range(g.NPOP):
			f.write(fitnesScores[i]+"\n")

