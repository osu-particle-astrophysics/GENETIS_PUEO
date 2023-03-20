#pragma once

// Libraries
#include <random>

// Global Variables
extern int seed;
extern int generation;
extern int population;
extern int sections;
extern int genes;
extern int reproduction_no;
extern int crossover_no;
extern int mutation_rate;
extern int sigma; 
extern int rank_no; 
extern int roulette_no;
extern int tournament_no;


int Tournament(vector<float> fitness)
{
  // Define starting parameters
  int pool_size = 0.07*population;
  vector<int> contenders; 
  int random_num = 0;
  uniform_real_distribution<float> choice(0, fitness.size());

  // Select contenders for the tournament 
  for( int i =0; i<pool_size; i++)
    {
      random_num = rand() % fitness.size();
      contenders.push_back(random_num);
    }

  // Find the best individual from the contenders
  int max = 0; 
  for(int j=0; j<pool_size; j++) 
    {
      if(fitness[contenders[j]] > fitness[contenders[max]]) 
	{
	  max = j;
	}
    }

  // Return the best individual
  return(contenders[max]);
  
}
