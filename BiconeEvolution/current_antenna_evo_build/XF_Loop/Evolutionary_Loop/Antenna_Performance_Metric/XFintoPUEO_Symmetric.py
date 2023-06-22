### Description: This code is written to reformat the outputs of XF to be acceptable into PUEOsim. XF outputs one file, this code parses through that file and creates 6 new files. For information on inputs for PUEOsim check out this ELOG post: radiorm.physics.ohio-state.edu/elog/GENETIS/195 

# See `python XFintoPUEO.py --help` for more information
import os
import math
import argparse

from pathlib import Path

import numpy as np

### GLOBALS ###
# These are the actual values needed for PUEO [DOUBLE CHECK BEFORE FULLY IMPLEMENTING] Its 200MHz incremented by 10MHz to 1500 MHz as found in pueoSim 

freqVals = [freq*10**6 for freq in range(200, 1501, 10)]

numFreq = 131  # 1500 - 200 = 1300 / 10 = 130 steps    

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

freqList = [str(val) for val in freqVals]  # pueoSim wants the freqs as strings
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
def read_file(indiv, freq_num, col):
    uanname = g.WorkingDir / 'Run_Outputs' / g.RunName / '{g.gen}_{indiv}_{freqNum}.uan'
    #uanname = Path(f'{g.WorkingDir}/{g.RunName}/uan_files/{g.gen}_uan_files/{indiv}/{g.gen}_{indiv}_{freqNum}.uan')
    #pulling data from the uan file                                                                                         
    data = np.genfromtxt(uanname, unpack=True, skip_header=18).tolist()

    return data[col]  # returns Gain(Theta) column THIS WILL NEED TO BE CHANGED FOR WHEN WE HAVE WORKING XF OUTPUTS (maybe make column input variable for function?)                                                                               
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
			f.write('{freqList[i]} {data[i]}\n')
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

