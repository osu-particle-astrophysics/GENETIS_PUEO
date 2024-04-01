TotalGens=100			## number of generations (after initial) to run through
NPOP=20 #100			## number of individuals per generation
FREQ=60				## the number frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)
NNT=800000			## Number of Neutrinos Thrown in peuosim   
exp=19				## exponent of the energy for the neutrinos in AraSim
num_keys=10			## how many XF keys we are letting this run use
database_flag=0			## 0 if not using the database, 1 if using the database
GeoFactor=1.0
				## These next 3 define the symmetry of the cones.
PUEO=1				## IF 1, we evolve the PUEO quad-ridged horn antenna, if 0, we evolve the Bicone
SYMMETRY=1		## IF 1, then PUEO antenna is square symmetric and only simulate each antenna once
SEPARATION=0    		## If 1, separation evolves. If 0, separation is constant
DEBUG_MODE=0			## 1 for testing (ex: send specific seeds), 0 for real runs
				## These next variables are the values passed to the GA
REPRODUCTION=0			## Number (not fraction!) of individuals formed through reproduction
CROSSOVER=16 #96			## Number (not fraction!) of individuals formed through crossover
MUTATION=4 #4 #1		## Number (not fraction!) of individuals formed through crossover	
SIGMA=5				## Standard deviation for the mutation operation (divided by 100)
ROULETTE=4 #20			## Number (not fraction!) of individuals formed through crossover
TOURNAMENT=4 #20		## Number (not fraction!) of individuals formed through crossover
RANK=12 #60				## Number (not fraction!) of individuals formed through crossover
ELITE=0				## Elite function on/off (1/0)

JobPlotting=0        ## 1 to submit a job to plot the fitness scores, 0 to not submit a job to plot the fitness scores
ParallelXFPUEO=1	## 1 to run pueosim for each antenna as the XF jobs finish, 0 to not
SingleBatch=0       ## 1 to submit a single batch for XF jobs (each job running for n antennas)
PSIMDIR="/fs/ess/PAS1960/buildingPueoSim" 
