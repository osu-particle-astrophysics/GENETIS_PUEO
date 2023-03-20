// This function given the number of antannas, a vector to store the antennas and the experiment, will generate
// the zeroth generation of antennas.

// Includes
#include <time.h>
#include <math.h>
#include <random>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <vector>
#include <chrono>
#include <ctime>

using namespace std;

// User functions
#include "../HeaderFiles/ConstraintARA.h"
#include "../HeaderFiles/ConstraintPUEO.h"
#include "../HeaderFiles/Crossover.h"
#include "../HeaderFiles/DataRead.h"
#include "../HeaderFiles/DataWrite.h"
#include "../HeaderFiles/GenerateARA.h"
#include "../HeaderFiles/GeneratePUEO.h"
#include "../HeaderFiles/Immigration.h"
#include "../HeaderFiles/Initialize.h"
#include "../HeaderFiles/Mutation.h"
#include "../HeaderFiles/Rank.h"
#include "../HeaderFiles/Reproduction.h"
#include "../HeaderFiles/Roulette.h"
#include "../HeaderFiles/Selection.h"
#include "../HeaderFiles/Sort.h"
#include "../HeaderFiles/Tournament.h"

void Initialize(vector<vector<vector<float> > > & varOutput, string design)
{
// if the experiment is ARA, then call GenerateARA 
  if(design == "ARA")
  {
    for(int i=0; i<population; i++)
    {
      varOutput[i] = GenerateARA(); 
    }
  }
  
// if the experiment is PUEO, then call GeneratePUEO 
   if(design == "PUEO")
  {
    for(int i=0; i<population; i++)
    {
      varOutput[i] = GeneratePUEO();
    }
  }
}

