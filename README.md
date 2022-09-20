# Genetis PUEO Manual
## Installing IceMC:

### I: Getting anitaBuildTool
   Clone the anitaBuildTool repository (https://github.com/anitaNeutrino/anitaBuildTool) to your user.

    git clone https://github.com/anitaNeutrino/anitaBuildTool

### II: Get the Anita.sh file onto your user.
  
   Copy the file from this repository
  
   Then source the file

    source Anita.sh

   Note: You will need access to PAS0654 for this or you will get a permissions error.


### III: Running the build tool.
   Go into the anitaBuildTool directory

    cd anitaBuildTool

   And run the building script

    ./buildAnita.sh

   Note: There will be an error if you source files for running Ara in your .bashrc  
   Comment these out and restart your terminal before running the build. (remember to source Anita.sh, either in the terminal or in your .bashrc)

```
   CMake Error at components/libRootFftwWrapper/cmake_install.cmake:238 (file):
      file INSTALL cannot copy file
      "/users/PAS1960/dylanwells1629/anitaBuildTool/components/libRootFftwWrapper/include/AnalyticSignal.h"
      to
      "/cvmfs/ara.opensciencegrid.org/v2.0.0/centos7/ara_build/include/AnalyticSignal.h":
      Read-only file system.
   Call Stack (most recent call first):
```

## Running IceMC:

   Go into the directory ../anitaBuildTool/build/components/icemc/
   
   And run the command  
   
    ./icemc -i {inputFile} -o {outputDirectory} -r {runNumber} -n {numberOfNeutrinos} -t {triggerThreshold} -e {energyExponent}
   *May need to chmod -R 775 ../anitaBuildTool/comonents/icemc/ if you get a permissions error  

### inputFile:
   Must be the full path to the file  
   
   Config files are found in ../anitaBuildTool/components/icemc  
    
   Ex: /users/PAS1960/dylanwells1629/anitaBuildTool/components/icemc/inputs.anita4.conf  
    
   Config files are found in ../anitaBuildTool/components/icemc  

### outputDirectory:
   Will be made in ../anitaBuildTool/build/components/icemc/ by default, specify full path otherwise.  

### runNumber: 
   The run number.  

### numberOfNeutrinos:
   The number of neutrinos generated in the simulation.   
   
   Can be found in inputs.conf  
   
   Default is 2,000,000.  
   
   How many neutrinos to generate  


### triggerThreshold:
   Threshold for each band for the frequency domain voltage trigger.  
   
   Default is 2.3  
   
   #thresholds for each band- this is only for the frequency domain voltage trigger.  If using a different trigger scheme then keep these at the default values of 2.3 because the max among them is used for the chance in hell cuts  

### energyExponent:
   The exponent of the energy for the neutrinos  
   
   Can be found in input.conf   
   
   Default is 20   
   
   #Select energy (just enter the exponent) or (30) for baseline ES&S (1) for E^-1 (2) for E^-2 (3) for E^-3 (4) for E^-4 (5) for ES&S flux with cosmological constant (6) for neutrino GZK flux from Iron nuclei (16-22)not using spectrum but just for a single energy (101-114)use all kinds of theoretical flux models  
   
   Note: Input and output are the only required parameters to run icemc (others take their value from the input config file)   

## Outputs:
   Running ./icemc outputs veff+runNumber+.txt   
   
   File contains  
   
   veff_out << spec_string << "\t" << km3sr << "\t" << km3sr_e << "\t" << km3sr_mu << "\t" << km3sr_tau << "\t" << settings1->SIGMA_FACTOR << endl;  
   
   We want to retreive the second column of veff
   
   
   Output files creation is in ../anitaBuildTool/components/icemc/icemc.cc  , look there for more details
   
   
## Inputs:
   Data is in  
   
   ICEMC_DATA_DIR = ~anitaBuildTool/components/icemc/data/

### Reading Gains
   The function ReadGains is defined in components/icemc/anita.cc. 
   From Read Gains:
```   
    hh_0 
    gainsfile.open((ICEMC_DATA_DIR+"/hh_0").c_str()); // gains for horizontal polarization
    vv_0
     gainsfile.open((ICEMC_DATA_DIR+"/vv_0").c_str()); // gains for vertical polarization
    hv_0
    gainsfile.open((ICEMC_DATA_DIR+"/hv_0").c_str()); // gains for h-->v cross polarization
    vh_0
    gainsfile.open((ICEMC_DATA_DIR+"/vh_0").c_str()); // gains for v-->h cross polarization
```

Gain files have gains for frequency range:  

200 Mhz - 1500 Mhz

Gain Files are formatted:  

First Column Frequency, Second Column Gain (in decibels)   

More gain files from function SetGains in components/icemc/anita.cc  
```
    vv_az
    anglefile.open((ICEMC_DATA_DIR+"/vv_az").c_str()); // v polarization, a angle
    hh_az
    anglefile.open((ICEMC_DATA_DIR+"/hh_az").c_str()); // h polarization, a angle
    hh_el
    anglefile.open((ICEMC_DATA_DIR+"/hh_el").c_str()); // h polarization, e angle
    vv_el
    anglefile.open((ICEMC_DATA_DIR+"/vv_el").c_str()); // v polarization, e angle
```
These have the same format as vv_0 and hh_0, except the frequencies go from 2.00e08 to 1.50e09 6 times instead of 1.  
```
for(jjj = 1; jjj < 7; jjj++)  
    for(iii = 0; iii < 131; iii++) {  
      anglefile >> sfrequency >> gain_angle[0][iii][jjj];  
```
From SetGain in components/icemc/anita.cc  

Reference angles:  
0  
5  
10  
20  
30  
45  
90  

IceMC will interpolate gains between these frequencies, see Set_Gain_angle in components/icemc/anita.cc for more information

## Comparing Ara and IceMC Input/Output:


### Comparing Inputs:
   Frequency Lists:  
   Ara - 83.33MHz - 1066.70 MHz, step = 13.33MHz  
   IceMC - 200MHz - 1500MHz, step = 10MHz  
   Number of files read in:  
   Ara - 1  
   IceMC - 8  
   Formating of files:  
   Ara - Theta, Phi, Gain (dB, thetra), Gain (theta), Phase (theta)   
   IceMc - Frequency, Gain (dB)  (Different files cover different thetas and phis)  
   File Type:  
   Ara - .txt  
   IceMC - no suffix (file is just 2 columns of text)  
  

### Comparing Outputs:
   IceMC - veff is in second column in veff+runName+.txt file (in the outputDirectory directory)  
   Ara - veff is at the bottom of the AraOut.txt file  
