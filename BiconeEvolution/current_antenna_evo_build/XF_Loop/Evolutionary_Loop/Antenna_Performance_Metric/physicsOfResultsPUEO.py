#!/usr/bin/env python
__author__ = "Dylan Wells <wells.1629@osu.edu>"
'''
=======================
Use `python physicsOfResultsPUEO.py --help` for usage instructions.
=======================
example usage: python physicsOfResultsPUEO.py /fs/ess/PAS1960/HornEvolutionOSC/GENETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/2023_05_08/Root_Files/10_Root_Files /users/PAS1960/dylanwells1629/plots 2 19
=======================
'''

# Imports
import os
import argparse
from collections import defaultdict
from fnmatch import fnmatch

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

import ROOT

# Global Variables
desc = 'Create the physics of results plots for the GENETIS Pueo project.'
parser = argparse.ArgumentParser(description=desc)
parser.add_argument("source", help="source directory of root files", type=str)
parser.add_argument("destination", help="destination directory for plots", type=str)
# parser.add_argument("gen", help="generation number", type=int)
parser.add_argument("indiv", help="individual number", type=int)
parser.add_argument("energy", help="energy of neutrino", type=int)
g = parser.parse_args()

ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libNiceMC.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libAntarcticaRoot.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libAnitaEvent.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libPueoSim.so")
ROOT.gInterpreter.Declare('#include "Geoid.h"')

#ROOT.gSystem.Load("/users/PAS1960/dylanwells1629/buildingPueoSim/pueoBuilder/lib/libNiceMC.so")
#ROOT.gSystem.Load("/users/PAS1960/dylanwells1629/buildingPueoSim/pueoBuilder/lib/libAntarcticaRoot.so")
#ROOT.gSystem.Load("/users/PAS1960/dylanwells1629/buildingPueoSim/pueoBuilder/lib/libAnitaEvent.so")
#ROOT.gSystem.Load("/users/PAS1960/dylanwells1629/buildingPueoSim/pueoBuilder/lib/libPueoSim.so")
#ROOT.gInterpreter.Declare('#include "Geoid.h"')

'''
# Variables used in Dennis' code
#list of all variable names
        var = ['trigg', 'weight', 'posnu_x', 'posnu_y', 'posnu_z',
               'rec_ang_0', 'theta_rec_0', 'reflect_ang_0',
               'dist_0', 'arrival_time_0', 'reflection_0', 
               'l_att_0', 'view_ang_0', 'launch_ang_0',
               'rec_ang_1', 'theta_rec_1', 'reflect_ang_1',
               'dist_1', 'arrival_time_1', 'reflection_1', 
               'l_att_1', 'view_ang_1', 'launch_ang_1',
               'current', 'flavor', 'elast',
               'nnu_theta', 'nnu_phi', 'ShowerEnergy',
               'depth', 'distance']
'''
var_dict = {}
PassingEvents = defaultdict(list)
PassingWeights = defaultdict(list)
TotalEvents = defaultdict(list)
RawWeights = defaultdict(list)

var = ['trigg', 'passed', 'passWeight', 'rawWeights', 
       'position', 'neutrinoFlavor', 
       'interactionLength', 'interactionCrossSection',
       'interactionStrength', 'showerPnuEv', 'maxEField', 
       'maxEFieldFreq', 'nu_e', 'nu_m', 'nu_t', 'RFx', 'RFy', 
       'RFz', 'RFdirCosTheta', 'RFdirTheta', 'nuDirCosTheta', 'nuDirTheta']

waveformV_array = []
waveformH_array = []

for x in var:
    var_dict['{0}'.format(x)] = []

#Functions
def getFiles(source, energy, indiv):
    
    # The root files will be located in the 
    # $WorkingDir/Run_Outputs/$RunName/Root_Files/$genNum_Root_Files/ directory
    # The root files will be named IceFinal_$genNum_$indiv_$seed.root

    root = source
    print(root)
    all_tree_pattern = "IceFinal_allTree_*_{}_*.root".format(indiv)
    pass_tree_pattern = "IceFinal_passTree_*_{}_*_1.root".format(indiv)

    # Walk through the directory and find the root files
    for path, subdirs, files in os.walk(root):
        j = 0
        for name in files:
            if fnmatch(name, all_tree_pattern):
                print(os.path.join(path, name))
                
                try:
                    # Open the root file and assign the trees to variables
                    fileName = os.path.join(path, name)
                    IceFinalFile = ROOT.TFile(fileName)
                    

                    allTree = IceFinalFile.allTree
                    allEvents = allTree.GetEntries()
                    print(allEvents)
                    TotalEvents[energy].append(allEvents)
                    
                except:
                    print("Error opening file")
                    continue
                
            elif fnmatch(name, pass_tree_pattern):
                print(os.path.join(path, name))
                
                try:    
                    
                    fileName = os.path.join(path, name)
                    IceFinalFile = ROOT.TFile(fileName)
                    
                    passTree = IceFinalFile.passTree
                    passEvents = passTree.GetEntries()
                    
                    nuWeights = []
                    nuPasses = []
                    print(passEvents)
                    
                except:
                    print("Error opening file")
                    continue
                
                
                waveformsH = []
                waveformsV = []
                for i in range(passEvents):
                    j += 1
                    
                    passTree.GetEvent(i)
                
                    # Part from rootAnalysis.py
                    nuPasses.append(1)
                    nuWeights.append(passTree.event.neutrino.path.weight
                                    /(passTree.event.loop.positionWeight
                                    *passTree.event.loop.directionWeight))
                    RawWeights[energy].append(nuWeights[-1])

                    # collecting varaibles in the dictionary
                    waveformsV = passTree.event.waveformsV
                    waveformsH = passTree.event.waveformsH
                    
                    trigg = j
                    var_dict['trigg'].append(j)
                    passed = 1
                    passWeight = nuWeights[-1]
                    rawWeights = nuWeights[-1]
                    position = passTree.event.interaction.position
                    #pathEntry = passTree.event.neutrino.path.entry doesn't seem to be included
                    #pathExit = passTree.event.neutrino.path.exit
                    neutrinoFlavor = passTree.event.neutrino.flavor
                    interactionLength = passTree.event.interaction.length
                    interactionCrossSection = passTree.event.interaction.crossSection
                    interactionStrength = passTree.event.interaction.strength
                    showerPnuEv = passTree.event.shower.pnu.eV
                    maxEField = passTree.event.signalSummaryAtDetector.maxEField
                    maxEFieldFreq = passTree.event.signalSummaryAtDetector.maxEFieldFreq
                    RFdirCosTheta = passTree.event.RFdir.CosTheta()
                    RFx = passTree.event.RFdir.X()
                    RFy = passTree.event.RFdir.Y()
                    RFz = passTree.event.RFdir.Z()
                    RFdirTheta = passTree.event.RFdir.Theta()
                    nuDirCosTheta = passTree.event.neutrino.path.direction.CosTheta()
                    nuDirTheta = passTree.event.neutrino.path.direction.Theta()
                    
                    if passTree.event.neutrino.flavor == 1:
                        nu_e, nu_m, nu_t = 1, 0, 0
                    elif passTree.event.neutrino.flavor == 2:
                        nu_e, nu_m, nu_t = 0, 1, 0
                    else:
                        nu_e, nu_m, nu_t = 0, 0, 1
                    
                    all_var = [trigg, passed, passWeight, rawWeights,
                            position, neutrinoFlavor, 
                            interactionLength, interactionCrossSection, 
                            interactionStrength, showerPnuEv, maxEField,
                            maxEFieldFreq, nu_e, nu_m, nu_t, RFx, RFy, 
                            RFz, RFdirCosTheta, RFdirTheta, nuDirCosTheta, nuDirTheta]
                    
                    for k, v in enumerate(all_var):
                        var_dict[var[k]].append(v)
                    
                PassingEvents[energy].append(np.sum(nuPasses))
                PassingWeights[energy].append(np.sum(nuWeights))
                waveformH_array.append(waveformsH)
                waveformV_array.append(waveformsV)
    print("Number of events: {}".format(np.sum(TotalEvents[energy])))
    print("Number of passing events: {}".format(np.sum(PassingEvents[energy])))
    print("Done collecting variables")

getFiles(g.source, g.energy, g.indiv)

print(waveformH_array, waveformV_array)
print(len(waveformH_array), len(waveformV_array))
try:
    print(waveformH_array[0].size(), waveformV_array[0].size())
except:
    print("didn't work")

print("Plotting")
### Plotting ###
mpl.rcParams['text.usetex'] = True
# colorblind friendly colors
plotting_colors = ['#00429d', '#4771b2', '#73a2c6', '#a5d5d8', '#ffffe0', '#ffbcaf', '#f4777f', '#cf3759', '#93003a']

#plotting the number of each type of neutrino that passed
#Note: 1 = nu_e, 2 = nu_mu, 3 = nu_tau
fig1 = plt.figure()
ax1 = fig1.add_subplot(111)
N, bins, patches = ax1.hist(var_dict['neutrinoFlavor'], bins=3, range=(0.5, 3.5), align='mid', rwidth=0.8)
patches[0].set_facecolor(plotting_colors[0])
patches[1].set_facecolor(plotting_colors[4])
patches[2].set_facecolor(plotting_colors[-1])
ax1.set_xlabel('Neutrino Flavor')
ax1.set_ylabel('Number of Neutrinos')
ax1.set_title('Neutrino Flavor for {} EeV Neutrinos'.format(g.energy))
ax1.set_xticks([1, 2, 3])
ax1.set_xticklabels(['$\\nu_e$', '$\\nu_\\mu$', '$\\nu_\\tau$'])
ax1.grid(True)
fig1.savefig('{}/{}_neutrinoFlavor_bestindiv.png'.format(g.destination, g.indiv))

#plot a 2d histogram of the maximum electric field against the maximum electric field frequency
fig5 = plt.figure()
ax5 = fig5.add_subplot(111)
N, xedges, yedges, im = ax5.hist2d(var_dict['maxEField'], var_dict['maxEFieldFreq'], bins=100, range=[[0, max(var_dict['maxEField'])], [0, max(var_dict['maxEFieldFreq'])]], norm=mpl.colors.LogNorm())
ax5.set_xlabel('Maximum Electric Field (V/m)', fontsize=12)
ax5.set_ylabel('Maximum Electric Field Frequency (Hz)', fontsize=12)
ax5.set_title('Maximum Electric Field vs Maximum Electric Field Frequency for {} EeV Neutrinos'.format(g.energy), fontsize=13, fontweight='bold')
ax5.grid(True)
cbar = fig5.colorbar(im, ax=ax5)
cbar.set_label('Number of Neutrinos')
cbar.set_ticks([1, 10, 100, 1000, 10000, 100000])
cbar.set_ticklabels(['1', '10', '100', '1000', '10000', '100000'])
fig5.savefig('{}/{}_maxEField_vs_maxEFieldFreq_2d_bestindiv.png'.format(g.destination, g.indiv))

#plot RF direction
fig6 = plt.figure()
ax6 = fig6.add_subplot(111)
ax6.scatter(var_dict['RFx'], var_dict['RFy'], s=1)
ax6.set_xlabel('RFx')
ax6.set_ylabel('RFy')
ax6.set_title('RF Direction for {} EeV Neutrinos'.format(g.energy))
ax6.grid(True)
fig6.savefig('{}/{}_RF_direction_bestindiv.png'.format(g.destination, g.indiv))

#Plot a histogram of the RF direction cosine theta
fig7 = plt.figure()
ax7 = fig7.add_subplot(111)
N, bins, patches = ax7.hist(var_dict['RFdirCosTheta'], bins=100, range=(0, 1), align='mid', rwidth=0.8, color=plotting_colors[0])
ax7.set_xlabel('RF Direction Cosine $\\theta$')
ax7.set_ylabel('Number of Events')
ax7.set_title('RF Direction Cosine $\\theta$ for {} EeV Neutrinos'.format(g.energy))
ax7.grid(True)
fig7.savefig('{}/{}_RFdirCosTheta_bestindiv.png'.format(g.destination, g.indiv))

#Plot a histogram of the neutrino direction cosine theta
fig9 = plt.figure()
ax9 = fig9.add_subplot(111)
N, bins, patches = ax9.hist(var_dict['nuDirCosTheta'], bins=100, range=(0, 1), align='mid', rwidth=0.8, color = plotting_colors[-1])
ax9.set_xlabel('Neutrino Direction Cosine $\\theta$')
ax9.set_ylabel('Number of Events')
ax9.set_title('Neutrino Direction Cosine $\\theta$ for {} EeV Neutrinos'.format(g.energy))
ax9.grid(True)
fig9.savefig('{}/{}_nuDirCosTheta_bestindiv.png'.format(g.destination, g.indiv))

#Plot a histogram of the neutrino direction theta
fig10 = plt.figure()
ax10 = fig10.add_subplot(111)
N, bins, patches = ax10.hist(var_dict['nuDirTheta'], bins=100, range=(0, 3.14), align='mid', rwidth=0.8, color = plotting_colors[-1])
ax10.set_xlabel('Neutrino Direction $\\theta$ (rad)')
ax10.set_ylabel('Number of Events')
ax10.set_title('Neutrino Direction $\\theta$ for {} EeV Neutrinos'.format(g.energy))
ax10.set_xticks([0, 0.5*np.pi, np.pi])
ax10.set_xticklabels(['0', '$\\frac{1}{2}\\pi$', '$\\pi$'])
ax10.grid(True)
fig10.savefig('{}/{}_nuDirTheta_bestindiv.png'.format(g.destination, g.indiv))