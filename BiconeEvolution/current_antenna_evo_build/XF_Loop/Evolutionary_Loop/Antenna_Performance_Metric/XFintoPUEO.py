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

freqvals = [
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

numfreq = 131 # 1500 - 200 = 1300 / 10 = 130 steps    

# These are values to test with current nonPUEO files (These are the frequency values for ARA simulation software)
'''
freqvals = [
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
numfreq = 60
'''

freqlist = [f'{val}' for val in freqvals] # This is in the format that pueoSim wants
big_freq_list = freqlist * 6 # This is the same thing, just 6 times :) (this is to get the gain at different angles at each frequency, we have 6 angles)

# Adds arguments when running code
parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="How many antennas are being simulated each generation?", type=int)
parser.add_argument("WorkingDir", help="Evolutionary_Loop directory", type=Path)
parser.add_argument("RunName", help="Run Name directory where everything will be stored", type=str)
parser.add_argument("gen", help="The generation the loop is on", type=int)
parser.add_argument("indiv", help="The individual in the population", type=int)
parser.add_argument("XFCOUNT", help="The number of total XF jobs (NPOP or NPOP*2).", type=int)
g = parser.parse_args()

# Function to read in files
def readFile(indiv, freqnum, col):
    uanname = Path(f'{g.WorkingDir}/Run_Outputs/{g.RunName}/{g.gen}_{indiv}_{freqnum}.uan')
    #uanname = Path(f'{g.WorkingDir}/{g.RunName}/uan_files/{g.gen}_uan_files/{indiv}/{g.gen}_{indiv}_{freqnum}.uan')
    #pulling data from the uan file                                                                                         
    data = np.genfromtxt(uanname, unpack=True, skip_header=18)
    
    return (data[col]) #returns Gain(Theta) column THIS WILL NEED TO BE CHANGED FOR WHEN WE HAVE WORKING XF OUTPUTS (maybe make column input variable for function?)                                                                               

# Function for the pueoSim "0" files
def pueoFile0(indiv, type):
    true_indiv = int((indiv+1)/2) ## Brings us back to 1-NPOP instead of 1-NPOP*2
    if type == 'vv':
        filename = g.WorkingDir / 'Test_Outputs' / f'{type}_0_{g.gen}_{true_indiv}' # this will need to be changed to the correct output directory
        with open(filename, "w+") as pueo_v0:
            os.chmod(filename, 0o777)
            uanmaxg = []
            for freq in range(numfreq):
                uandatg = readFile(indiv, freq+1, 2) # gives gain column                                                           
                maxgain = uandatg[0] # gain at theta = 90                                                                        
                uanmaxg.append(maxgain)
            outputvv = np.column_stack((freqlist, uanmaxg))
            for p in range(numfreq):
                for q in range(2):
                    pueo_v0.write(str(outputvv[p][q])+" ")
                pueo_v0.write("\n")
            print(f'Done with vv_0 for Antenna {true_indiv}')
    elif type == 'hh': 
        filename = g.WorkingDir / 'Test_Outputs' / f'{type}_0_{g.gen}_{true_indiv}' # CHANGE THIS
        with open(filename, "w+") as pueo_h0:
            os.chmod(filename, 0o777)
            uanmaxg = []
            for freq in range(numfreq):
                uandatg = readFile(indiv + 1, freq+1, 3) # gives gain column
                maxgain = uandatg[0] # gain at theta = 90
                uanmaxg.append(maxgain)
            outputhh = np.column_stack((freqlist, uanmaxg))
            for p in range(numfreq):
                for q in range(2):
                    pueo_h0.write(str(outputhh[p][q])+" ")
                pueo_h0.write("\n")
            print(f'Done with hh_0 for Antenna {true_indiv}')
    elif type == 'vh':
        filename = g.WorkingDir / 'Test_Outputs' / f'{type}_0_{g.gen}_{true_indiv}' # CHANGE THIS
        with open(filename, "w+") as pueo_vh0:
            os.chmod(filename, 0o777)
            uanmaxg = []
            for freq in range(numfreq):
                uandatg = readFile(indiv, freq+1, 3) # gives gain column
                maxgain = uandatg[0] # gain at theta = 90
                uanmaxg.append(maxgain)
            outputvh = np.column_stack((freqlist, uanmaxg))
            for p in range(numfreq):
                for q in range(2):
                    pueo_vh0.write(str(outputvh[p][q])+" ")
                pueo_vh0.write("\n")
            print(f'Done with vh_0 for Antenna {true_indiv}')
    elif type == 'hv':
        filename = g.WorkingDir / 'Test_Outputs' / f'{type}_0_{g.gen}_{true_indiv}' # CHANGE THIS
        with open(filename, "w+") as pueo_hv0:
            os.chmod(filename, 0o777)
            uanmaxg = []
            for freq in range(numfreq):
                uandatg = readFile(indiv + 1, freq+1, 2) # gives gain column
                maxgain = uandatg[0] # gain at theta = 90
                uanmaxg.append(maxgain)
            outputhv = np.column_stack((freqlist, uanmaxg))
            for p in range(numfreq):
                for q in range(2):
                    pueo_hv0.write(str(outputhv[p][q])+" ")
                pueo_hv0.write("\n")
            print(f'Done with hv_0 for Antenna {true_indiv}')
    else:
        print('Error: Type not recognized')
        return
# For the pueoSim el and az files
def pueoElAz(indiv, type):
    true_indiv = int((indiv+1)/2) ## Brings us back to 1-NPOP instead of 1-NPOP*2
    if type == 'vv_el':
        filename = g.WorkingDir / 'Test_Outputs' / f'{type}_{g.gen}_{true_indiv}' # CHANGE THIS
        with open(filename, "w+") as pueo_vv_el:
            os.chmod(filename, 0o777)
            uananggain = []
            for freq in range(numfreq):
                temp_list = []
                uandatg = readFile(indiv, freq+1, 2) # gives gain column
                anggain = uandatg[73] # gain at theta = 5
                temp_list.append(anggain)
                anggain = uandatg[146] # gain at theta = 10
                temp_list.append(anggain)
                anggain = uandatg[292] # gain at theta = 20
                temp_list.append(anggain)
                anggain = uandatg[438] # gain at theta = 30
                temp_list.append(anggain)
                anggain = uandatg[657] # gain at theta = 45
                temp_list.append(anggain)
                anggain = uandatg[1314] # gain at theta = 90
                temp_list.append(anggain)
                uananggain.append(temp_list)
            new_list = np.transpose(uananggain).tolist()
            propergains = []
            for i in range(len(new_list)):
                for j in range(len(new_list[0])):
                    propergains.append(new_list[i][j])

            outputvv_el = np.column_stack((big_freq_list, propergains))
  #          outputvv_el = np.column_stack((big_freq_list, np.transpose(uananggain).tolist()))
            for p in range(numfreq*6):
                for q in range(2):
                    pueo_vv_el.write(str(outputvv_el[p][q])+" ")
                pueo_vv_el.write("\n")
            print(f'Done with vv_el for Antenna {true_indiv}')
    elif type == 'vv_az':
        filename = g.WorkingDir / 'Test_Outputs' / f'{type}_{g.gen}_{true_indiv}' # CHANGE THIS
        with open(filename, "w+") as pueo_vv_az:
            os.chmod(filename, 0o777)
            uananggain = []
            for freq in range(numfreq):
                temp_list = []
                uandatg = readFile(indiv, freq+1, 2) # gives gain column ()
                anggain = uandatg[1] # gain at phi = 5
                temp_list.append(anggain)
                anggain = uandatg[2] # gain at phi = 10
                temp_list.append(anggain)
                anggain = uandatg[4] # gain at phi = 20
                temp_list.append(anggain)
                anggain = uandatg[6] # gain at phi = 30
                temp_list.append(anggain)
                anggain = uandatg[9] # gain at phi = 45
                temp_list.append(anggain)
                anggain = uandatg[18] # gain at phi = 90
                temp_list.append(anggain)
                uananggain.append(temp_list)

            new_list = np.transpose(uananggain).tolist()
            propergains = []
            for i in range(len(new_list)):
                for j in range(len(new_list[0])):
                    propergains.append(new_list[i][j])

            outputvv_az = np.column_stack((big_freq_list, propergains))
 #          outputvv_az = np.column_stack((big_freq_list, np.transpose(uananggain).tolist()))
            for p in range(numfreq*6):
                for q in range(2):
                    pueo_vv_az.write(str(outputvv_az[p][q])+" ")
                pueo_vv_az.write("\n")
            print(f'Done with vv_az for Antenna {true_indiv}')
    elif type == 'hh_el':
        filename = g.WorkingDir / 'Test_Outputs' / f'{type}_{g.gen}_{true_indiv}' # CHANGE THIS
        with open(filename, "w+") as pueo_hh_el:
            os.chmod(filename, 0o777)
            uananggain = []
            for freq in range(numfreq):
                temp_list = []
                uandatg = readFile(indiv + 1, freq+1, 3) # gives gain column (MIGHT BE DIFFERENT)
                anggain = uandatg[73] # gain at theta = 5
                temp_list.append(anggain)
                anggain = uandatg[146] # gain at theta = 10
                temp_list.append(anggain)
                anggain = uandatg[292] # gain at theta = 20
                temp_list.append(anggain)
                anggain = uandatg[438] # gain at theta = 30
                temp_list.append(anggain)
                anggain = uandatg[657] # gain at theta = 45
                temp_list.append(anggain)
                anggain = uandatg[1314] # gain at theta = 90
                temp_list.append(anggain)
                uananggain.append(temp_list)
 
            new_list = np.transpose(uananggain).tolist()
            propergains = []
            for i in range(len(new_list)):
                for j in range(len(new_list[0])):
                    propergains.append(new_list[i][j])

            outputhh_el = np.column_stack((big_freq_list, propergains))
            #outputhh_el = np.column_stack((big_freq_list, np.transpose(uananggain).tolist()))
            for p in range(numfreq*6):
                for q in range(2):
                    pueo_hh_el.write(str(outputhh_el[p][q])+" ")
                pueo_hh_el.write("\n")
            print(f'Done with hh_el for Antenna {true_indiv}')
    elif type == 'hh_az':
        filename = g.WorkingDir / 'Test_Outputs' / f'{type}_{g.gen}_{true_indiv}' # CHANGE THIS
        with open(filename, "w+") as pueo_hh_az:
            os.chmod(filename, 0o777)
            uananggain = []
            for freq in range(numfreq):
                temp_list = []
                uandatg = readFile(indiv + 1, freq+1, 3) # gives gain column (MIGHT BE DIFFERENT) 
                anggain = uandatg[1] # gain at phi = 5
                temp_list.append(anggain)
                anggain = uandatg[2] # gain at phi = 10
                temp_list.append(anggain)
                anggain = uandatg[4] # gain at phi = 20
                temp_list.append(anggain)
                anggain = uandatg[6] # gain at phi = 30
                temp_list.append(anggain)
                anggain = uandatg[9] # gain at phi = 45
                temp_list.append(anggain)
                anggain = uandatg[18] # gain at phi = 90
                temp_list.append(anggain)
                uananggain.append(temp_list)

            new_list = np.transpose(uananggain).tolist()
            propergains = []
            for i in range(len(new_list)):
                for j in range(len(new_list[0])):
                    propergains.append(new_list[i][j])

            outputhh_az = np.column_stack((big_freq_list, propergains))
 #          outputhh_az = np.column_stack((big_freq_list, np.transpose(uananggain).tolist()))
            for p in range(numfreq*6):
                for q in range(2):
                    pueo_hh_az.write(str(outputhh_az[p][q])+" ")
                pueo_hh_az.write("\n")
            print(f'Done with hh_az for Antenna {true_indiv}')
    else: 
        print('Error: Invalid Type')
        return
### START ###
# For 0 files 
# Loop up to NPOP*2
# Each antenna has two simulations
# First one is vertical orientation, second i horizontal
# If antenna % 2 == 0, call vv, vh
# If antenna % 2 == 1, coll hh, hv
for antenna in range(g.NPOP*2):
    if(antenna % 2 == 0):
        pueoFile0(antenna+1,'vv') # vv_0
        pueoFile0(antenna+1,'vh') # vh_0
    else:
        pueoFile0(antenna,'hv') # hv_0
        pueoFile0(antenna,'hh') # hh_0

# Now to pull angles 5, 10, 20, 30, 45, 90 for el or az and respective theta or phi
# Angles and index locations. For theta. 5:[73], 10:[146], 20:[292], 30:[438], 45:[657], 90:[1314]
# For phi. 5:[1], 10:[2], 20:[4], 30:[6], 45:[9], 90:[18]

for antenna in range(g.NPOP*2):
    if(antenna % 2 == 0):
        pueoElAz(antenna+1,'vv_el') # vv_el
        pueoElAz(antenna+1,'vv_az') # vv_az
    else:
        pueoElAz(antenna,'hh_el') # hh_el
        pueoElAz(antenna,'hh_az') # hh_az

print("Done writing all new files! WOOOOOOOOOOOOOO") 
