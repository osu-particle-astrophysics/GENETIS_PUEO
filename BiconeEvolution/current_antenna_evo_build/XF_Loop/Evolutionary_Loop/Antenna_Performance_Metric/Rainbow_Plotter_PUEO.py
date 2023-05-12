#To run this script osc you will need to run the following commands: (This will install a local version of the kaleido package)
# module laod python/3.9-2022.05
# pip install -U kaleido
#

import plotly.express as px
import pandas as pd
import argparse

parser = argparse.ArgumentParser()

#parser.add_argument("GenNumber", help="Generation number the code is running on (for formatting purposes)", type=int)
parser.add_argument("location", help="Location of runData.csv and fitness.csv", type=str)
g = parser.parse_args()

data = pd.read_csv(g.location+"/testpara.csv")
fig = px.parallel_coordinates(data, color = "Fitness", color_continuous_scale = px.colors.sequential.Turbo, dimensions = ["SideLength","Height","XInitial","YInital","ZFinal","YFinal","Beta","Generation"],labels={"SideLength": "Side Length (cm)","Height": "Height (cm)","XInitial": "Initial X (cm)","YInital": "Initial Y (cm)","ZFinal": "Final Z (cm)","YFinal": "Final Y (cm)","Beta": "Beta","Generation": "Generation"},color_continuous_midpoint=22500, range_color = [9000,12000])
fig.write_image(g.location+"/Rainbow_Plot.png")


