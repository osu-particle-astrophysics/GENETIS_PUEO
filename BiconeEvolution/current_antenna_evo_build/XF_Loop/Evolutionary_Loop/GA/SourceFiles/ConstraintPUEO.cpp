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

bool ConstraintPUEO(float S, float H, float x_0, float y_0, float y_f, float z_f, float beta)
{
  bool intersect = true;
  float x_f = S;
  if(S > max_S || H > max_H){
    intersect = true;
  }else if(x_0 < 0 || x_0 > x_f){
    intersect = true;
  }else if(y_0 < 0 || y_0 > z_f){
    intersect = true;
  }else if(y_f < 0 || y_f > z_f){
    intersect = true;
  }else if(z_f < 0 || z_f > H){
    intersect = true;
  }else if((4/30)*z_f > beta || (7*z_f) < beta){
    intersect = true;
  }else{
    intersect = false;
  }
  return intersect;
}
