# See `python XFintoPUEO.py --help` for more information
import os
import math
import argparse

from pathlib import Path

import numpy as np

### GLOBALS ###
## frequencies used in PUEOsim
freq_vals = [freq*10**6 for freq in range(200, 1501, 10)]
num_freq = 131  # 1500 - 200 = 1300 / 10 = 130 steps    

## frequencies used in AraSim
'''
freq_vals = [(83.33 + 16.67*freq)*10**6 for freq in range (0, 60, 1)]
num_freq = 60
'''
freq_list = [str(val) for val in freq_vals]  # pueoSim wants the freqs as strings

## Adds arguments when running code
parser = argparse.ArgumentParser(prog = 'XFintoPUEO_Symmetric.py', description = 'Reads theta and phi gains from uan files created by XFdtd to create files for PUEOsim to read in.')
parser.add_argument("npop", help="Number of individuals per generation.", type=int)
parser.add_argument("working_dir", help="Base working directory; usually /path/to/Evolutionary_Loop.", type=Path)
parser.add_argument("run_name", help="Name of current run; directory in /path/to/Run_Outputs where data is stored.", type=str)
parser.add_argument("gen", help="The generation the loop is on.", type=int)
g = parser.parse_args()


## Function Definitions
## Function to read in files
def read_file(indiv, freq_num, col):
    uanname = g.working_dir / 'Run_Outputs' / g.run_name / '{g.gen}_{indiv}_{freqNum}.uan'
    data = np.genfromtxt(uanname, unpack=True, skip_header=18).tolist()

    return data[col]  # Return the gain for the polarization being read
 
## Make a function to create a list for each of the columns (V and H gains)
## This function reads in the gain at each phi for the desired thetas
def getGains(indiv):
    vpol_gains = []
    hpol_gains = []

    for freq in range(num_freq):
        vpol_gains.append(read_file(indiv, freq+1, 2))
        hpol_gains.append(read_file(indiv, freq+1, 3))

    return vpol_gains, hpol_gains

## This function writes the data to a file
def writeGains(data, freq_list, file_name):
    with open(file_name, "a") as f:
        for i in range(num_freq):
            f.write('{freq_list[i]} {data[i]}\n')


## Function calls
## Here's the path to output to
file_header = g.working_dir / 'Test_Outputs' 
## Loop over the number of individuals
for indiv in range(1, g.npop+1):
        ## Let's call the functions
        ## Start by getting the gain data
        vpol_data, hpol_data = getGains(indiv)
        vpol_data_t = np.transpose(vpol_data).tolist()
        hpol_data_t = np.transpose(hpol_data).tolist()

        ## We're treating vv and hh as the same and vh and hv as the same
        ## So for the _0 files, it's pretty simple:
        writeGains(vpol_data_t[0], freq_list, file_header / f'vv_0_{g.gen}_{indiv}')
        writeGains(vpol_data_t[0], freq_list, file_header / f'hh_0_{g.gen}_{indiv}')
        writeGains(hpol_data_t[0], freq_list, file_header / f'vh_0_{g.gen}_{indiv}')
        writeGains(hpol_data_t[0], freq_list, file_header / f'hv_0_{g.gen}_{indiv}')
        ## Now we need to be more careful for the az and el files
        ## We want the angles 5, 10, 20, 30, 45, 90
        ## For the azimuth, this is just counting through the phi at 0 theta
        ## We just pick out the 2nd, 3rd, 5th, 7th, 10th, and 19th sublists
        ## So we call the writeGains function for each of those lists
        v_az_file = file_header / f'vv_az_{g.gen}_{indiv}'
        h_az_file = file_header / f'hh_az_{g.gen}_{indiv}'
        v_el_file = file_header / f'vv_el_{g.gen}_{indiv}'
        h_el_file = file_header / f'hh_el_{g.gen}_{indiv}'
        indices = [1, 2, 4, 6, 9, 18]
        for i in indices:
            writeGains(vpol_data_t[i], freq_list, v_az_file)
            writeGains(hpol_data_t[i], freq_list, h_az_file)
        ## For the elevation, we need to count through theta at 0 phi
        ## These are trickier, because theta increments only after all of the phi increments
        ## So if 0,0 (theta, phi) is in the 0th row, and 0,360 is in the 72nd row
        ## then 5,0 is in the 73rd row, and we increment by adding 73 for each theta step
        indices = [73, 146, 292, 438, 657, 1314]
        for i in indices:
            writeGains(vpol_data_t[i], freq_list, v_el_file)
            writeGains(vpol_data_t[i], freq_list, h_el_file)

