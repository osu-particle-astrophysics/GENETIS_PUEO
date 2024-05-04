# Genetis PUEO Manual

The GENETIS PUEO software utilizes Genetic Algorithms to automatically design Quad Ridged-Horn Antennas towards greater neutrino-sensitivity. 

## Installing the Loop

* install the GENETIS_PUEO loop with `git clone git@github.com:osu-particle-astrophysics/GENETIS_PUEO.git`

* Go into the GENETIS_PUEO directory `cd GENETIS_PUEO`

* Make and enter a new directory for the GA `mkdir GA` 

* `cd GA`

* install the GA from the Shared-Code repository `git clone git@github.com:osu-particle-astrophysics/Shared-Code.git`

## Installing PueoSim

Now we have all of the GENETIS codebase installed. The next step is to install and link the pueoSim simulation software


* Follow the steps [here](https://github.com/osu-particle-astrophysics/GENETIS_PUEO/wiki/Installing-PueoSim)
  
* add the Path of the installation to PSIMDIR in `setup.sh`

### Example: 

if I clone a copy of pueosim to `/fs/ess/PAS1960/buildingPueoSim/pueoBuilder/`

The corresponding variable declaration is 
`PSIMDIR=/fs/ess/PAS1960/buildingPueoSim`

## Running the Loop

The main script that runs all subsequent parts is `Loop_Scripts/Loop.sh`

Steps:

* edit the `setup.sh` file to your desired specifications.

* while inside of the `GENETIS_PUEO` directory, run the command: `./Loop_Scripts/Loop.sh $RunName $setupfile`

* press any key to continue initially

* Press No on the first XF popup

* Done! The loop will automatically continue on from this point


Note: If there is no inputted $setupfile, the loop will default to `setup.sh`

