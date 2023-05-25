#!/usr/bin/env python
__author__ = "Dylan Wells <wells.1629@osu.edu>"
'''
=======================
Description: This file will create the physics of results plots for the
GENETIS Pueo project.

This script will take in the location for IceFinal root files for an
individual and loop through them, pull variables, and plot them.
=======================
Usage:
python physicsOfResultsPUEO.py <source> <destination> <indiv> <energy>
<source> = location of IceFinal root files
<destination> = location to save plots
# <gen> = generation number
<indiv> = individual number
<energy> = energy of neutrino
=======================
example: python physicsOfResultsPUEO.py /fs/ess/PAS1960/HornEvolutionOSC/GENETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/2023_05_08/Root_Files/10_Root_Files /users/PAS1960/dylanwells1629/plots 10 2 19
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
parser = argparse.ArgumentParser()
parser.add_argument("source", help="source directory of root files", type=str)
parser.add_argument("destination", help="destination directory for plots", type=str)
# parser.add_argument("gen", help="generation number", type=int)
parser.add_argument("indiv", help="individual number", type=int)
parser.add_argument("energy", help="energy of neutrino", type=int)
g=parser.parse_args()

ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libNiceMC.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libAntarcticaRoot.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libAnitaEvent.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libPueoSim.so")
ROOT.gInterpreter.Declare('#include "Geoid.h"')

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
success_runs = []

var = ['trigg', 'passed', 'passWeight', 'rawWeights', 
       'position', 'neutrinoFlavor', 
       'interactionLength', 'interactionCrossSection',
       'interactionStrength', 'showerPnuEv', 'maxEField', 
       'maxEFieldFreq', 'nu_e', 'nu_m', 'nu_t']

for x in var:
    var_dict['{0}'.format(x)] = []

#Functions
def getFiles(source, energy, indiv):
    
    # The root files will be located in the 
    # $WorkingDir/Run_Outputs/$RunName/Root_Files/$genNum_Root_Files/ directory
    # The root files will be named IceFinal_$genNum_$indiv_$seed.root

    root = source
    print(root)
    pattern = "IceFinal_*_{}_*.root".format(indiv)


    # Walk through the directory and find the root files
    for path, subdirs, files in os.walk(root):
        j = 0
        for name in files:
            if fnmatch(name, pattern):
                print(os.path.join(path, name))
                
                try:
                    # Open the root file and assign the trees to variables
                    fileName = os.path.join(path, name)
                    IceFinalFile = ROOT.TFile(fileName)
                    
                    nuWeights = []
                    nuPasses = []

                    allTree = IceFinalFile.allTree
                    allEvents = allTree.GetEntries()

                    TotalEvents[energy].append(allEvents)
                    passTree = IceFinalFile.passTree
                    passEvents = passTree.GetEntries()
                except:
                    print("Error opening file")
                    continue
                success_runs.append(fileName)
                
                for i in range(0,passEvents):
                    j = j + 1
                    
                    passTree.GetEvent(i)
                    allTree.GetEvent(i)
                    
                    # Part from rootAnalysis.py
                    nuPasses.append(1)
                    nuWeights.append(passTree.event.neutrino.path.weight
                                     /(passTree.event.loop.positionWeight
                                       *passTree.event.loop.directionWeight))
                    RawWeights[energy].append(nuWeights[-1])

                    # collecting varaibles in the dictionary

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
                    if(passTree.event.neutrino.flavor==1):
                        nu_e = 1
                        nu_m = 0
                        nu_t = 0
                    elif(passTree.event.neutrino.flavor==2):
                        nu_e = 0
                        nu_m = 1
                        nu_t = 0
                    else:
                        nu_e = 0
                        nu_m = 0
                        nu_t = 1
                    
                    all_var = [trigg, passed, passWeight, rawWeights,
                               position, neutrinoFlavor, 
                               interactionLength, interactionCrossSection, 
                               interactionStrength, showerPnuEv, maxEField,
                               maxEFieldFreq, nu_e, nu_m, nu_t]
                    
                    for k in range(1, len(all_var)):
                        var_dict['{0}'.format(var[k])].append(all_var[k])
                    
                PassingEvents[energy].append(np.sum(nuPasses))
                PassingWeights[energy].append(np.sum(nuWeights))
    print("Number of events: {}".format(np.sum(TotalEvents[energy])))
    print("Number of passing events: {}".format(np.sum(PassingEvents[energy])))
    print("Done collecting variables")

getFiles(g.source, g.energy, g.indiv)


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

#plot the interaction length against the interaction cross section
fig2 = plt.figure()
ax2 = fig2.add_subplot(111)
ax2.scatter(var_dict['interactionLength'], var_dict['interactionCrossSection'], s=1)
ax2.set_xlabel('Interaction Length (m)')
ax2.set_ylabel('Interaction Cross Section (m$^2$)')
ax2.set_title('Interaction Length vs Interaction Cross Section for {} EeV Neutrinos'.format(g.energy))
ax2.grid(True)
fig2.savefig('{}/{}_interactionLength_vs_interactionCrossSection_bestindiv.png'.format(g.destination, g.indiv))

#plot the interaction length against the interaction strength
fig3 = plt.figure()
ax3 = fig3.add_subplot(111)
ax3.scatter(var_dict['interactionLength'], var_dict['interactionStrength'], s=1)
ax3.set_xlabel('Interaction Length (m)')
ax3.set_ylabel('Interaction Strength')
ax3.set_title('Interaction Length vs Interaction Strength for {} EeV Neutrinos'.format(g.energy))
ax3.grid(True)
fig3.savefig('{}/{}_interactionLength_vs_interactionStrength_bestindiv.png'.format(g.destination, g.indiv))

#plot the maximum electric field against the maximum electric field frequency
fig4 = plt.figure()
ax4 = fig4.add_subplot(111)
ax4.scatter(var_dict['maxEField'], var_dict['maxEFieldFreq'], s=1)
ax4.set_xlabel('Maximum Electric Field (V/m)')
ax4.set_ylabel('Maximum Electric Field Frequency (Hz)')
ax4.set_title('Maximum Electric Field vs Maximum Electric Field Frequency for {} EeV Neutrinos'.format(g.energy))
ax4.grid(True)
fig4.savefig('{}/{}_maxEField_vs_maxEFieldFreq_bestindiv.png'.format(g.destination, g.indiv))

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

