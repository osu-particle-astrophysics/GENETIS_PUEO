#!/usr/bin/env python
#This file came from Will with some GENETIS specific modifications by Dylan
# Run with:
# python rootAnalysis.py 1 1 19 /users/PAS1960/dylanwells1629/developing/GENETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Generation_Data 2023_05_08 /users/PAS1960/dylanwells1629/developing/GENETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop

# Imports
import os
import argparse
from collections import defaultdict
from fnmatch import fnmatch

import numpy as np

import ROOT

# Global Variables
desc = 'Analyze the root files and output fitness scores and errors'
parser = argparse.ArgumentParser(description = desc)
parser.add_argument("gen", help="current gen", type=int)
parser.add_argument("indiv", help="Individual", type=int)
parser.add_argument("energy", help="Individual", type=int)
parser.add_argument("opath", help="Output path", type=str)
parser.add_argument("RunName", help="Run Name", type=str)
parser.add_argument("WorkingDir", help="Working Directory", type=str)
g=parser.parse_args()



ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libNiceMC.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libAntarcticaRoot.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libAnitaEvent.so")
ROOT.gSystem.Load("/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/lib/libPueoSim.so")
ROOT.gInterpreter.Declare('#include "Geoid.h"')
'''
ROOT.gSystem.Load("/users/PAS1960/dylanwells1629/buildingPueoSim/pueoBuilder/lib/libNiceMC.so")
ROOT.gSystem.Load("/users/PAS1960/dylanwells1629/buildingPueoSim/pueoBuilder/lib/libAntarcticaRoot.so")
ROOT.gSystem.Load("/users/PAS1960/dylanwells1629/buildingPueoSim/pueoBuilder/lib/libAnitaEvent.so")
ROOT.gSystem.Load("/users/PAS1960/dylanwells1629/buildingPueoSim/pueoBuilder/lib/libPueoSim.so")
ROOT.gInterpreter.Declare('#include "Geoid.h"')
'''

def EffectiveVolume2(thisColor,thisLabel):

    root = g.WorkingDir + "/Run_Outputs/" + g.RunName + "/Root_Files/" + str(g.gen) + "_Root_Files"
    print(root)
    
    allTreePattern = "IceFinal_allTree_" + str(g.gen) + "_" + str(g.indiv) + "_" + "*"
    passTreePattern = "IceFinal_skimmed_" + str(g.gen) + "_" + str(g.indiv) + "_" + "*"

    PassingEvents = defaultdict(list)
    PassingWeights = defaultdict(list)
    TotalEvents = defaultdict(list)
    RawWeights = defaultdict(list)

    success_runs = []

    for path, subdirs, files in os.walk(root):
        for name in files:
            print(name)
            if fnmatch(name,allTreePattern):
                print(os.path.join(path,name))
               
                # this_energy is leftover from Will's code,
                # I'll keep it in case we ever decide to simulate
                # multiple energies at once
                this_energy=g.energy

                try:
                    fileName = os.path.join(path,name)
                    IceFinalFile = ROOT.TFile.Open(fileName)

                    nuWeights = []
                    nuPasses = []

                    allTree = IceFinalFile.allTree
                    allEvents = allTree.GetEntries()

                    TotalEvents[this_energy].append(allEvents)
                    

                except:
                    #print('error! skipping run')
                    continue
                success_runs.append(fileName)
                #If you don't load libraries (or if you can't), you can load events with, e.g. allTree.GetLeaf("eventSummary.neutrino.flavor").GetValue()
                
            elif fnmatch(name,passTreePattern):
                print(os.path.join(path,name))
                
                try: 
                    fileName = os.path.join(path,name)
                    IceFinalFile = ROOT.TFile.Open(fileName)
                    
                    this_energy=g.energy
                    
                    nuWeights = []
                    
                    #passTree = IceFinalFile.passTree
                    #passEvents = passTree.GetEntries()
                    skimTree = IceFinalFile.skimTree
                    passEvents = skimTree.GetEntries()
                except:
                    #print('error! skipping run')
                    continue
                
                for i in range(passEvents):
                    #passTree.GetEvent(i)
                    skimTree.GetEvent(i)
                    nuPasses.append(1)
                    #nuWeights.append(passTree.event.neutrino.path.weight/(passTree.event.loop.positionWeight*passTree.event.loop.directionWeight))
                    nuWeights.append(skimTree.neutrinoPathWeight/(skimTree.positionWeight*skimTree.directionWeight))
                    RawWeights[this_energy].append(nuWeights[-1])
                
                PassingEvents[this_energy].append(passEvents)
                PassingWeights[this_energy].append(np.sum(nuWeights))
                

    E_EV = np.sort(np.asarray(list(PassingEvents.keys())))

    E_EV = np.sort(np.asarray(list(PassingEvents.keys())))

    #cross_section_E = np.log10(np.asarray([1e4,2.5e4,6e4,1e5,2.5e5,6e5,1e6,2.5e6,6e6,1e7,2.5e7,6e7,1e8,2.5e8,6e8,1e9,2.5e9,6e9,1e10,2.5e10,6e10,1e11,2.5e11,6e11,1e12]))+9.0#eV
    #cross_sections = np.asarray([0.63e-34,0.12e-33,0.22e-33,0.3e-33,0.49e-33,0.77e-33,0.98e-33,0.15e-32,0.22e-32,0.27e-32,0.4e-32,0.56e-32,0.67e-32,0.94e-32,0.13e-31,0.15e-31,0.2e-31,0.27e-31,0.31e-31,0.41e-31,0.53e-31,0.61e-31,0.8e-31,0.1e-30,0.12e-30])#cm
    #interp_cross = np.interp(E_EV,cross_section_E,cross_sections) #cm^2
    
    IceVolume = 2.68592e7 #km^3
    #rho_factor=917.0/1000.00 #g/cm^3
    #m_n = 1.67e-24 #g

    #L_int = m_n/(rho_factor*interp_cross)/100 #m
    #interaction_lengths = L_int

    effective_V = []

    effective_V_p = []
    effective_V_m = []

    #all_weighted = []
    #all_passed = []
    #all_events = []
    #all_weights_squared = []

    #print('E_EV: ', E_EV)
    #print('PassingWeights: ', PassingWeights)
    #print('PassingEvents: ', PassingEvents)
    #print('TotalEvents: ', TotalEvents)

    for en in E_EV:

        total_weighted = np.sum(PassingWeights[en])
        #total_passed = np.sum(PassingEvents[en])
        total_events = np.sum(TotalEvents[en])

        #all_weighted.append(total_weighted)
        #all_passed.append(total_passed)
        #all_events.append(total_events)
        #all_weights_squared.append(np.sum(np.asarray(PassingWeights[en])**2))


        #print('at energy ', en, ', ', total_weighted,total_passed,'events passed out of ',total_events)
        #print('average rawWeights is : ',np.mean(RawWeights[en]))
        error_p, error_m = AddErrors(RawWeights[en])
        #print(total_weighted,events_error,total_weighted*frac_error_p,total_weighted*frac_error_m)

        effective_V.append(IceVolume*total_weighted/total_events*4*np.pi)
        #print("effective V is ", IceVolume*total_weighted/total_events*4*np.pi)
        #print("components were", IceVolume, total_weighted, total_events)
        effective_V_p.append(IceVolume*(error_p)/total_events*4*np.pi)
        effective_V_m.append(IceVolume*(error_m)/total_events*4*np.pi)
        #effective_A.append(effective_V[-1]/(L_int/100000))#factor of 100000 to convert from cm to km 

    #all_weighted = np.asarray(all_weighted)
    #all_passed = np.asarray(all_passed)
    #all_events = np.asarray(all_events)

    effective_V = np.asarray(effective_V)
    effective_V_p = np.asarray(effective_V_p)
    effective_V_m = np.asarray(effective_V_m)


    with open(g.opath+"/"+str(g.gen)+"_pueoOut.csv",'a') as f:
        f.write(str(g.indiv)+","+str(effective_V[0])+","+str(effective_V_p[0])+","+str(effective_V_m[0])+"\n")
        print("Writing to:", g.opath+"/"+str(g.gen)+"_pueoOut.csv" )

    with open(g.opath+"/"+str(g.gen)+"_fitnessScores.csv",'a') as f:
        f.write(str(effective_V[0])+"\n")
        print("Writing to:", g.opath+"/"+str(g.gen)+"_fitnessScores.csv")

    with open(g.opath+"/"+str(g.gen)+"_vEffectives.csv",'a') as f:
        f.write(str(effective_V[0])+"\n")
        print("Writing to:", g.opath+"/"+str(g.gen)+"_fitnessScores.csv")

    with open(g.opath+"/"+str(g.gen)+"_errorBars.csv",'a') as f:
        f.write(str(effective_V_p[0])+","+str(effective_V_m[0])+"\n")
        print("Writing to:", g.opath+"/"+str(g.gen)+"_errorBars.csv")





def AddErrors(all_weights):
    bin_num = 10
    max_weight = np.max(all_weights)
    min_weight = np.min(all_weights)

    bin_values = np.linspace(min_weight,max_weight,bin_num)

    bin_error_p = np.zeros(bin_num)
    bin_error_m = np.zeros(bin_num)
    test_error = np.zeros(bin_num)

    poissonerror_minus=[0.-0.00, 1.-0.37, 2.-0.74, 3.-1.10, 4.-2.34, 5.-2.75, 6.-3.82, 7.-4.25, 8.-5.30, 9.-6.33, 10.-6.78, 11.-7.81, 12.-8.83, 13.-9.28, 14.-10.30, 15.-11.32, 16.-12.33, 17.-12.79, 18.-13.81, 19.-14.82, 20.-15.83]
    poissonerror_plus=[1.29-0., 2.75-1., 4.25-2., 5.30-3., 6.78-4., 7.81-5., 9.28-6., 10.30-7., 11.32-8., 12.79-9., 13.81-10., 14.82-11., 16.29-12., 17.30-13., 18.32-14., 19.32-15., 20.80-16., 21.81-17., 22.82-18., 23.82-19., 25.30-20]
    counts, bins =np.histogram(all_weights,bins=bin_values)
    bin_centers = (bins[1:]+bins[:-1])/2.0
    bin_width = bins[1]-bins[0]
    for i, b in enumerate(bin_centers):
        if(counts[i]<20):
            this_pp = poissonerror_plus[counts[i]]
            this_pm = poissonerror_minus[counts[i]]
        else:
            this_pp = np.sqrt(counts[i])
            this_pm = np.sqrt(counts[i])
        #print('this pp pm is :',this_pp, this_pm)
        bin_error_p[i]=this_pp*b
        bin_error_m[i]=this_pm*b
        test_error[i]=this_pp*10**(-1*(i+0.5)/bin_num*(max_weight-min_weight)+min_weight)
    #print('bin error p is',np.sum(all_weights),test_error)
    total_error_p = np.sqrt(np.sum(bin_error_p**2))
    total_error_m = np.sqrt(np.sum(bin_error_m**2))
    #print("total error p, m :", total_error_p, total_error_m)
    total_test = np.sqrt(np.sum(test_error**2))
    #print('total error is ',total_error_p,total_error_m,total_test,np.sum(all_weights))
    #plt.hist(all_weights,bins=bin_values)
    #plt.show()
    return(total_error_p,total_error_m)

EffectiveVolume2('black','Update')
