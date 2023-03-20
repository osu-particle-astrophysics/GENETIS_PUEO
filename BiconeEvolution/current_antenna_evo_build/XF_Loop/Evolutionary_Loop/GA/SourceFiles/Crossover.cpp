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

void Crossover(vector<vector<vector<float> > > & varInput, vector<vector<vector<float> > > & varOutput, vector<float> fitness, vector<int> P_loc, vector<int> & selected, float roul_percentage, float tour_percentage, float rank_percentage, int crossover_no, int pool_size, int reproduction_no, float M_rate, float sigma)
{
  int roul_no = roul_percentage * crossover_no;
  int tour_no = tour_percentage * crossover_no;
  int rank_no = rank_percentage * crossover_no;
  vector<int> parents_loc;
  double swap;
  uniform_real_distribution<double> choice(0.0, 1.0);

for(int r=0; r<roul_no; r++)
{
  parents_loc.push_back(new_roulette(fitness)); 
}
for(int t=roul_no; t<roul_no+tour_no; t++) 
{
  parents_loc.push_back(new_tournament(fitness, pool_size));
}
for(int k=roul_no+tour_no; k<crossover_no; k++)
{
 parents_loc.push_back(Rank(fitness));
} 

 if(parents_loc.size() != crossover_no)
   {
     cout << "error: parent vector is not proper length" << endl;
   }

for(int i=0; i<parents_loc.size(); i=i+2)
  {
    for(int j=0; j<NSECTIONS; j++)

      {
	for(int k=0; k<NVARS; k++)
	  {
	    swap = choice(generator);

	    if(swap < .5)
	      {
		varOutput[i+reproduction_no][j][k] = varInput[parents_loc[i]][j][k];
		varOutput[i+1+reproduction_no][j][k] = varInput[parents_loc[i+1]][j][k];
	      }
	    else
	      {
		varOutput[i+reproduction_no][j][k] = varInput[parents_loc[i+1]][j][k];
		varOutput[i+1+reproduction_no][j][k] = varInput[parents_loc[i]][j][k];
	      }
	  }
            float R_1= varOutput[i+reproduction_no][j][0];                                                 
            float l_1= varOutput[i+reproduction_no][j][1]; 
            float a_1= varOutput[i+reproduction_no][j][2];  
            float b_1= varOutput[i+reproduction_no][j][3]; 
            float end_point_1 = (a_1*l_1*l_1 + b_1*l_1 + R_1); 
            float vertex_1 = (R_1 - (b_1*b_1)/(4*a_1)); 
		
	    float R_2= varOutput[i+1+reproduction_no][j][0];
            float l_2= varOutput[i+1+reproduction_no][j][1];
            float a_2= varOutput[i+1+reproduction_no][j][2];
            float b_2= varOutput[i+1+reproduction_no][j][3];
            float end_point_2 = (a_2*l_2*l_2 + b_2*l_2 + R_2);
            float vertex_2 = (R_2 - (b_2*b_2)/(4*a_2));

	    if (a_1 == 0.0 &&  max_outer_radius > end_point_1 && end_point_1 >= 0.0 && a_2 == 0.0 && max_outer_radius > end_point_2 && end_point_2 >= 0.0)
	      {
		j=j;
	      }
            else if(a_1 !=0.0 && max_outer_radius > end_point_1 && end_point_1 >= 0.0 && max_outer_radius > vertex_1 && vertex_1 >= 0.0 && a_2 != 0 && max_outer_radius > end_point_2 && end_point_2 >= 0.0 && max_outer_radius > vertex_2 && vertex_2 >= 0.0)
	      { 
              j=j;
		
	      }
	    else if (a_1 == 0.0 &&  max_outer_radius > end_point_1 && end_point_1 >= 0.0 && a_2 != 0 && max_outer_radius > end_point_2 && end_point_2 >= 0.0 && max_outer_radius > vertex_2 && vertex_2 >= 0.0)
              {
              j=j;
              }

            else if(a_2 == 0.0 && max_outer_radius > end_point_2 && end_point_2 >= 0.0 && a_1 !=0.0 && max_outer_radius > end_point_1 && end_point_1 >= 0.0 && max_outer_radius > vertex_1 && vertex_1 >= 0.0)
              {
              j=j;
              }
 
            else
	      {
              j= j-1; 
	      }
      }
    selected.push_back(P_loc[parents_loc[i]]);
    selected.push_back(P_loc[parents_loc[1+i]]);
  }
 mutation(varOutput, M_rate, sigma, reproduction_no, crossover_no);
}
