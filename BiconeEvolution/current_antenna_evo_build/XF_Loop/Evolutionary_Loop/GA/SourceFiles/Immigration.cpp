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

void Immigration(vector<vector<vector<float> > > & varOutput, int reproduction_no, int crossover_no, float max_length, float max_radius, float max_seperation, float max_outer_radius, float max_A, float max_B)
{
  uniform_real_distribution<float> l_mut(min_length, max_length);
  uniform_real_distribution<float> r_mut(0, max_radius);
  uniform_real_distribution<float> a_mut(min_A, max_A);
  uniform_real_distribution<float> b_mut(min_B, max_B);
  uniform_real_distribution<float> s_mut(min_seperation, max_seperation);

  for(int i=reproduction_no+crossover_no; i< varOutput.size(); i++)
    {
      for(int j=0; j<NSECTIONS; j++)
	{
	  varOutput[i][j][0] = r_mut(generator);
	  varOutput[i][j][1] = l_mut(generator);
	  varOutput[i][j][2] = a_mut(generator);
	  varOutput[i][j][3] = b_mut(generator);
	  varOutput[i][j][4] = s_mut(generator);

          float R= varOutput[i][j][0]; 
          float l= varOutput[i][j][1]; 
          float a= varOutput[i][j][2]; 
          float b= varOutput[i][j][3]; 
          float end_point = (a*l*l + b*l + R); 
          float vertex = (R - (b*b)/(4*a)); 

	  if(a == 0.0 && max_outer_radius > end_point && end_point >= 0.0)
	    {
	      j=j;
	    }
          else if(a != 0.0 && max_outer_radius > end_point && end_point >= 0.0 && max_outer_radius > vertex && vertex >= 0.0)
	  {
            j= j;
          }
          else{
            j= j-1;
          }
	  
	}
    }
}
