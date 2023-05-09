#!/usr/bin/env python
#This file came from Will with some GENETIS specific modifications by Dylan
import ROOT
import numpy as np
#import matplotlib.pyplot as plt
#import scipy.signal
from collections import defaultdict
import os
from fnmatch import fnmatch
#import matplotlib
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("gen", help="current gen", type=int)
parser.add_argument("indiv", help="Individual", type=int)
parser.add_argument("energy", help="Individual", type=int)
parser.add_argument("opath", help="Output path", type=str)
parser.add_argument("RunName", help="Run Name", type=str)
g=parser.parse_args()

ROOT.gSystem.Load("/fs/ess/buildingPueoSim/pueoBuilder/lib/libNiceMC.so")
ROOT.gSystem.Load("/fs/ess/buildingPueoSim/pueoBuilder/lib/libAntarcticaRoot.so")
ROOT.gSystem.Load("/fs/ess/buildingPueoSim/pueoBuilder/lib/libAnitaEvent.so")
ROOT.gSystem.Load("/fs/ess/buildingPueoSim/pueoBuilder/lib/libPueoSim.so")
ROOT.gInterpreter.Declare('#include "Geoid.h"')

def EffectiveVolume2(thisColor,thisLabel):

	#Previous script uses this structure, we don't:
	#Directory structure:
	#localoutput2/energyXX/runYY
	#XX=17.5,18,18.5,etc
	#YY= whatever you want 
	#It will automatically group together multiple runs at the same energy.


	root = '/fs/ess/PAS1960/HornEvolutionOSC/GENETIS_PUEO/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/'+g.RunName
	pattern = "IceFinal_" + str(g.gen) + "_" + str(g.indiv) + "*"



	PassingEvents = defaultdict(list)
	PassingWeights = defaultdict(list)
	TotalEvents = defaultdict(list)
	RawWeights = defaultdict(list)


	success_runs = []


	nu_e = {17.5:0,18:0,18.5:0,19:0,19.5:0,20:0,20.5:0,21:0}
	nu_m = {17.5:0,18:0,18.5:0,19:0,19.5:0,20:0,20.5:0,21:0}
	nu_t = {17.5:0,18:0,18.5:0,19:0,19.5:0,20:0,20.5:0,21:0}
	for path, subdirs, files in os.walk(root):
		for name in files:
			if fnmatch(name,pattern):
				#print(os.path.join(path,name))
				#Original script loops through the energies, when we just simulate one 
				'''
				fullName = os.path.join(path,name)
				#try:

				if(os.path.join(path,name)[fullName.find('energy')+9]=='5'):
					print(os.path.join(path,name)[fullName.find('energy')+6:fullName.find('energy')+8])
					print(type(os.path.join(path,name)[fullName.find('energy')+6:fullName.find('energy')+8]))
					this_energy = float(os.path.join(path,name)[fullName.find('energy')+6:fullName.find('energy')+8])+0.5
					#print(fullName,os.path.join(path,name)[fullName.find('energy')+9])
				else:
					print("else", fullName, fullName.find('energy')+6, fullName.find('energy')+8, fullName[0:9])
					print(os.path.join(path,name)[fullName.find('energy')+6:fullName.find('energy')+8])
					print(type(os.path.join(path,name)[fullName.find('energy')+6:fullName.find('energy')+8]))
					this_energy = float(os.path.join(path,name)[fullName.find('energy')+6:fullName.find('energy')+8])
				print(this_energy)
				'''
				this_energy=g.energy
				#if(this_energy==18):
				#	continue
				try:
					fileName = os.path.join(path,name)
					IceFinalFile = ROOT.TFile.Open(fileName)

					nuWeights = []
					nuPasses = []



					allTree = IceFinalFile.allTree
					allEvents = allTree.GetEntries()

					TotalEvents[this_energy].append(allEvents)
					passTree = IceFinalFile.passTree
					passEvents = passTree.GetEntries()
				except:
					#print('error! skipping run')
					continue
				success_runs.append(fileName)
				#If you don't load libraries (or if you can't), you can load events with, e.g. allTree.GetLeaf("eventSummary.neutrino.flavor").GetValue()

				for i in range(0,passEvents):
					passTree.GetEvent(i)
					allTree.GetEvent(i)
					#nuPasses.append(allTree.eventSummary.loop.passesTrigger.result)
					if(passTree.event.neutrino.flavor==1):
						nu_e[this_energy]=nu_e[this_energy]+1
					elif(passTree.event.neutrino.flavor==2):
						nu_m[this_energy]=nu_m[this_energy]+1
					else:
						nu_t[this_energy]=nu_t[this_energy]+1
					nuPasses.append(1)
					nuWeights.append(passTree.event.neutrino.path.weight/(passTree.event.loop.positionWeight*passTree.event.loop.directionWeight))
					#print("weights", passTree.event.neutrino.path.weight, passTree.event.loop.positionWeight, passTree.event.loop.directionWeight)
					RawWeights[this_energy].append(nuWeights[-1])

				PassingEvents[this_energy].append(np.sum(nuPasses))
				PassingWeights[this_energy].append(np.sum(nuWeights))



	E_EV = np.sort(np.asarray(list(PassingEvents.keys())))


	#fig, ax = plt.subplots(num=0)

	E_EV = np.sort(np.asarray(list(PassingEvents.keys())))

	#ax.set_ylabel('Flavor Ratio')
	#ax.set_xlabel('log(Energy [eV])')
	#ax.legend()

	#E_EV = np.asarray([17.5,18.0,18.5,19.0,19.5,20.0,20.5,21.0])
	cross_section_E = np.log10(np.asarray([1e4,2.5e4,6e4,1e5,2.5e5,6e5,1e6,2.5e6,6e6,1e7,2.5e7,6e7,1e8,2.5e8,6e8,1e9,2.5e9,6e9,1e10,2.5e10,6e10,1e11,2.5e11,6e11,1e12]))+9.0#eV
	cross_sections = np.asarray([0.63e-34,0.12e-33,0.22e-33,0.3e-33,0.49e-33,0.77e-33,0.98e-33,0.15e-32,0.22e-32,0.27e-32,0.4e-32,0.56e-32,0.67e-32,0.94e-32,0.13e-31,0.15e-31,0.2e-31,0.27e-31,0.31e-31,0.41e-31,0.53e-31,0.61e-31,0.8e-31,0.1e-30,0.12e-30])#cm
	interp_cross = np.interp(E_EV,cross_section_E,cross_sections)#cm^2
	
	IceVolume = 2.68592e7 #km^3
	rho_factor=917.0/1000.00 #g/cm^3
	m_n = 1.67e-24 #g

	L_int = m_n/(rho_factor*interp_cross)/100 #m
	interaction_lengths = L_int
	#energies = [18,19,20,21]
	effective_V = []

	effective_V_p = []
	effective_V_m = []

	all_weighted = []
	all_passed = []
	all_events = []
	all_weights_squared = []

	#print('E_EV: ', E_EV)
	#print('PassingWeights: ', PassingWeights)
	#print('PassingEvents: ', PassingEvents)
	#print('TotalEvents: ', TotalEvents)
	for en in E_EV:
		#if(en==17.5):
		#	continue
		total_weighted = np.sum(PassingWeights[en])
		total_passed = np.sum(PassingEvents[en])
		total_events = np.sum(TotalEvents[en])

		all_weighted.append(total_weighted)
		all_passed.append(total_passed)
		all_events.append(total_events)
		all_weights_squared.append(np.sum(np.asarray(PassingWeights[en])**2))


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

	all_weighted = np.asarray(all_weighted)
	all_passed = np.asarray(all_passed)
	all_events = np.asarray(all_events)

	effective_V = np.asarray(effective_V)
	effective_V_p = np.asarray(effective_V_p)
	effective_V_m = np.asarray(effective_V_m)

	#print("Effective, p, m :", effective_V, effective_V_p, effective_V_m)
	#print('scaled?: ', effective_V_m/interaction_lengths*1e3)
	#Scaling down the errors by the interaction lengths
	scaledP = effective_V_p/interaction_lengths*1e3
	scaledM = effective_V_m/interaction_lengths*1e3
	#print('scaledP: ', scaledP, scaledP[0])
	#print('scaledM: ', scaledM, scaledM[0])

	with open(g.opath+str(g.gen)+"_pueoOut.csv",'a') as f:
		f.write(str(g.indiv)+","+str(effective_V[0])+","+str(scaledP[0])+","+str(scaledM[0])+"\n")

	with open(g.opath+str(g.gen)+"_fitnessScores.csv",'a') as f:
		f.write(str(effective_V[0])+"\n")

	with open(g.opath+str(g.gen)+"_errorBars.csv",'a') as f:
		f.write(str(scaledP[0])+","+str(scaledM[0])+"\n")

	'''
	effective_A=(effective_V/(L_int/100000))#factor of 100000 to convert from cm to km 
	#print(effective_A)
	plt.figure(1)
	plt.plot(E_EV,effective_V,'o-',color='black')
	plt.grid()
	plt.xlabel('Log( Energy [eV] )')
	plt.ylabel('Effective Volume [$km^3 sr$]')
	plt.yscale('log')
	plt.savefig('effectiveV.pdf')

	#interaction_lengths=L_int/1e-3

	#print((effective_V-effective_V_m)/interaction_lengths*1e3,(effective_V_p-effective_V)/interaction_lengths*1e3)
	plt.figure(2)
	#plt.plot(E_EV,effective_V/interaction_lengths*1e3,'o',color='black',label='PUEOSim $A_{eff}$')
	#plt.plot(energies,effective_A,color='dodgerblue')
	plt.ylabel('Effective Area [$km^2 sr$]')
	plt.xlabel('Log( Energy [eV] )')
	#expected_Aeff = np.loadtxt('diffuse_Askaryan.txt')
	#plt.plot(np.log10(expected_Aeff[:,0]),expected_Aeff[:,1],color='dodgerblue',label="Scaled $A_{eff}$")
	plt.errorbar(E_EV,effective_V/interaction_lengths*1e3,yerr=[effective_V_m/interaction_lengths*1e3,effective_V_p/interaction_lengths*1e3],color='black',label='PUEOSim $A_{eff}$')
	
	np.savez('effectiveArea.npz', E_EV, effective_V/interaction_lengths*1e3, [effective_V_m/interaction_lengths*1e3,effective_V_p/interaction_lengths*1e3])

	plt.yscale('log')
	plt.grid()
	plt.legend()
	plt.xlim(17.5, 21.0)
	plt.ylim(1e-5, 1e3)
	plt.savefig('effectiveA'+thisLabel+'.pdf')
	#plt.close()

	#plt.show()
	plt.figure(3)
	plt.plot(E_EV,effective_V/interaction_lengths*1e3,'o-',color=thisColor,label=thisLabel)
	#print("effective As", effective_V/interaction_lengths*1e3)
	#plt.errorbar(energies,effective_V/interaction_lengths*1e3,yerr=[(effective_V-effective_V_m)/interaction_lengths*1e3,(effective_V_p-effective_V)/interaction_lengths*1e3],color=thisColor,label=thisLabel)

	np.save('effectiveA_'+str(thisLabel)+'.npy',effective_V/interaction_lengths*1e3)
	np.save('numPass_'+str(thisLabel)+'.npy',all_passed)
	np.save('numWeight_'+str(thisLabel)+'.npy',all_weighted)
	np.save('totalEvents_'+str(thisLabel)+'.npy',all_events)
	np.save('squaredWeights_'+str(thisLabel)+'.npy',all_weights_squared)
	'''

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
		bin_error_p[i]=this_pp*b#*bin_width
		bin_error_m[i]=this_pm*b#*bin_widthfullName.find('energy')+6:fullName.find('energy')+8
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