#pragma once


// Global Variables
extern int seed;
extern std::default_random_engine generator;
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


int Roulette(vector<float> fitness)
{
  // Define starting parameters
  vector<float> probabilities;
  float total_fitness = 0;

  // Find the sum of all fitness scores
  for(int i=0; i< fitness.size();i++)
    {
      total_fitness = total_fitness + fitness[i];
    }
  
  // Assign probaility to each individual
  for(int j =0; j< fitness.size();j++)
    {
      probabilities.push_back(fitness[j]/total_fitness);
    }

  // Generate random number
  uniform_real_distribution<float> choice(0.0, 1.0);
  float select = choice(generator);

  // Select individual based on random number
  int x=0;
  float probability_sum = 0;
  for(int i=0; probability_sum <= select; i++)
    {
      probability_sum = probability_sum + probabilities[i];
      x=i;
    }
  
  // Return the chosen individual
  return(x);
}