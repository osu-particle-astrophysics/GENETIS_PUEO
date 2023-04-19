import numpy as np		
import matplotlib.pyplot as plt			
import argparse
import matplotlib.cm as cm
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory", type=str)
parser.add_argument("numGens", help="Number of generations the code is running for", type=int)
parser.add_argument("NPOP", help="Number of individuals in a population", type=int)
g = parser.parse_args()

Veff = []
Err_plus = []
Err_minus = []
VeffArray = []
Err_plusArray = []
Err_minusArray = []

tempVeff = []
tempErr_plus = []
tempErr_minus = []

def read_veff(antenna_file):
    veff_list = pd.read_csv(antenna_file, header=None)
    veff_list = np.array(veff_list)
    veff_list = veff_list.flatten()
    veff_list = veff_list.tolist()
    tempVeff.append(veff_list)

def read_errors(error_file):
    plus_errors = pd.read_csv(error_file, usecols=[0], header=None)
    minus_errors = pd.read_csv(error_file, usecols=[1], header=None)
    plus_errors = np.array(plus_errors)
    plus_errors = plus_errors.flatten()
    minus_errors = np.array(minus_errors)
    minus_errors = minus_errors.flatten()
    plus_errors = plus_errors.tolist()
    minus_errors = minus_errors.tolist()
    tempErr_plus.append(plus_errors)
    tempErr_minus.append(minus_errors)

for gen in range(0, g.numGens+1):
    read_veff(g.source + "/" + str(gen) + "_vEffectives.csv")
    read_errors(g.source + "/" + str(gen) + "_errorBars.csv")
#re format the data into veffArray
for ind in range(0, g.NPOP):
    for gen in range(0, g.numGens+1):
        Veff.append(tempVeff[gen][ind])
        Err_plus.append(tempErr_plus[gen][ind])
        Err_minus.append(tempErr_minus[gen][ind])
    VeffArray.append(Veff)
    Err_plusArray.append(Err_plus)
    Err_minusArray.append(Err_minus)
    Veff = []
    Err_plus = []
    Err_minus = []

genAxis = np.linspace(0,g.numGens,g.numGens+1, endpoint=True)

#print(genAxis)
#print(Veff_ARA)

#Veff_ARA_Ref = Veff_ARA * np.ones(len(genAxis))
plt.figure(figsize = (10, 8))

#plt.plot(genAxis, Veff_ARA_Ref, label = "ARA Reference", marker = 'o', color = 'k')
#plt.axhline(y=Veff_ARA, linestyle = '--', color = 'k')

ax = plt.subplot(111)

ax.set_ylim(bottom = -0.2, top = max(max(VeffArray)) + max(max(Err_plusArray)) + 0.5)
colors = cm.rainbow(np.linspace(0, 1, g.NPOP))

for ind in range(0, g.NPOP):
    LabelName = "{}".format(ind+1)
    yerr_plus = Err_plusArray[ind]
    yerr_minus = Err_minusArray[ind]
    #ax.xlabel('Generation', size = 21)
    #ax.ylabel('Fitness Score (Ice Volume) ($km^3$sr)', size = 21)
    #ax.title('Generation', size = 21)
    plt.errorbar(genAxis, VeffArray[ind], yerr = [yerr_minus, yerr_plus], label = LabelName, marker = 'o', color = colors[ind], linestyle = '', alpha=0.4, markersize = 18)
  

plt.xlabel('Generation', size = 26)
plt.ylabel('V\u03A9$_{eff}$ (km$^3$str)', size = 26)
plt.title("V\u03A9$_e$$_f$$_f$ over Generations (0 - {})".format(int(g.numGens)), size = 30)
#plt.legend()
plt.savefig(g.destination + "/" + "Veff_plot.png")
#plt.show(block=False)
#plt.pause(10)
