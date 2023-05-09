#To run this script osc you will need to run the following commands: (This will install a local version of the kaleido package)
# module laod python/3.9-2022.05
# pip install -U kaleido
#

import plotly.express as px
import pandas as pd
data = pd.read_csv('Generation_Data/testpara.csv')
fig = px.parallel_coordinates(data, color = "Fitness", color_continuous_scale = px.colors.sequential.Turbo, dimensions = ["SideLength","Height","XInitial","YInital","ZFinal","YFinal","Beta","Generation"],labels={"SideLength": "Side Length (cm)","Height": "Height (cm)","XInitial": "Initial X (cm)","YInital": "Initial Y (cm)","ZFinal": "Final Z (cm)","YFinal": "Final Y (cm)","Beta": "Beta","Generation": "Generation"},color_continuous_midpoint=22500, range_color = [5000,45000])
fig.write_image("Generation_Data/Rainbow_Plot.png")


