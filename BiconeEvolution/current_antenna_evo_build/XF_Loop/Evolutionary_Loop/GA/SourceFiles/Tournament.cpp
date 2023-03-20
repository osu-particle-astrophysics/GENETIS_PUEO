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

int Tournament(vector<float> fitness, int pool_size)
{
 
  vector<int> contenders; 
  uniform_real_distribution<float> choice(0, fitness.size());

  for( int i =0; i<pool_size; i++)
    {
      random_num = rand() % fitness.size();
      contenders.push_back(random_num);
    }

  int max = 0; 
  for(int j=0; j<pool_size; j++) 
    {
      if(fitness[contenders[j]] > fitness[contenders[max]]) 
	{
	  max = j;
	}
    }

  return(contenders[max]);
  
}
