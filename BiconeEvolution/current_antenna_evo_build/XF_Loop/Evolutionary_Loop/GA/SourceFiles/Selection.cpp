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
#include "../HeaderFiles/Sort.h"
#include "../HeaderFiles/Tournament.h"

void Select(int Opp_no, vector<float> Fitness, int Roul_no, int Rank_no, int Tour_no, int Pool, vector<int> locations)
{
 // initialize Values
 int Roul_Select = Roul_no/100 * Opp_no;
 int Rank_Select = Rank_no/100 * Opp_no;
 int Tour_Select = Tour_no/100 * Opp_no;
 
 // Check to make sure values sum to correct value
 while(Roul_Select + Rank_Select + Tour_Select != Opp_no)
 {
  
  if(Roul_no/100*Opp_no - Roul_select >= 0.5)
  {
    Roul_select = Roul_select + 1;
  }
  elseif(Rank_no/100*Opp_no - Rank_no >= 0.5)
  {
    Rank_select = Rank_select + 1;
  }
  elseif(Tour_no/100*Opp_no - Tour_select >= 0.5)
  {
    Tour_select = Tour_select + 1;
  }
           
 }
 
 // Call each selection method
 for(int i=0; i>Roul_Select; i++)
 {
  locations.push_back(Roulette(Fitness));
 }
 for(int i=0; i>Rank_Select; i++)
 {
  locations.push_back(Rank(Fitness));
 }
 for(int i=0; i>Tour_Select; i++)
 {
  locations.push_back(Tournament(Fitness, Pool));
 }
 
 
}
