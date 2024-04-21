# Create The Rainbow Plots
import plotly.express as px
import pandas as pd
import argparse
import numpy as np

from pathlib import Path

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("source", help="Location of runData.csv and fitness.csv", type=Path)
    parser.add_argument('destination', help="Location to save the plot", type=Path)
    return parser.parse_args()

def main(args):
    #load in the plotting data
    maxFits, minFits, maxErrors = np.loadtxt(args.source / "plottingData.csv", 
                                            delimiter=',', skiprows=0, unpack=True)
    maxFit = maxFits.max()
    minFit = minFits.min()

    data = pd.read_csv(g.location / "testpara.csv")

    #We want the range of colors to be from the minimum fitness to the maximum fitness
    fig = px.parallel_coordinates(data, color = "Fitness", 
                                color_continuous_scale = px.colors.sequential.Turbo, 
                                dimensions = ["SideLength","Height","XInitial","YInital",
                                                "YFinal","ZFinal","Beta","Generation"],
                                labels={"SideLength": "Side Length (cm)","Height": "Height (cm)",
                                        "XInitial": "Initial X (cm)","YInital": "Initial Y (cm)",
                                        "YFinal": "Final Y (cm)","ZFinal": "Final Z (cm)",
                                        "Beta": "Beta","Generation": "Generation"},
                                color_continuous_midpoint=22500, range_color = [minFit, maxFit])
    fig.write_image(args.destination / "Rainbow_Plot.png")
    

if __name__ == "__main__":
    args = parse_args()
    main(args)
