# Get the indices of the best, middle, and worst detectors from the fitness scores
import argparse
import numpy as np

from pathlib import Path

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("source", help="Name of source folder from home directory", type=Path)
    parser.add_argument("gen", help="Generation number (ex:0)", type=int)
    return parser.parse_args()

def main(args):
    # Read in the Fitness scores
    fitness_scores = np.loadtxt(args.source / f'{g.gen}_fitnessScores.csv',
                                delimiter=',', skiprows=0, unpack=True)
    
    # Get the indices of the best, middle, and worst detectors
    sorted_indices = np.argsort(fitness_scores)
    max_index = sorted_indices[-1]+1
    mid_index = sorted_indices[round(len(fitness_scores)/2)]+1
    min_index = sorted_indices[0]+1

    # Print the indices for bash to parse
    print(f"{max_index} {mid_index} {min_index}")


if __name__ == "__main__":
    args = parse_args()
    main(args)