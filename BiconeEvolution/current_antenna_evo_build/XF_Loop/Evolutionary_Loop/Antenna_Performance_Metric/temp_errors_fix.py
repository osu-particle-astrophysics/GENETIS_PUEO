#This script will make a csv file with 2 columns and NPOP rows full of zeroes 
import argparse 
import csv
parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="Population size.", type=int)
parser.add_argument("gen", help="current generation", type=int)
g=parser.parse_args()
fileName = str(g.gen) + "_errorBars.csv"
with open(fileName, 'w', newline='') as csvfile:
  writer=csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
  for i in range(g.NPOP):
    writer.writerow(['0','0'])

