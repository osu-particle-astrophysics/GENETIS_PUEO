#To run this script osc you will need to run the following commands: (This will install a local version of the kaleido package)
# module laod python/3.9-2022.05
# pip install -U kaleido
#

import plotly.express as px
import pandas as pd
import argparse
import numpy as np

parser = argparse.ArgumentParser()

#parser.add_argument("GenNumber", help="Generation number the code is running on (for formatting purposes)", type=int)
parser.add_argument("location", help="Location of runData.csv and fitness.csv", type=str)
g = parser.parse_args()

#load in the plotting data
maxFits, minFits, maxErrors = np.loadtxt(g.location + "/plottingData.csv", delimiter=',', skiprows=0, unpack=True)
maxFit = maxFits.max()
minFit = minFits.min()

data = pd.read_csv(g.location+"/testpara.csv")
#We want the range of colors to be from the minimum fitness to the maximum fitness
fig = px.parallel_coordinates(data, color = "Fitness", color_continuous_scale = px.colors.sequential.Turbo, dimensions = ["SideLength","Height","XInitial","YInital","ZFinal","YFinal","Beta","Generation"],labels={"SideLength": "Side Length (cm)","Height": "Height (cm)","XInitial": "Initial X (cm)","YInital": "Initial Y (cm)","ZFinal": "Final Z (cm)","YFinal": "Final Y (cm)","Beta": "Beta","Generation": "Generation"},color_continuous_midpoint=22500, range_color = [minFit, maxFit])
fig.write_image(g.location+"/Rainbow_Plot.png")


