#TESTING HOW TO MANIPULATE ARRAYS

#TO RUN python arraymanTEST.py 2 . 2022_07_16_Test 0 1


import numpy as np
import argparse
import os
import math

#freqVals = [200.0*10**(+6), 210.0*10**(+6), 220.0*10**(+6), 230.0*10**(+6), 240.0*10**(+6), 250.0*10**(+6), 260.0*10**(+6), 270.0*10**(+6), 280.0*10**(+6), 290.0*10**(+6), 300.0*10**(+6), 310.0*10**(+6), 320.0*10**(+6), 330.0*10**(+6), 340.0*10**(+6), 350.0*10**(+6),360.0*10**(+6), 370.0*10**(+6), 380.0*10**(+6), 390.0*10**(+6), 400.0*10**(+6), 410.0*10**(+6), 420.0*10**(+6), 430.0*10**(+6), 440.0*10**(+6), 450.0*10**(+6), 460.0*10**(+6), 470.0*10**(+6), 480.0*10**(+6), 490.0*10**(+6), 500.0*10**(+6), 510.0*10**(+6), 520.0*10**(+6), 530.0*10**(+6), 540.0*10**(+6), 550.0*10**(+6), 560.0*10**(+6), 570.0*10**(+6), 580.0*10**(+6), 590.0*10**(+6), 600.0*10**(+6), 610.0*10**(+6), 620.0*10**(+6), 630.0*10**(+6), 640.0*10**(+6), 650.0*10**(+6), 660.0*10**(+6), 670.0*10**(+6), 680.0*10**(+6), 690.0*10**(+6), 700.0*10**(+6), 710.0*10**(+6), 720.0*10**(+6), 730.0*10**(+6), 740.0*10**(+6), 750.0*10**(+6), 760.0*10**(+6), 770.0*10**(+6), 780.0*10**(+6), 790.0*10**(+6), 800.0*10**(+6), 810.0*10**(+6), 820.0*10**(+6), 830.0*10**(+6), 840.0*10**(+6), 850.0*10**(+6), 860.0*10**(+6), 870.0*10**(+6), 880.0*10**(+6), 890.0*10**(+6), 900.0*10**(+6), 910.0*10**(+6), 920.0*10**(+6), 930.0*10**(+6), 940.0*10**(+6), 950.0*10**(+6), 960.0*10**(+6), 970.0*10**(+6), 980.0*10**(+6), 990.0*10**(+6), 1000.0*10**(+6), 1010.0*10**(+6), 1020.0*10**(+6), 1030.0*10**(+6), 1040.0*10**(+6), 1050.0*10**(+6), 1060.0*10**(+6), 1070.0*10**(+6), 1080.0*10**(+6), 1090.0*10**(+6), 1100.0*10**(+6), 1110.0*10**(+6), 1120.0*10**(+6), 1130.0*10**(+6), 1140.0*10**(+6), 1150.0*10**(+6), 1160.0*10**(+6), 1170.0*10**(+6), 1180.0*10**(+6), 1190.0*10**(+6), 1200.0*10**(+6), 1210.0*10**(+6), 1220.0*10**(+6), 1230.0*10**(+6), 1240.0*10**(+6), 1250.0*10**(+6), 1260.0*10**(+6), 1270.0*10**(+6), 1280.0*10**(+6), 1290.0*10**(+6), 1300.0*10**(+6), 1310.0*10**(+6), 1320.0*10**(+6), 1330.0*10**(+6), 1340.0*10**(+6), 1350.0*10**(+6), 1360.0*10**(+6), 1370.0*10**(+6), 1380.0*10**(+6), 1390.0*10**(+6), 1400.0*10**(+6), 1410.0*10**(+6), 1420.0*10**(+6), 1430.0*10**(+6), 1440.0*10**(+6), 1450.0*10**(+6), 1460.0*10**(+6), 1470.0*10**(+6), 1480.0*10**(+6), 1490.0*10**(+6), 1500.0*10**(+6) ]

#numFreq = 130 # 1500 - 200 = 1300 / 10 = 130 steps    

freqVals = [83.33*10**(+6), 100.00*10**(+6), 116.67*10**(+6), 133.33*10**(+6), 150.00*10**(+6), 166.67*10**(+6), 183.34*10**(+6), 200.00*10**(+6), 216.67*10**(+6), 233.34*10**(+6), 250.00*10**(+6), 266.67*10**(+6), 283.34*10**(+6), 300.00*10**(+6), 316.67*10**(+6), 333.34*10**(+6), 350.00*10**(+6), 366.67*10**(+6), 383.34*10**(+6), 400.01*10**(+6), 416.67*10**(+6), 433.34*10**(+6), 450.01*10**(+6), 466.67*10**(+6), 483.34*10**(+6), 500.01*10**(+6), 516.68*10**(+6), 533.34*10**(+6), 550.01*10**(+6), 566.68*10**(+6), 583.34*10**(+6), 600.01*10**(+6), 616.68*10**(+6), 633.34*10**(+6), 650.01*10**(+6), 666.68*10**(+6), 683.35*10**(+6), 700.01*10**(+6), 716.68*10**(+6), 733.35*10**(+6), 750.01*10**(+6), 766.68*10**(+6), 783.35*10**(+6), 800.01*10**(+6), 816.68*10**(+6), 833.35*10**(+6), 850.02*10**(+6), 866.68*10**(+6),883.35*10**(+6), 900.02*10**(+6), 916.68*10**(+6), 933.35*10**(+6), 950.02*10**(+6), 966.68*10**(+6), 983.35*10**(+6), 1000.00*10**(+6), 1016.70*10**(+6), 1033.40*10**(+6), 1050.00*10**(+6), 1066.70*10**(+6)]

numFreq = 60

parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="How many antennas are being simulated each generation?", type=int)
parser.add_argument("WorkingDir", help="Evolutionary_Loop directory", type=str)
parser.add_argument("RunName", help="Run Name directory where everything will be stored", type=str)
parser.add_argument("gen", help="The generation the loop is on", type=int)
parser.add_argument("indiv", help="The individual in the population", type=int)
g = parser.parse_args()


uanLoc = '/users/PAS1977/jacobweiler/GENETIS/'

def readFile(indiv, freqNum):
    uanName = f'{g.WorkingDir}/{g.RunName}/uan_files/{g.gen}_uan_files/{indiv}/{g.gen}_{indiv}_{freqNum}.uan'
    #pulling data from the uan file                                                                                         
    Data = np.genfromtxt(uanName, unpack=True, skip_header = 17)
    return (Data[2]) #returns Gain(Theta) column                                                                               

# Testing for Max
### START ###

n = 37
m = 73

freqArray = []
# Formatting Frequency values into Scientific Notation  
for q in range(numFreq):
    scinoteval = "{:.2e}".format(freqVals[q])
    freqArray.append(scinoteval)

# For vv_0
for antenna in range(g.NPOP):
    with open(f'{g.WorkingDir}/Test_Outputs/'+"vv_0_"+{g.gen}+" "+str(antenna+1), "w+") as PUEO_v0:
        os.chmod(f'{g.WorkingDir}/Test_Outputs/'+"vv_0_"+{g.gen}+" "+str(antenna+1), 0o777)
        
        uanMaxG = []
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) #Gives Gain Column                                                           
            MaxGain = uanDatG[1314] #Gain at theta = 90                                                                        
            uanMaxG.append(MaxGain)
        
        OutputVV = np.column_stack((freqArray, uanMaxG))
        for p in range(numFreq):
            for q in range(2):
                PUEO_v0.write(str(OutputVV[p][q])+" ")
            PUEO_v0.write("\n")
        print("Done with vv_0 for Antenna " +str(antenna+1))

# For hh_0
for antenna in range(g.NPOP):
    with open(f'{g.WorkingDir}/Test_Outputs/'+"hh_0_"+{g.gen}+" "+str(antenna+1), "w+") as PUEO_h0:
        os.chmod(f'{g.WorkingDir}/Test_Outputs/'+"hh_0_"+{g.gen}+" "+str(antenna+1), 0o777)

        uanMaxG = []
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) #Gives Gain Column           
            MaxGain = uanDatG[1314] #Gain at theta = 90                        
            uanMaxG.append(MaxGain)

        OutputHH = np.column_stack((freqArray, uanMaxG))
        for p in range(numFreq):
            for q in range(2):
                PUEO_h0.write(str(OutputHH[p][q])+" ")
            PUEO_h0.write("\n")
        print("Done with hh_0 for Antenna " +str(antenna+1))

# For vh_0: 
for antenna in range(g.NPOP):
    with open(f'{g.WorkingDir}/Test_Outputs/'+"vh_0_"+{g.gen}+" "+str(antenna+1), "w+") as PUEO_vh0:
        os.chmod(f'{g.WorkingDir}/Test_Outputs/'+"vh_0_"+{g.gen}+" "+str(antenna+1), 0o777)
        uanMaxG = []
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) #Gives Gain Column           
            MaxGain = uanDatG[1314] #Gain at theta = 90                        
            uanMaxG.append(MaxGain)

        OutputVH = np.column_stack((freqArray, uanMaxG))
        for p in range(numFreq):
            for q in range(2):
                PUEO_vh0.write(str(OutputVH[p][q])+" ")
            PUEO_vh0.write("\n")
        print("Done with vh_0 for Antenna " +str(antenna+1))

# for hv_0:
for antenna in range(g.NPOP):
    with open(f'{g.WorkingDir}/Test_Outputs/'+"hv_0_"+{g.gen}+" "+str(antenna+1), "w+") as PUEO_hv0:
        os.chmod(f'{g.WorkingDir}/Test_Outputs/'+"hv_0_"+{g.gen}+" "+str(antenna+1), 0o777)
        uanMaxG = []
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) #Gives Gain Column           
            MaxGain = uanDatG[1314] #Gain at theta = 90                        
            uanMaxG.append(MaxGain)

        OutputHV = np.column_stack((freqArray, uanMaxG))
        for p in range(numFreq):
            for q in range(2):
                PUEO_hv0.write(str(OutputHV[p][q])+" ")
            PUEO_hv0.write("\n")
        print("Done with hv_0 for Antenna " +str(antenna+1))

# Now to pull angles 5, 10, 20, 30, 45, 90 for el or az and respective theta or phi
# Angles and index locations. For theta. 5:[73], 10:[146], 20:[292], 30:[438], 45:[657], 90:[1314]
# For phi. 5:[1], 10:[2], 20:[4], 30:[6], 45:[9], 90:[18]

# Creating new Array with Frequencies 6 times
BIGfreqArray = []
for z in range(6):
    for q in range(numFreq):
        scinoteval = "{:.2e}".format(freqVals[q])
        BIGfreqArray.append(scinoteval)
numBIGarray = 360
# for vv_el: (theta)

for antenna in range(g.NPOP):
    with open(f'{g.WorkingDir}/Test_Outputs/'+"vv_el_"+{g.gen}+" "+str(antenna+1), "w+") as PUEO_vve: 
        os.chmod(f'{g.WorkingDir}/Test_Outputs/'+"vv_el_"+{g.gen}+" "+str(antenna+1), 0o777)
        uanAngG = []
        #print("Gain for 5")
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) #Gain Column
            fiveGain = uanDatG[73]
            uanAngG.append(fiveGain)
            #print(fiveGain)
        #print("Gain for 10")
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            tenGain = uanDatG[146]
            uanAngG.append(tenGain)
            #print(tenGain)
        #print("Gain for 20") 
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            twentyGain = uanDatG[292]
            uanAngG.append(twentyGain)
            #print(twentyGain)
        #print("Gain for 30")
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            thirtyGain = uanDatG[438]
            uanAngG.append(thirtyGain)
            #print(thirtyGain)
        #print("Gain for 45")
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) 
            fortfiveGain = uanDatG[657]
            uanAngG.append(fortfiveGain)
            #print(fortfiveGain)
        #print("Gain for 90")
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            nineGain = uanDatG[1314]
            uanAngG.append(nineGain)
            #print(nineGain)
        #print("Array of these values" + "\n" + str(uanAngG))
        OutputVVE = np.column_stack((BIGfreqArray, uanAngG)) 
        for p in range(numBIGarray):
            for q in range(2):
                PUEO_vve.write(str(OutputVVE[p][q])+" ")
            PUEO_vve.write("\n")
        print("Done with vv_el for Antenna " +str(antenna+1))

# For vv_az:
# For phi. 5:[1], 10:[2], 20:[4], 30:[6], 45:[9], 90:[18] 

for antenna in range(g.NPOP):
    with open(f'{g.WorkingDir}/Test_Outputs/'+"vv_az_"+{g.gen}+" "+str(antenna+1), "w+") as PUEO_vva:
        os.chmod(f'{g.WorkingDir}/Test_Outputs/'+"vv_az_"+{g.gen}+" "+str(antenna+1), 0o777)
        uanAngG = []
        #print("Gain for 5")                                                                                                                                                                                                                                  
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) #Gain Column                                                                                                                                                                                                
            fiveGain = uanDatG[1]
            uanAngG.append(fiveGain)
            #print(fiveGain)                                                                                                                                                                                                                                  
        #print("Gain for 10")                                                                                                                                                                                                                                 
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            tenGain = uanDatG[2]
            uanAngG.append(tenGain)
            #print(tenGain)                                                                                                                                                                                                                                   
        #print("Gain for 20")                                                                                                                                                                                                                                 
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            twentyGain = uanDatG[4]
            uanAngG.append(twentyGain)
            #print(twentyGain)                                                                                                                                                                                                                                
        #print("Gain for 30")                                                                                                                                                                                                                                 
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            thirtyGain = uanDatG[6]
            uanAngG.append(thirtyGain)
            #print(thirtyGain)                                                                                                                                                                                                                                
        #print("Gain for 45")                                                                                                                                                                                                                                 
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            fortfiveGain = uanDatG[9]
            uanAngG.append(fortfiveGain)
            #print(fortfiveGain)                                                                                                                                                                                                                              
        #print("Gain for 90")               
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            nineGain = uanDatG[18]
            uanAngG.append(nineGain)
            #print(nineGain)                                                                                                                                                                                                                                  
        #print("Array of these values" + "\n" + str(uanAngG))                                                                                                                                                                                                 
        OutputVVA = np.column_stack((BIGfreqArray, uanAngG))
        for p in range(numBIGarray):
            for q in range(2):
                PUEO_vva.write(str(OutputVVA[p][q])+" ")
            PUEO_vva.write("\n")
        print("Done with vv_az for Antenna " +str(antenna+1))

# For hh_el:

for antenna in range(g.NPOP):
    with open(f'{g.WorkingDir}/Test_Outputs/'+"hh_el_"+{g.gen}+" "+str(antenna+1), "w+") as PUEO_hhe:
        os.chmod(f'{g.WorkingDir}/Test_Outputs/'+"hh_el_"+{g.gen}+" "+str(antenna+1), 0o777)
        uanAngG = []
        #print("Gain for 5")                                                                                                        
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) #Gain Column                                                                     
            fiveGain = uanDatG[73]
            uanAngG.append(fiveGain)
            #print(fiveGain)                                                                                                        
        #print("Gain for 10")                                                                                                       
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            tenGain = uanDatG[146]
            uanAngG.append(tenGain)
            #print(tenGain)                                                                                                         
        #print("Gain for 20")                                                                                                       
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            twentyGain = uanDatG[292]
            uanAngG.append(twentyGain)
            #print(twentyGain)                                                                                                      
        #print("Gain for 30")                                                                                                       
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            thirtyGain = uanDatG[438]
            uanAngG.append(thirtyGain)
            #print(thirtyGain)                                                                                                      
        #print("Gain for 45")                                                                                                       
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            fortfiveGain = uanDatG[657]
            uanAngG.append(fortfiveGain)
            #print(fortfiveGain)                                                                                                    
        #print("Gain for 90")                                                                                                       
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            nineGain = uanDatG[1314]
            uanAngG.append(nineGain)
            #print(nineGain)                                                                                                        
        #print("Array of these values" + "\n" + str(uanAngG))                                                                       
        OutputHHE = np.column_stack((BIGfreqArray, uanAngG))
        for p in range(numBIGarray):
            for q in range(2):
                PUEO_hhe.write(str(OutputHHE[p][q])+" ")
            PUEO_hhe.write("\n")
        print("Done with hh_el for Antenna " +str(antenna+1))


# For hh_az:

for antenna in range(g.NPOP):
    with open(f'{g.WorkingDir}/Test_Outputs/'+"hh_az_"+{g.gen}+" "+str(antenna+1), "w+") as PUEO_hha:
        os.chmod(f'{g.WorkingDir}/Test_Outputs/'+"hh_az_"+{g.gen}+" "+str(antenna+1), 0o777)
        uanAngG = []
        #print("Gain for 5")                                                                                                       \
                                                                                                                                    
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1) #Gain Column                                                                     \
                                                                                                                                    
            fiveGain = uanDatG[1]
            uanAngG.append(fiveGain)
            #print(fiveGain)                                                                                                       \
                                                                                                                                    
        #print("Gain for 10")                                                                                                      \
                                                                                                                                    
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            tenGain = uanDatG[2]
            uanAngG.append(tenGain)
            #print(tenGain)                                                                                                        \
                                                                                                                                    
        #print("Gain for 20")                                                                                                      \
                                                                                                                                    
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            twentyGain = uanDatG[4]
            uanAngG.append(twentyGain)
            #print(twentyGain) 
#print("Gain for 30")                                                                                                      \
                                                                                                                                    
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            thirtyGain = uanDatG[6]
            uanAngG.append(thirtyGain)
            #print(thirtyGain)                                                                                                     \
                                                                                                                                    
        #print("Gain for 45")                                                                                                      \
                                                                                                                                    
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            fortfiveGain = uanDatG[9]
            uanAngG.append(fortfiveGain)
            #print(fortfiveGain)                                                                                                   \
                                                                                                                                    
        #print("Gain for 90")                                                                                                       
        for freq in range(numFreq):
            uanDatG = readFile(antenna+1, freq+1)
            nineGain = uanDatG[18]
            uanAngG.append(nineGain)
            #print(nineGain)                                                                                                       \
                                                                                                                                    
        #print("Array of these values" + "\n" + str(uanAngG))                                                                      \
                                                                                                                                    
        OutputHHA = np.column_stack((BIGfreqArray, uanAngG))
        for p in range(numBIGarray):
            for q in range(2):
                PUEO_hha.write(str(OutputHHA[p][q])+" ")
            PUEO_hha.write("\n")
        print("Done with hh_az for Antenna " +str(antenna+1))



print("Done writing all new files! WOOOOOOOOOOOOOO") 
