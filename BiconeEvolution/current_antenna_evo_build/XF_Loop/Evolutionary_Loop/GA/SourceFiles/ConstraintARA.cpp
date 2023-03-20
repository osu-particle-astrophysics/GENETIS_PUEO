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

bool ConstraintARA(int R, int L, int A, int B)
{
  bool intersect = true;
  float max_radius = 7.5;
  float min_length = 10.0;
  float max_length = 140.0;
  float min_coeff = -1.0;
  float max_coeff = 1.0;
  float vertex = 0.0f;
  float R = varInput[side][0];
  float L = varInput[side][1];
  float A = varInput[side][2];
  float B = varInput[side][3];
  float end_point = A*L*L + B*L + R;
  
  if(A != 0.0){
    vertex = (R - (B*B)/(4*A));
  }else{
    vertex = end_point;
  }
  if(A == 0.0 && max_radius > end_point && end_point >= 0.0){
    if(R < 0.0 || L < min_length || L > max_length || A < min_coeff || A > max_coeff || B < min_coeff || B > max_coeff){
      intersect = true;
    }else{
      intersect = false;
    }
  }else if (A != 0.0 && max_radius > end_point && end_point >= 0.0 && max_radius > vertex && vertex >= 0.0){
    if(R < 0.0 || L < min_length || L > max_length || A < min_coeff || A > max_coeff || B < min_coeff || B > max_coeff){
      intersect = true;
    }else{
      intersect = false;
    }
  }else{
    intersect = true;
  }
  return intersect;
}
