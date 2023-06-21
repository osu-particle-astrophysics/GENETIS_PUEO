### File Name: XFintoPUEO.py
### Created by: Jacob Weiler
### Creation Date: 10/29/2022
### Last Modified: 4/11/2023 
### Description: This code is written to reformat the outputs of XF to be acceptable into PUEOsim. XF outputs one file, this code parses through that file and creates 6 new files. For information on inputs for PUEOsim check out this ELOG post: radiorm.physics.ohio-state.edu/elog/GENETIS/195 

# General: TO RUN python XFintoPUEO.py (NPOP) (source) (Run Name) (generation) (starting individual)
# Jacob Test: TO RUN python XFintoPUEO.py 2 . 2022_07_16_Test 0 1

### THINGS TO DO: 
### 1. Change file locations for both the inputs and outputs for this script
### 2. Go through and change the columns and indices pulled from uan file to something that works with horn antenna XF output
### 3. Double check to make sure outputs are correctly pulling the right gains and into the vertical and horizontal files

import numpy as np
import argparse
import os
import math
from pathlib import Path

### GLOBALS ###
# These are the actual values needed for PUEO [DOUBLE CHECK BEFORE FULLY IMPLEMENTING] Its 200MHz incremented by 10MHz to 1500 MHz as found in pueoSim 

freqVals = [
    200.0e6, 210.0e6, 220.0e6, 230.0e6, 240.0e6, 250.0e6, 260.0e6, 270.0e6,
    280.0e6, 290.0e6, 300.0e6, 310.0e6, 320.0e6, 330.0e6, 340.0e6, 350.0e6,
    360.0e6, 370.0e6, 380.0e6, 390.0e6, 400.0e6, 410.0e6, 420.0e6, 430.0e6,
    440.0e6, 450.0e6, 460.0e6, 470.0e6, 480.0e6, 490.0e6, 500.0e6, 510.0e6,
    520.0e6, 530.0e6, 540.0e6, 550.0e6, 560.0e6, 570.0e6, 580.0e6, 590.0e6,
    600.0e6, 610.0e6, 620.0e6, 630.0e6, 640.0e6, 650.0e6, 660.0e6, 670.0e6, 
    680.0e6, 690.0e6, 700.0e6, 710.0e6, 720.0e6, 730.0e6, 740.0e6, 750.0e6, 
    760.0e6, 770.0e6, 780.0e6, 790.0e6, 800.0e6, 810.0e6, 820.0e6, 830.0e6, 
    840.0e6, 850.0e6, 860.0e6, 870.0e6, 880.0e6, 890.0e6, 900.0e6, 910.0e6, 
    920.0e6, 930.0e6, 940.0e6, 950.0e6, 960.0e6, 970.0e6, 980.0e6, 990.0e6, 
    1000.0e6, 1010.0e6, 1020.0e6, 1030.0e6, 1040.0e6, 1050.0e6, 1060.0e6,
    1070.0e6, 1080.0e6, 1090.0e6, 1100.0e6, 1110.0e6, 1120.0e6, 1130.0e6, 
    1140.0e6, 1150.0e6, 1160.0e6, 1170.0e6, 1180.0e6, 1190.0e6, 1200.0e6, 
    1210.0e6, 1220.0e6, 1230.0e6, 1240.0e6, 1250.0e6, 1260.0e6, 1270.0e6, 
    1280.0e6, 1290.0e6, 1300.0e6, 1310.0e6, 1320.0e6, 1330.0e6, 1340.0e6, 
    1350.0e6, 1360.0e6, 1370.0e6, 1380.0e6, 1390.0e6, 1400.0e6, 1410.0e6, 
    1420.0e6, 1430.0e6, 1440.0e6, 1450.0e6, 1460.0e6, 1470.0e6, 1480.0e6, 
    1490.0e6, 1500.0e6
    ]

numFreq = 131 # 1500 - 200 = 1300 / 10 = 130 steps    

# These are values to test with current nonPUEO files (These are the frequency values for ARA simulation software)
'''
freqVals = [
    83.33e6, 100.00e6, 116.67e6, 133.33e6, 150.00e6, 166.67e6, 183.34e6,
    200.00e6, 216.67e6, 233.34e6, 250.00e6, 266.67e6, 283.34e6, 300.00e6, 
    316.67e6, 333.34e6, 350.00e6, 366.67e6, 383.34e6, 400.01e6, 416.67e6,
    433.34e6, 450.01e6, 466.67e6, 483.34e6, 500.01e6, 516.68e6, 533.34e6,
    550.01e6, 566.68e6, 583.34e6, 600.01e6, 616.68e6, 633.34e6, 650.01e6,
    666.68e6, 683.35e6, 700.01e6, 716.68e6, 733.35e6, 750.01e6, 766.68e6,
    783.35e6, 800.01e6, 816.68e6, 833.35e6, 850.02e6, 866.68e6,883.35e6,
    900.02e6, 916.68e6, 933.35e6, 950.02e6, 966.68e6, 983.35e6, 1000.00e6,
    1016.70e6, 1033.40e6, 1050.00e6, 1066.70e6
    ]
numFreq = 60
'''

freqList = [f'{val}' for val in freqVals] # This is in the format that pueoSim wants
big_freq_list = freqList * 6 # This is the same thing, just 6 times :) (this is to get the gain at different angles at each frequency, we have 6 angles)

# Adds arguments when running code
parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="How many antennas are being simulated each generation?", type=int)
parser.add_argument("WorkingDir", help="Evolutionary_Loop directory", type=Path)
parser.add_argument("RunName", help="Run Name directory where everything will be stored", type=str)
parser.add_argument("gen", help="The generation the loop is on", type=int)
parser.add_argument("indiv", help="The individual in the population", type=int)
g = parser.parse_args()

# Function to read in files
def readFile(indiv, freqNum, col):
    uanname = Path(f'{g.WorkingDir}/Run_Outputs/{g.RunName}/{g.gen}_{indiv}_{freqNum}.uan')
    #uanname = Path(f'{g.WorkingDir}/{g.RunName}/uan_files/{g.gen}_uan_files/{indiv}/{g.gen}_{indiv}_{freqNum}.uan')
    #pulling data from the uan file                                                                                         
    data = np.genfromtxt(uanname, unpack=True, skip_header=18).tolist()

    return (data[col]) #returns Gain(Theta) column THIS WILL NEED TO BE CHANGED FOR WHEN WE HAVE WORKING XF OUTPUTS (maybe make column input variable for function?)                                                                               
## Make a function to create a list for each of the columns (V and H gains)
## This function reads in the gain at each phi for the desired thetas
def getGains(indiv):
	vpolGains = []
	hpolGains = []

	for freq in range(numFreq):
		vpolGains.append(readFile(indiv, freq+1, 2))
		hpolGains.append(readFile(indiv, freq+1, 3))

	return vpolGains, hpolGains

## This function writes the data to a file
def writeGains(data, freqList, fileName):
	with open(fileName, "a") as f:
		for i in range(numFreq):
			f.write(str(freqList[i]) + " " + str(data[i]) + "\n")
	return 0


## Here's the path to output to
fileHeader = g.WorkingDir / 'Test_Outputs' 
## Loop over the number of individuals
for indiv in range(1, g.NPOP+1):
		## Let's call the functions
		## Start by getting the gain data
		vpolData, hpolData = getGains(indiv)
		## We're treating vv and hh as the same and vh and hv as the same
		## So for the _0 files, it's pretty simple:
		writeGains(np.transpose(vpolData).tolist()[0], freqList, fileHeader / f'vv_0_{g.gen}_{indiv}')
		writeGains(np.transpose(vpolData).tolist()[0], freqList, fileHeader / f'hh_0_{g.gen}_{indiv}')
		writeGains(np.transpose(hpolData).tolist()[0], freqList, fileHeader / f'vh_0_{g.gen}_{indiv}')
		writeGains(np.transpose(hpolData).tolist()[0], freqList, fileHeader / f'hv_0_{g.gen}_{indiv}')
		## Now we need to be more careful for the az and el files
		## We want the angles 5, 10, 20, 30, 45, 90
		## For the azimuth, this is just counting through the phi at 0 theta
		## We just pick out the 2nd, 3rd, 5th, 7th, 10th, and 19th sublists
		## So we call the writeGains function for each of those lists
		indices = [1, 2, 4, 6, 9, 18]
		for i in indices:
			writeGains(np.transpose(vpolData).tolist()[i], freqList, fileHeader / f'vv_az_{g.gen}_{indiv}')
			writeGains(np.transpose(hpolData).tolist()[i], freqList, fileHeader / f'hh_az_{g.gen}_{indiv}')
		## For the elevation, we need to count through theta at 0 phi
		## These are trickier, because theta increments only after all of the phi increments
		## So if 0,0 (theta, phi) is in the 0th row, and 0,360 is in the 72nd row
		## then 5,0 is in the 73rd row, and we increment by adding 73 for each theta step
		indices = [73, 146, 292, 438, 657, 1314]
		for i in indices:
			writeGains(np.transpose(vpolData).tolist()[i], freqList, fileHeader / f'vv_el_{g.gen}_{indiv}')
			writeGains(np.transpose(hpolData).tolist()[i], freqList, fileHeader / f'hh_el_{g.gen}_{indiv}')

