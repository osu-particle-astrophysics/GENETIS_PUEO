// This function will generate one antenna for the ARA experiment and then call the constraint function

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

vector<vector<float> > GenerateARA()
{
  // initialize an interesect condidtion
  bool intersect = True;
  vector<vector<<float> > antenna (sections,vector <float>(genes, 0.0f));
  
  // variables
  float max_outer_radius = 7.5;
  float max_radius = max_outer_radius;
  float min_length = 10.0; // in cm
  float max_length = 140;  // in cm
  float max_theta = atan(max_outer_radius/min_length);
  float min_A = -1.0; 
  float max_A = 1.0;
  float min_B = -1.0; 
  float max_B = 1.0;

  for(int i=0; i<sections, i++)
  {
    // while the intersect condition is true, generate the side of an individual
    while(intersect==True)
    {
      std::uniform_real_distribution <float> distribution_radius(0, max_radius);          // Inner Radius
      float R = distribution_radius(generator);
      
      std::uniform_real_distribution <float> distribution_length(min_length, max_length); // Length
      float L = distribution_length(generator);
      
      std::uniform_real_distribution <float> distribution_A(min_A, max_A);                // linear coefficient
      float A = distribution_A(generator);
      
      std::uniform_real_distribution <float> distribution_B(min_B, max_B);                // quadratic coefficient
      float B = distribution_B(generator);
      
      // Take the individual and pass it to the constraint function and update the interesct condition
      intersect = ConstraintARA(R, L, A, B)
    }
    // store the variables into the antenna vector
    antenna[i][0] = R;
    antenna[i][1] = L;
    antenna[i][2] = A;
    antenna[i][3] = B;
  }
  return(antenna)
}
