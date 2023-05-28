__author__ = 'Dylan Wells <wells.1629@osu.edu>'

# Imports
import argparse
import math
from pathlib import Path

import pandas as pd

# Arguments
desc = ("This script will combine the errors and fitness scores "
        "of individuals made with reproduction")
parser = argparse.ArgumentParser(description=desc)
parser.add_argument("source", help="source directory for fitness files", type=Path)
parser.add_argument("gen", help="Generation number.", type=int)

g = parser.parse_args()

source_dir = g.source
curr_gen = g.gen
prev_gen = g.gen - 1
parents_csv = source_dir / f'{curr_gen}_parents.csv'
prev_fitness = source_dir / f'{prev_gen}_fitnessScores.csv'
curr_fitness = source_dir / f'{curr_gen}_fitnessScores.csv'
prev_errors = source_dir / f'{prev_gen}_errorBars.csv'
curr_errors = source_dir / f'{curr_gen}_errorBars.csv'

# load in the parents.csv file to find inviduals made from reproduction
skiprows = 4
parents_csv = pd.read_csv(parents_csv, header=0, 
                          delimiter=',', skiprows=skiprows)
operators = parents_csv.iloc[:, 3].values

reproduced = []

for i, op in enumerate(operators):
    if op == ' Reproduction':
        reproduced.append(i)
        
parents = parents_csv.iloc[:, 1].values
parents = [int(parents[i]) for i in reproduced]

print(f"Combining errors and fitness scores of individuals {reproduced}")

def load_csv(fitness_csv, error_csv, iterator):
    fitness_files = pd.read_csv(fitness_csv, header=None)
    error_file = pd.read_csv(error_csv, header=None)
    
    fitness_scores = fitness_files.iloc[:, 0].values
    err_plus = error_file.iloc[:, 0].values
    err_minus = error_file.iloc[:, 1].values
    
    fitness_scores = [float(fitness_scores[i]) for i in iterator]
    err_plus = [float(err_plus[i]) for i in iterator]
    err_minus = [float(err_minus[i]) for i in iterator]
    
    return fitness_scores, err_plus, err_minus

p_fitness_scores, p_err_plus, p_err_minus = load_csv(prev_fitness, prev_errors, parents)
c_fitness_scores, c_err_plus, c_err_minus = load_csv(curr_fitness, curr_errors, reproduced)

new_fitness_scores = []
new_err_plus = []
new_err_minus = []

# combine the errors and fitnesses of parents and children
def combine_measurements(m1, err1_plus, err1_minus, m2, err2_plus, err2_minus):
    weight1 = err1_plus + err1_minus
    weight2 = err2_plus + err2_minus
    
    combined_measurement = (
        (m1 / (weight1**2) + m2 / (weight2**2)) /
        (1/(weight1**2) + 1/(weight2**2))
    )
    
    combined_err_plus = math.sqrt(1/(1/(err1_plus**2) + 1/(err2_plus**2)))
    combined_err_minus = math.sqrt(1/(1/(err1_minus**2) + 1/(err2_minus**2)))
    
    return combined_measurement, combined_err_plus, combined_err_minus
    
for i in range(len(p_fitness_scores)):
    new_fitness, plus_err, minus_err = combine_measurements(p_fitness_scores[i], p_err_plus[i], 
                                                            p_err_minus[i], c_fitness_scores[i], 
                                                            c_err_plus[i], c_err_minus[i])
    new_fitness_scores.append(new_fitness)
    new_err_plus.append(plus_err)
    new_err_minus.append(minus_err)

fitness_csv = pd.read_csv(curr_fitness, header=None)
errors_csv = pd.read_csv(curr_errors, header=None)

# Reconstruct the fitness csv file with the new fitness scores at indexes of reproduction
for i in reproduced:
    fitness_csv.iloc[i, 0] = new_fitness_scores.pop(0)
    errors_csv.iloc[i, 0] = new_err_plus.pop(0)
    errors_csv.iloc[i, 1] = new_err_minus.pop(0)

# Write the new fitness csv file
fitness_csv.to_csv(f'{g.source}/{g.gen}_fitnessScores.csv', index=False, header=False)
errors_csv.to_csv(f'{g.source}/{g.gen}_errorBars.csv', index=False, header=False)

print("Done combining errors and fitness scores")
