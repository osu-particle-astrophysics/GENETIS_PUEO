__author__ = 'Dylan Wells <wells.1629@osu.edu>'

# Imports
import argparse
import math

import pandas as pd

# Arguments
desc = "This script will combine the errors and fitness scores \
        of individuals made with reproduction"
parser = argparse.ArgumentParser(description=desc)
parser.add_argument("source", help="source directory for fitness files", type=str)
parser.add_argument("gen", help="Generation number.", type=int)

g = parser.parse_args()

# load in the parents.csv file to find inviduals made from reproduction
skiprows = 4
parents_csv = pd.read_csv(f'{g.source}/{g.gen}_parents.csv', header=0, 
                          delimiter=',', skiprows=skiprows)
operators = parents_csv.iloc[:, 3].values

reproduced = []

for i, op in enumerate(operators):
    if op == ' Reproduction':
        reproduced.append(i)
print(f"Combining errors and fitness scores of individuals {reproduced}")

# load in the errors and fitnesses of parents
fitness_csv = pd.read_csv(f'{g.source}/{(g.gen)-1}_fitnessScores.csv', header=None)
p_fitness_scores = fitness_csv.iloc[:, 0].values

errors_csv = pd.read_csv(f'{g.source}/{(g.gen)-1}_errorBars.csv', header=None)
p_err_plus = errors_csv.iloc[:, 0].values
p_err_minus = errors_csv.iloc[:, 1].values

p_fitness_scores = [float(p_fitness_scores[i]) for i in reproduced]
p_err_plus = [float(p_err_plus[i]) for i in reproduced]
p_err_minus = [float(p_err_minus[i]) for i in reproduced]

# load in the errors and fitnesses of children
fitness_csv = pd.read_csv(f'{g.source}/{g.gen}_fitnessScores.csv', header=None)
c_fitness_scores = fitness_csv.iloc[:, 0].values

errors_csv = pd.read_csv(f'{g.source}/{g.gen}_errorBars.csv', header=None)
c_err_plus = errors_csv.iloc[:, 0].values
c_err_minus = errors_csv.iloc[:, 1].values

c_fitness_scores = [float(c_fitness_scores[i]) for i in reproduced]
c_err_plus = [float(c_err_plus[i]) for i in reproduced]
c_err_minus = [float(c_err_minus[i]) for i in reproduced]

new_fitness_scores = []
new_err_plus = []
new_err_minus = []

# combine the errors and fitnesses of parents and children
def combine_measurements(m1, err1_plus, err1_minus, m2, err2_plus, err2_minus):
    weight1 = err1_plus + err1_minus
    weight2 = err2_plus + err2_minus
    
    combined_measurement = (m1 / (weight1**2) + m2 / (weight2**2)) / (1/(weight1**2) + 1/(weight2**2))
    
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

# Reconstruct the fitness csv file with the new fitness scores at indexes of reproduction
for i in reproduced:
    fitness_csv.iloc[i, 0] = new_fitness_scores.pop(0)
    errors_csv.iloc[i, 0] = new_err_plus.pop(0)
    errors_csv.iloc[i, 1] = new_err_minus.pop(0)

# Write the new fitness csv file
fitness_csv.to_csv(f'{g.source}/{g.gen}_fitnessScores.csv', index=False, header=False)
errors_csv.to_csv(f'{g.source}/{g.gen}_errorBars.csv', index=False, header=False)

print("Done combining errors and fitness scores")