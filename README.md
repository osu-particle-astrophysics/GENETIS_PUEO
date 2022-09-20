# Genetis PUEO Manual
## Installing IceMC:

### I: Getting anitaBuildTool
   Clone the anitaBuildTool repository (https://github.com/anitaNeutrino/anitaBuildTool) to your user.

    git clone https://github.com/anitaNeutrino/anitaBuildTool

### II: Get the Anita.sh file onto your user.
  
   Should be part of the repository
  
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

## Outputs:
   Running ./icemc outputs veff+runNumber+.txt   
   
   File contains  
   
   veff_out << spec_string << "\t" << km3sr << "\t" << km3sr_e << "\t" << km3sr_mu << "\t" << km3sr_tau << "\t" << settings1->SIGMA_FACTOR << endl;  
   
   Input and output are the only required parameters (others take their value from the input config file)
   
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
for(jjj = 1; jjj < 7; jjj++)  
    for(iii = 0; iii < 131; iii++) {  
      anglefile >> sfrequency >> gain_angle[0][iii][jjj];  

SetGains loops through these 6 frequency lists, (1 to 6, 131 lines each)
What are the angles of these?
F
Setgain angle
Reference angles:
0
5
10
20
30
45
90


double relativegains[4]; // fill this for each frequency bin for each antenna.  It's the gain of the antenna given the angle that the signal hits the balloon, for vv, vh, hv, hh, relative to the gain at boresight
Maybe icemc interpolates for gains at different thetas and phis?
// reads in the effect of a signal not hitting the antenna straight on
// also reads in gainxx_measured and sets xxgaintoheight
Set_gain_angle

  for(jjj = 0; jjj < 6; jjj++) inv_angle_bin_size[jjj] = 1. /
                                 (reference_angle[jjj+1] - reference_angle[jjj]); // this is used for interpolating gains at angles between reference angles
 
  double gainhv, gainhh, gainvh, gainvv;
  double gain_step = frequency_forgain_measured[1]-frequency_forgain_measured[0]; // how wide are the steps in frequency;
 
  cout << "GAINS is " << GAINS << "\n";
  for (int k = 0; k < NFREQ; ++k) {
    whichbin[k] = int((freq[k] - frequency_forgain_measured[0]) / gain_step); // finds the gains that were measured for the frequencies closest to the frequency being considered here
    if((whichbin[k] >= NPOINTS_GAIN || whichbin[k] < 0) && !settings1->FORSECKEL) {
      cout << "Set_gain_angle out of range, freq = " << freq[k] << endl;
      exit(1);
    }
 
    //now a linear interpolation for the frequency
    scalef2[k] = (freq[k] - frequency_forgain_measured[whichbin[k]]) / gain_step;
    // how far from the lower frequency
    scalef1[k] = 1. - scalef2[k]; // how far from the higher frequency
 
Seems to interpolate for other gains. Only reads in those 8 files. That's weird, but ok?

Outputs:
IceMC outputs file veff+runNum+.txt in outputDirectory
We want the veff found in the second column

Ara Input/Output:

Input:
XF .uan outputs have Code Headers
Theta, Phi, Gain Theta (dB), Gain Phi (db), Phase Theta, Phase Phi
Ara input files have format:
Theta, Phi, Gain (db, theta), Gain (theta), Phase (Theta)
.txt

Output:
Veff can be found at the bottom of the AraOut.txt file




Comparing Inputs:
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

Other notes for IceMC inputs:
IceMC reads in 8 different files for gain.
vv_0  hh_0  vh_0  hv_0  vv_el  vv_az  hh_el  hh_az
Found in ../anitaBuiltTool/components/icemc/data
vv_0 = gains for vertical polarization
hh_0 = gains for horizontal polarization
vh_0 = gains for v → h cross polarization
hv_0 = gains for h → v cross polarization
vv_el = v polarization, e angle
vv_az = v polarization, a angle
hh_el = h polarization, e angle
hh_az = h polarization a angle
for e angle and a angle  in 
      0.   0
5
10
20
30
45
90
(runs 1 to 6)

Comparing Outputs:
IceMC - veff is in second column in veff+runName+.txt file (in the outputDirectory directory)
Ara - veff is at the bottom of the AraOut.txt file
