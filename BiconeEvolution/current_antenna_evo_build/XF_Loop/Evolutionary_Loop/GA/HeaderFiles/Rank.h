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

int Rank(vector<float> fitness)
{
  // Define Starting parameters
  vector<float> probabilities;
  float sum_npop=0;
  
  // get the length of the fitness array
  for(int i=1; i<=fitness.size(); i++)
    {
      sum_npop = sum_npop + i;
    }
  
  // Assign probability to each individual
  for(int j=0; j<fitness.size(); j++)
    {
      probabilities.push_back((fitness.size()-j)/(sum_npop));
    }

  // Call a random number 
  uniform_real_distribution<float> choice(0.0, 1.0);
  float select = choice(generator);

  // Grab the individual defined by the random number
  int x=0;
  float probability_sum =0;
  for (int k=0; probability_sum <= select; k++)
    {
      probability_sum = probability_sum + probabilities[k];
      x=k;
    }
  
  // Return the chosen individual
  return(x);
}
