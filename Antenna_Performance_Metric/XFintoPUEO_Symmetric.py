# See `python XFintoPUEO.py --help` for more information
import argparse
import numpy as np

from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(prog = 'XFintoPUEO_Symmetric.py', description = 'Reads theta and phi gains from uan files created by XFdtd to create files for PUEOsim to read in.')
    parser.add_argument("npop", help="Number of individuals per generation.", type=int)
    parser.add_argument("working_dir", help="Base working directory; usually /path/to/Evolutionary_Loop.", type=Path)
    parser.add_argument("run_name", help="Name of current run; directory in /path/to/Run_Outputs where data is stored.", type=str)
    parser.add_argument("gen", help="The generation the loop is on.", type=int)
    parser.add_argument("out_dir", help="Directory to output to.", type=Path)
    # specific indiv is optional
    parser.add_argument("-s", "--single", help="If you want to run a single individual, enter the number of the individual here.", type=int, default=-1)
    return parser.parse_args()


def main(args):
    ## Function calls
    ## Here's the path to output to
    file_header = args.out_dir
    freq_vals = [freq*10**6 for freq in range(200, 1501, 10)]
    #num_freq = 131  # 1500 - 200 = 1300 / 10 = 131 steps    
    freq_list = [str(val) for val in freq_vals]

    ## Loop over the number of individuals
    if args.single != -1:
        callFunctions(args.single, args, freq_list, file_header)
        exit()

    for indiv in range(args.npop):
        callFunctions(indiv, args, freq_list, file_header)


## Function Definitions
## Function to read in files
def read_file(indiv, freq_num, col, args):
    uanname = args.working_dir / 'Run_Outputs' / args.run_name / 'uan_files' / f'{args.gen}_uan_files' / f'{indiv}' / f'{args.gen}_{indiv}_{freq_num}.uan'
    data = np.genfromtxt(uanname, unpack=True, skip_header=18).tolist()

    return data[col]  # Return the gain for the polarization being read
 
## Make a function to create a list for each of the columns (V and H gains)
## This function reads in the gain at each phi for the desired thetas
def getGains(indiv, args, num_freq=131):
    vpol_gains = []
    hpol_gains = []
    hpol_phases = []
    vpol_phases = []

    for freq in range(num_freq):
        vpol_gains.append(read_file(indiv, freq+1, 2, args))
        hpol_gains.append(read_file(indiv, freq+1, 3, args))
        vpol_phases.append(read_file(indiv, freq+1, 4, args))
        hpol_phases.append(read_file(indiv, freq+1, 5, args))

    #convert phases to radians
    vpol_phases = np.radians(vpol_phases)
    hpol_phases = np.radians(hpol_phases)
    
    vpol_gains = np.array(vpol_gains)
    hpol_gains = np.array(hpol_gains)
    
    # turn the gains from dB to absolute, every element in shape (131, 2701)
    vpol_gains = 10**(vpol_gains/10)
    hpol_gains = 10**(hpol_gains/10)
    
    return vpol_gains, hpol_gains, vpol_phases, hpol_phases

## This function writes the data to a file
def writeGains(gain_data, phase_data, 
               freq_list, file_name, num_freq=131):
    with open(file_name, "a") as f:
        for i in range(num_freq):
            f.write(f'{freq_list[i]} {gain_data[i]} {phase_data[i]}\n')

def callFunctions(indiv, args, freq_list, file_header):
    ## Let's call the functions
    ## Start by getting the gain data
    vpol_gain, hpol_gain, vpol_phase, hpol_phase = getGains(indiv, args)
    vpol_gain_t = np.transpose(vpol_gain).tolist()
    hpol_gain_t = np.transpose(hpol_gain).tolist()
    vpol_phase_t = np.transpose(vpol_phase).tolist()
    hpol_phase_t = np.transpose(hpol_phase).tolist()

    ## We're treating vv and hh as the same and vh and hv as the same
    ## So for the _0 files, it's pretty simple:
    
    writeGains(vpol_gain_t[0], vpol_phase_t[0],
               freq_list, file_header / f'vv_0_{args.gen}_{indiv}')
    writeGains(vpol_gain_t[0], vpol_phase_t[0],
               freq_list, file_header / f'hh_0_{args.gen}_{indiv}')
    writeGains(hpol_gain_t[0], hpol_phase_t[0],
               freq_list, file_header / f'vh_0_{args.gen}_{indiv}')
    writeGains(hpol_gain_t[0], hpol_phase_t[0],
               freq_list, file_header / f'hv_0_{args.gen}_{indiv}')
    ## Now we need to be more careful for the az and el files
    ## We want the angles 5, 10, 20, 30, 45, 90
    ## For the azimuth, this is just counting through the phi at 0 theta
    ## We just pick out the 2nd, 3rd, 5th, 7th, 10th, and 19th sublists
    ## So we call the writeGains function for each of those lists
    v_az_file = file_header / f'vv_az_{args.gen}_{indiv}'
    h_az_file = file_header / f'hh_az_{args.gen}_{indiv}'
    v_el_file = file_header / f'vv_el_{args.gen}_{indiv}'
    h_el_file = file_header / f'hh_el_{args.gen}_{indiv}'
    indices = [1, 2, 4, 6, 9, 18]
    for i in indices:
        writeGains(vpol_gain_t[i], vpol_phase_t[i], freq_list, v_az_file)
        writeGains(hpol_gain_t[i], hpol_phase_t[i], freq_list, h_az_file)
    ## For the elevation, we need to count through theta at 0 phi
    ## These are trickier, because theta increments only after all of the phi increments
    ## So if 0,0 (theta, phi) is in the 0th row, and 0,360 is in the 72nd row
    ## then 5,0 is in the 73rd row, and we increment by adding 73 for each theta step
    
    # Reference angles for pueoSim v1.1.0
    reference_angles = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    indices = [int(angle/5)*73 for angle in reference_angles]
    for i in indices:
        writeGains(vpol_gain_t[i], vpol_phase_t[i], freq_list, v_el_file)
        writeGains(hpol_gain_t[i], hpol_phase_t[i], freq_list, h_el_file)


if __name__ == "__main__":
    args = parse_args()
    main(args)