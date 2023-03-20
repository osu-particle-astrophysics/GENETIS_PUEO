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

void Mutation(vector<vector<vector<float> > > & varOutput, float M_rate, float sigma, int reproduction_no, int crossover_no)
{
  uniform_real_distribution<float> select(0.0, 1.0);

  for(int i=reproduction_no; i<crossover_no+reproduction_no; i++)
    {
      for(int j=0; j<NSECTIONS; j++)
	{
	  for(int k=0; k<NVARS; k++)
	    {
	      float s = select(generator);
	      if(s <= M_rate)
		{
		  normal_distribution<float> mutate(varOutput[i][j][k], sigma*varOutput[i][j][k]);
		  varOutput[i][j][k] = mutate(generator);
		  int intersect = 0;
		  int constrained = 0;
		  while(intersect == 0 || constrained == 0)
		    {
		      float r = varOutput[i][j][0];
		      float l = varOutput[i][j][1];
		      float a = varOutput[i][j][2];
		      float b = varOutput[i][j][3];
		      float end_point = (a * l * l + b * l + r);
		      float vertex = (r - (b * b)/(4 * a));
	
		      if(a == 0.0 && max_outer_radius > end_point && end_point >= 0.0)
			{
			  if(r<0 || l<min_length || l>max_length || a<min_A || a>max_A || b<min_B || b>max_B)
			    {
			      constrained = 0;
			      varOutput[i][j][k] = mutate(generator);
			    }
			  else
			    {
			      constrained = 1;
			    }
			  intersect = 1;
			}
		      else if(a != 0.0 && max_outer_radius > end_point && end_point >= 0.0 && max_outer_radius > vertex && vertex >= 0.0)
			{
			  if(r<0 || l<min_length || l>max_length || a<min_A || a>max_A || b<min_B || b>max_B)
                            {
                              constrained = 0;
                              varOutput[i][j][k] = mutate(generator);
                            }
                          else
                            {
                              constrained = 1;
                            }
			  intersect = 1;
			}
		      else
			{
			  intersect = 0;
			  varOutput[i][j][k] = mutate(generator);
			}
		    }
		}
	    }
	}
    }
}
