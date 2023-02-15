// New_GA.cpp
// Author: Ryan Debolt, Dylan Wells
// Organization: GENETIS
// Date: 12/5/2022
// Info:
// This New version of the GA is designed to house the functions as standalone functions that can be transplanted
// to any GA  with the plan to make the GA as simple and flexible as possible

// Compile using:
// g++ -std=c++11 New_GA.cpp -o GA.exe

// Call using
// ./Ga.exe "design", generation, population, rank, roulette, tournament, reproduction, crossover, mutation_rate, sigma

// Libraries
#include <time.h>
#include <math.h>
#include <random>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <vector>
#include <chrono>
#include <thread>
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


// GLOBAL CONSTANTS
float max_S=50;
float max_H=50;
int seed = time(NULL);
default_random_engine generator(seed);
string design;
int generation;
int population;
int sections;
int genes;
int reproduction_no;
int crossover_no;
int mutation_rate;
int sigma; 
int rank_no; 
int roulette_no;
int tournament_no;


int main(int argc, char const *argv[])
{
  // Start Flag
  cout << "Genetic Algorithm initialized" << endl;
  cout << endl;
  
  //ARGUMENTS (read in all arguments that determine what functions get run) 
  design = string(argv[1]); // read in ARA or PUEO
  generation = atoi(argv[2]);
  population = atoi(argv[3]); // read in : atoi(argv[x])
  rank_no = atoi(argv[4]);
  roulette_no = atoi(argv[5]);
  tournament_no = atoi(argv[6]);
  reproduction_no = atoi(argv[7]);
  crossover_no = atoi(argv[8]);
  mutation_rate = atoi(argv[9]);
  sigma = atoi(argv[10]);
  
  
  // VECTORS
  vector<int> P_loc (population); // Parent locations vector
  vector<float> fitness (population, 0.0f); // stores fitness score
  vector<int> selected (population);
  
  // Check the design and prepare input/output vectors
  if (design == "ARA")
    {
      // determine sections and genes for ara
      sections = 2;
      genes = 4;
      
    }
    
    // if PUEO, create PUEO antennas
  else if (design == "PUEO")
    {
      // determine sections and genes for PUEO
      sections = 1;
      genes = 7; 
  }
  
  // create in/out vectors based on parameters
  vector<vector<vector<float>>> varInput (population,vector<vector<float> >(sections,vector <float>(genes, 0.0f))); // stores all input antennas
  vector<vector<vector<float>>> varOutput (population,vector<vector<float> >(sections,vector <float>(genes, 0.0f))); // stores all output antennas
  
  
  // FUNCTION CALLS
  
  // Generation zero functions
  if (generation == 0)
  {
    // run initialization
    Initialize(varOutput);
  }
  
  // Generation 1+ functions
  if (generation != 0)
  {
    // Read in data from pervious generation
    DataRead(varInput, fitness);
    
    // Sort vectors by fitness scores
    Sort(fitness, varInput, P_loc);
    
    // Pass individuals from the previous generation into the current one
    Reproduction(varInput, varOutput, fitness, P_loc, selected);
    
    // Create new individuals via sexual reproduction and mutations
    Crossover(varInput, varOutput, fitness, P_loc, selected);
    
    // Introduce new individuals into the population by random generation
    Immigration(varOutput);
  }
  
  // write information to data files
  DataWrite(varOutput, selected);
  
  // End Flag
  cout << endl;
  cout << "Genetic Algorithm Completed" << endl;
  
  return 0;
}
