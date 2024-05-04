############### GENERAL PARAMS ####################################
TotalGens=100			## number of generations (after initial) to run through
NPOP=4 					## number of individuals per generation
FREQS=131				## the number frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)
FreqStart=200.00
FreqStep=10.0
NNT=10000				## Number of Neutrinos Thrown in peuosim   
exp=19					## exponent of the energy for the neutrinos in AraSim
num_keys=10				## how many XF keys we are letting this run use
database_flag=0			## 0 if not using the database, 1 if using the database
GeoFactor=1.0
DEBUG_MODE=0			## 1 for testing (ex: send specific seeds), 0 for real runs
SteadyState=0		## 1 for steady state, 0 for transient
ForcedDiversity=1        ## 1 for forced diversity, 0 for not

############### ANTENNA PARAMS #######################################
PUEO=1					## IF 1, we evolve the PUEO quad-ridged horn antenna, if 0, we evolve the Bicone
SYMMETRY=1				## IF 1, then PUEO antenna is square symmetric and only simulate each antenna once
SEPARATION=0    		## If 1, separation evolves. If 0, separation is constant

############## GA #############################################
REPRODUCTION=0.0		## percent of individuals formed through reproduction
CROSSOVER=0.5 			## percent of individuals formed through crossover
MUTATION=0.5 	        ## percent of individuals formed through crossover	
SIGMA=0.05				## Standard deviation for the mutation operation
ROULETTE=0.0 		    ## percent of individuals formed through crossover
TOURNAMENT=1.0 		    ## percent of individuals formed through crossover
RANK=0.0				## percent of individuals formed through crossover
ELITE=0					## Elite function on/off (1/0)
REPLACEMENT="random"    ## random, worst, or best, ONLY SSGA

############### JOB SUBMISSION ###############################
JobPlotting=0        ## 1 to submit a job to plot the fitness scores, 0 to not submit a job to plot the fitness scores
ParallelXFPUEO=1	## 1 to run pueosim for each antenna as the XF jobs finish, 0 to not
SingleBatch=0       ## 1 to submit a single batch for XF jobs (each job running for n antennas)

############### PATHS ########################################
PSIMDIR="/fs/ess/PAS1960/buildingPueoSim" 
