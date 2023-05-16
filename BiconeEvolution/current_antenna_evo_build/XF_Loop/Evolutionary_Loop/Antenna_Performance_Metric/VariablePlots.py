
import numpy as np		# for data manipulation, storage
import matplotlib.pyplot as plt	# For plotting
import os			# exclusively for rstrip()
import argparse			# for getting the user's arguments from terminal
import matplotlib.cm as cm
import matplotlib as mpl


# We need to grab the three arguments from the bash script or user. These arguments in order are [the name of the source folder of the fitness scores], [the name of the destination folder for the plots], and [the number of generations] #why is is number of generations and not gen number??
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory", type=str)
parser.add_argument("numGens", help="Number of generations the code is running for", type=int)
parser.add_argument("NPOP", help="Number of individuals in a population", type=int)
parser.add_argument("GeoScalingFactor", help="The number by which we are scaling the antenna dimensions", type=int)
g = parser.parse_args()

# The name of the plot that will be put into the destination folder, g.destination
PlotName = "VariablePlot"


#----------DEFINITIONS HERE----------DEFINITIONS HERE----------DEFINITIONS HERE----------DEFINITIONS HERE
#----------STARTS HERE----------STARTS HERE----------STARTS HERE----------STARTS HERE 

# let me make an array holding each generation number
# I'm going to add small random numbers to these so that we can spread apart the data points a bit
np.random.seed(1) # seed the random number generator so each generation looks the same each time we recreated the plot
gen_array = []
for i in range(g.NPOP):
	gen_num = []
	for j in range(g.numGens):
		gen_num.append(j+np.random.uniform(-1/10,1/10,1))

	gen_array.append(gen_num)

#print(gen_array)


# READ DATA (runData.csv)

# runData.csv contains every antenna's DNA and fitness score for all generations. Format for each individual is radius, length, angle, fitness score (I call these characteristics).

# First, grab each line of the runData.csv as one element in a 1D list.
runDataRaw =[]
with open(g.source+"/runData.csv", "r") as runDataFile:
	runDataRaw=runDataFile.readlines()

# This list has each element terminating with '\n', so we use rstrip to remove '\n' from each string
for i in range(len(runDataRaw)):
	runDataRaw[i] = runDataRaw[i].rstrip()
# Now, we want to store this data in a 2D numpy array. As we'll see, this is a fairly complex process! First, make a new 2D list that contains only the numbers.
runDataRawOnlyNumb =[]
for i in range(len(runDataRaw)):
	# We want to skip the empty line and the 'Generation :' line
	if i%(g.NPOP+2) != 0 and i%(g.NPOP+2) != 1:
		# The split function takes '1.122650,19.905200,0.504576,32.500000' -> ['1.122650', '19.905200', '0.504576', '32.500000'] , which makes the new list 2D
		runDataRawOnlyNumb.append(runDataRaw[i].split(','))#.astype(float) 
#print("RawOnlyNumb ")
#print(runDataRawOnlyNumb)
#print(len(runDataRawOnlyNumb))
# Now convert it to a numpy array and roll it up
runData = []
runData = np.array(runDataRawOnlyNumb)
#print("runData ")
#print(runData)
runData = np.array(runDataRawOnlyNumb).astype(np.float)
#print("runData ")
#print(runData)
runData = runData.reshape((g.numGens, g.NPOP, 8))
#8 is for NVars + 1 where the 1 is the fitness score
#runData = np.array(runData, np.float).reshape(g.numGens, g.NPOP, 4)
# Finally, the data is in an almost useable shape: (generation, individual, characteristic)


# PLOT DATA
#variables are S, H, Xi, Yi, Zf, Yf, beta 

# Create an array of every S

allS = runData[:,:, 0].flatten()

SArray = []
tempS = []
for ind in range(g.NPOP):
    for l in range(0,len(allS),g.NPOP):
        tempS.append(g.GeoScalingFactor*allS[l+ind])
    SArray.append(tempS)
    tempS = []

# Create an array of every H

allH = runData[:,:, 1].flatten()

HArray = []
tempH = []
for ind in range(g.NPOP):
    for l in range(0,len(allH),g.NPOP):
        tempH.append(g.GeoScalingFactor*allH[l+ind])
    HArray.append(tempH)
    tempH = []

# Create an array of every Xi

allXi = runData[:,:, 2].flatten()

XiArray = []
tempXi = []
for ind in range(g.NPOP):
    for l in range(0,len(allXi),g.NPOP):
        tempXi.append(g.GeoScalingFactor*allXi[l+ind])
    XiArray.append(tempXi)
    tempXi = []

# Create an array of every Yi

allYi = runData[:,:, 3].flatten()

YiArray = []
tempYi = []
for ind in range(g.NPOP):
    for l in range(0,len(allYi),g.NPOP):
        tempYi.append(g.GeoScalingFactor*allYi[l+ind])
    YiArray.append(tempYi)
    tempYi = []

# Create an array of every Zf

allZf = runData[:,:, 4].flatten()

ZfArray = []
tempZf = []
for ind in range(g.NPOP):
    for l in range(0,len(allZf),g.NPOP):
        tempZf.append(g.GeoScalingFactor*allZf[l+ind])
    ZfArray.append(tempZf)
    tempZf = []

# Create an array of every Yf

allYf = runData[:,:, 5].flatten()

YfArray = []
tempYf = []
for ind in range(g.NPOP):
    for l in range(0,len(allYf),g.NPOP):
        tempYf.append(g.GeoScalingFactor*allYf[l+ind])
    YfArray.append(tempYf)
    tempYf = []

# Create an array of every beta

allBeta = runData[:,:, 6].flatten()

BetaArray = []
tempBeta = []
for ind in range(g.NPOP):
    for l in range(0,len(allBeta),g.NPOP):
        tempBeta.append(allBeta[l+ind])
    BetaArray.append(tempBeta)
    tempBeta = []



# Plot!
#Create figure and subplots
mpl.rcParams['text.usetex'] = True
fig = plt.figure(figsize=(40, 8))
plt.style.use('seaborn')
axS = fig.add_subplot(1,7,1)
axH = fig.add_subplot(1,7,2)
axXi = fig.add_subplot(1,7,3)
axYi = fig.add_subplot(1,7,4)
axZf = fig.add_subplot(1,7,5)
axYf = fig.add_subplot(1,7,6)
axBeta = fig.add_subplot(1,7,7)


'''
# let's make some random shifts to add to the x axis
random_shift = []
for i in range(g.NPOP):
	x = []
	for j in range(g.numGens):
		x.append(np.random.uniform(-1/5,1/3,5))
	random_shift.append(x)
	print(random_shift)
	
# now let's make a new array with the gens and shifts
modified_gens = []
for i in range(g.NPOP):
	l = []
	for j in range(g.numGens):
		k = random_shift[i][j] + gen_array[i][j]
		l.append(k)
	modified_gens.append(l)
'''

# Loop through each individual and plot each array
colors = cm.rainbow(np.linspace(0, 1, g.NPOP))
# Testing our colorblind friendly colors
colors2 = ['#00429d', '#3e67ae', '#618fbf', '#85b7ce', '#b1dfdb', '#ffcab9', '#fd9291', '#e75d6f', '#c52a52', '#93003a']
for ind in range(g.NPOP):
    LabelName = "Individual {}".format(ind+1)
    E = np.random.uniform(-1/3, 1/3)
    axS.plot(gen_array[ind], SArray[ind], marker = 'o', label = LabelName, color = colors2[ind%10], linestyle = '', alpha = 0.4, markersize=10)
    axH.plot(gen_array[ind], HArray[ind], marker = 'o', label = LabelName, color = colors2[ind%10], linestyle = '', alpha = 0.4, markersize=10)
    axXi.plot(gen_array[ind], XiArray[ind], marker = 'o', label = LabelName, color = colors2[ind%10], linestyle = '', alpha = 0.4, markersize=10)
    axYi.plot(gen_array[ind], YiArray[ind], marker = 'o', label = LabelName, color = colors2[ind%10], linestyle = '', alpha = 0.4, markersize=10)
    axZf.plot(gen_array[ind], ZfArray[ind], marker = 'o', label = LabelName, color = colors2[ind%10], linestyle = '', alpha = 0.4, markersize=10)
    axYf.plot(gen_array[ind], YfArray[ind], marker = 'o', label = LabelName, color = colors2[ind%10], linestyle = '', alpha = 0.4, markersize=10)
    axBeta.plot(gen_array[ind], BetaArray[ind], marker = 'o', label = LabelName, color = colors2[ind%10], linestyle = '', alpha = 0.4, markersize=10)
	#axO.plot(bigRadii[ind], marker = 'o', label = LabelName, linestyle = '')

# Labels:

def get_sub(x):
    normal = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-=()"
    sub_s = "ₐ₈CDₑբGₕᵢⱼₖₗₘₙₒₚQᵣₛₜᵤᵥwₓᵧZₐ♭꜀ᑯₑբ₉ₕᵢⱼₖₗₘₙₒₚ૧ᵣₛₜᵤᵥwₓᵧ₂₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎"
    res = x.maketrans(''.join(normal), ''.join(sub_s))
    return x.translate(res)

littlef = get_sub("F")
littlei = get_sub("i")

#S subplot
axS.set_xlabel("Generation", size = 18)
axS.set_ylabel("S [cm]", size = 18)
axS.set_title("S over Generations (0 - {})".format(int(g.numGens-1)), size = 20)

#H subplot
axH.set_xlabel("Generation", size = 18)
axH.set_ylabel("H [cm]", size = 18)
axH.set_title("H over Generations (0 - {})".format(int(g.numGens-1)), size = 20)

#Xi subplot
axXi.set_xlabel("Generation", size = 18)
axXi.set_ylabel("Initial X [cm]", size = 18)
axXi.set_title("Initial X over Generations (0 - {})".format(int(g.numGens-1)), size = 20)

#Yi subplot
axYi.set_xlabel("Generation", size = 18)
axYi.set_ylabel("Initial Y [cm]", size = 18)
axYi.set_title("Initial Y over Generations (0 - {})".format(int(g.numGens-1)), size = 20)

#Zf subplot
axZf.set_xlabel("Generation", size = 18)
axZf.set_ylabel("Final Z [cm]", size = 18)
axZf.set_title("Final Z over Generations (0 - {})".format(int(g.numGens-1)), size = 20)

#Yf subplot
axYf.set_xlabel("Generation", size = 18)
axYf.set_ylabel("Final Y [cm]", size = 18)
axYf.set_title("Final Y over Generations (0 - {})".format(int(g.numGens-1)), size = 20)

#Beta subplot
axBeta.set_xlabel("Generation", size = 18)
axBeta.set_ylabel("Beta", size = 18)
axBeta.set_title("Beta over Generations (0 - {})".format(int(g.numGens-1)), size = 20)

#Setting the tici marks
axS.set_xticks(np.arange(0, g.numGens, 5))
axH.set_xticks(np.arange(0, g.numGens, 5))
axXi.set_xticks(np.arange(0, g.numGens, 5))
axYi.set_xticks(np.arange(0, g.numGens, 5))
axZf.set_xticks(np.arange(0, g.numGens, 5))
axYf.set_xticks(np.arange(0, g.numGens, 5))
axBeta.set_xticks(np.arange(0, g.numGens, 5))

#Making the grids
axS.grid()
axS.xaxis.grid(linestyle = '--', linewidth = 0.5)
axS.yaxis.grid(linestyle = '--', linewidth = 0.5)

axH.grid()
axH.xaxis.grid(linestyle = '--', linewidth = 0.5)
axH.yaxis.grid(linestyle = '--', linewidth = 0.5)

axXi.grid()
axXi.xaxis.grid(linestyle = '--', linewidth = 0.5)
axXi.yaxis.grid(linestyle = '--', linewidth = 0.5)

axYi.grid()
axYi.xaxis.grid(linestyle = '--', linewidth = 0.5)
axYi.yaxis.grid(linestyle = '--', linewidth = 0.5)

axZf.grid()
axZf.xaxis.grid(linestyle = '--', linewidth = 0.5)
axZf.yaxis.grid(linestyle = '--', linewidth = 0.5)

axYf.grid()
axYf.xaxis.grid(linestyle = '--', linewidth = 0.5)
axYf.yaxis.grid(linestyle = '--', linewidth = 0.5)

axBeta.grid()
axBeta.xaxis.grid(linestyle = '--', linewidth = 0.5)
axBeta.yaxis.grid(linestyle = '--', linewidth = 0.5)

#save the plot
plt.savefig(g.destination + "/" + PlotName)
