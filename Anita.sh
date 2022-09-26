# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#this modules were originally loading in both the env.sh, and bashrc_anita.sh files. This was redundant so it was added here, and removed from the others.                                           module load gnu/7.3.0
module load gnu
module load mvapich2
module load fftw3
#module load python/3.6-conda5.2
module load cmake
PATH=$PATH:$HOME/.local/bin:$home/bin
export PATH
export CC=`which gcc`
export CXX=`which g++`


export FFTWDIR=/fs/project/PAS0654/shared_software/fftw3/gnu/6.3/mvapich2/2.2/3.3.5
export ANITA_SOURCE_DIR=~/anitaBuildTool/
export ANITA_UTIL_INSTALL_DIR=~/anitaBuildTool/
export ICEMC_SRC_DIR=~/anitaBuildTool/components/icemc/
export ICEMC_BUILD_DIR=~/anitaBuildTool/build/components/icemc/
export DYLD_LIBRARY_PATH=${ICEMC_SRC_DIR}:${ICEMC_BUILD_DIR}:${DYLD_LIBRARY_PATH}
export ROOTSYS=/fs/project/PAS0654/shared_software/anita/owens_pitzer/build/root

# User specific aliases and functions
#This env.sh is for running the BiconeEvolution GENETIS software. This should only be un-commented if you are running GENETIS software. When you do this, comment out env.sh.                      

#source ~/new_root_setup.sh

source /fs/project/PAS0654/shared_software/anita/owens_pitzer/build/root/bin/thisroot.sh

#source /cvmfs/ara.opensciencegrid.org/trunk/centos7/setup.sh
#module load python/3.6-conda5.2

#BiconeGENETIS directory shortcut SHARED                                                                                                                                                           
alias GE='cd ../../../fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/'

#emacs Alias                                                                                                                                                                                       
alias emacs='emacs -nw'

#root alias                                                                                                                                                                                        
alias root='root -l'


#Alias                                                                                                                                                                                             
alias l="ls"

alias python='/cvmfs/ara.opensciencegrid.org/trunk/centos7/misc_build/bin/python3.9'
