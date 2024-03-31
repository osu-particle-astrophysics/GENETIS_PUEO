__author__ = 'Dylan Wells <wells.1629@osu.edu'

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
parser.add_argument("NPOP", help="Number of individuals in the population.", type=int)

g = parser.parse_args()

source_dir = g.source
curr_gen = g.gen
prev_gen = g.gen - 1
prev_DNA_file = source_dir / f'{prev_gen}_generationDNA.csv'
curr_DNA_file = source_dir / f'{curr_gen}_generationDNA.csv'
prev_fitness = source_dir / f'{prev_gen}_fitnessScores.csv'
curr_fitness = source_dir / f'{curr_gen}_fitnessScores.csv'
prev_errors = source_dir / f'{prev_gen}_errorBars.csv'
curr_errors = source_dir / f'{curr_gen}_errorBars.csv'

identical_indivs = []

# Load in the DNA files from the previous and current generation
# variables are S, H, Xi, Yi, Zf, Yf, beta 
intro_rows = 9

def read_DNA(DNA_file):
    '''Return a list of tuples containing the DNA of each individual in the population'''
    DNA_csv = pd.read_csv(DNA_file, header=None, 
                          delimiter=',', skiprows=intro_rows)
    DNA = {
        "S": DNA_csv.iloc[:, 0].values,
        "H": DNA_csv.iloc[:, 1].values,
        "Xi": DNA_csv.iloc[:, 2].values,
        "Yi": DNA_csv.iloc[:, 3].values,
        "Yf": DNA_csv.iloc[:, 4].values,
        "Zf": DNA_csv.iloc[:, 5].values,
        "beta": DNA_csv.iloc[:, 6].values
    }
    DNA_list = []
    for i in range(g.NPOP):
        DNA_list.append((DNA["S"][i], DNA["H"][i], DNA["Xi"][i], 
                         DNA["Yi"][i], DNA["Zf"][i], DNA["Yf"][i], 
                         DNA["beta"][i]))
    return DNA_list

prev_DNA = read_DNA(prev_DNA_file)
curr_DNA = read_DNA(curr_DNA_file)

identical_dict = {}

# Loop through the DNA of the two generations and find the individuals
# that have identical DNA
for i in range(g.NPOP):
    for j in range(g.NPOP):
        if prev_DNA[i] != curr_DNA[j]:
            continue
        print(f"Individual {i} in generation {prev_gen} has identical DNA to individual {j} in generation {curr_gen}")
        try:
            identical_dict[prev_DNA[i]][0].append(i) if i not in identical_dict[prev_DNA[i]][0] else print(f"Individual {i} already in list 0")
            identical_dict[prev_DNA[i]][1].append(j) if j not in identical_dict[prev_DNA[i]][1] else print(f"Individual {j} already in list 1")
        except KeyError:
            identical_dict[prev_DNA[i]] = [[i], [j]]

print(identical_dict)

def load_csv(fitness_csv, error_csv, iterator):
    '''Return the fitness scores and errors of the individuals in the iterator'''
    fitness_files = pd.read_csv(fitness_csv, header=None)
    error_file = pd.read_csv(error_csv, header=None)
    
    fitness_scores = fitness_files.iloc[:, 0].values
    err_plus = error_file.iloc[:, 0].values
    err_minus = error_file.iloc[:, 1].values
    
    fitness_scores = [float(fitness_scores[i]) for i in iterator]
    err_plus = [float(err_plus[i]) for i in iterator]
    err_minus = [float(err_minus[i]) for i in iterator]
    
    return fitness_scores, err_plus, err_minus


def combine_measurements(measurements, plus_errs, minus_errs):
    '''Return the combined measurement and errors of the measurements'''
    errs = [(plus_errs[i] + minus_errs[i])/2 for i in range(len(plus_errs))]
    weights = [1/(errs[i]**2) for i in range(len(errs))]
    
    combined_measurement = sum([measurements[i] * weights[i] for i in range(len(measurements))]) / sum(weights)
    combined_err_plus = math.sqrt(1/sum([1/(plus_errs[i]**2) for i in range(len(plus_errs))]))
    combined_err_minus = math.sqrt(1/sum([1/(minus_errs[i]**2) for i in range(len(minus_errs))]))
    
    return combined_measurement, combined_err_plus, combined_err_minus
    

def calculateCombinations(matches):
    '''Return the combined fitness scores and errors of the individuals in the matches list'''
    parents = matches[0]
    children = matches[1]
    print(f"Combining errors and fitness scores of parents: {parents} and children: {children}")
    p_fitness_scores, p_err_plus, p_err_minus = load_csv(prev_fitness, prev_errors, parents)
    c_fitness_scores, c_err_plus, c_err_minus = load_csv(curr_fitness, curr_errors, children)
    
    # As the parents have already combined errors if there exist multiple of them,
    # we only want to consider the values of one of them
    fitness_scores = [p_fitness_scores[0]] + c_fitness_scores
    err_plus = [p_err_plus[0]] + c_err_plus
    err_minus = [p_err_minus[0]] + c_err_minus
    print(f"Fitness scores: {fitness_scores}")
    print(f"Errors: {err_plus}, {err_minus}")
    combined_fitness, combined_err_plus, combined_err_minus = combine_measurements(fitness_scores, err_plus, err_minus)
    print("Combined fitness score: ", combined_fitness)
    return combined_fitness, combined_err_plus, combined_err_minus
        
    
for key in identical_dict.keys():
    combined_fitness, combined_err_plus, combined_err_minus = calculateCombinations(identical_dict[key])
    print(f"Combined fitness score of {key}: {combined_fitness} +{combined_err_plus} -{combined_err_minus}")
    
    #Now write the combined fitness score and errors to the fitness and error files
    
    fitness_csv = pd.read_csv(curr_fitness, header=None)
    errors_csv = pd.read_csv(curr_errors, header=None)
    
    for i in identical_dict[key][1]:
        fitness_csv.iloc[i, 0] = combined_fitness
        errors_csv.iloc[i, 0] = combined_err_plus
        errors_csv.iloc[i, 1] = combined_err_minus
    
    fitness_csv.to_csv(curr_fitness, header=False, index=False)
    errors_csv.to_csv(curr_errors, header=False, index=False)
    
print("Finished writing combined fitness scores and errors to files!!")
