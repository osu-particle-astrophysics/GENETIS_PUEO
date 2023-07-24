import pandas as pd
import numpy as np
import argparse

from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("source", help="", type=Path)
parser.add_argument("npop", help="", type=int)
parser.add_argument("gen", help="", type=int)
g = parser.parse_args()

fitnesses = np.zeros(g.npop)
error_plusses = np.zeros(g.npop)
error_minuses = np.zeros(g.npop)
for i in range(g.npop):
    #get the single line of the csv file as a float
    df = pd.read_csv(g.source / str(i) / f'{g.gen}_pueoOut.csv', header=None)
    #fitness is in the first row second column
    fitness = df.iloc[0,1]
    error_plus = df.iloc[0,2]
    error_minus = df.iloc[0,3]
    fitnesses[i] = fitness
    errror_plusses[i] = error_plus
    error_minuses[i] = error_minus
    

# write the fitnesses and errors to csv files
np.savetxt(g.source / f'{g.gen}_fitnessScores.csv', fitnesses, delimiter=",")
np.savetxt(g.source / f'{g.gen}_errorBars.csv', np.column_stack((error_plusses, error_minuses)), delimiter=",")
    
