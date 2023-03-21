#pragma once

#include <vector>
#include <random>
extern int genes;
extern int sections;
extern int seed;
extern std::default_random_engine generator;

std::vector<std::vector<float> > GenerateARA()
{
  // initialize an interesect condidtion
  bool intersect = true;
  std::vector<std::vector<float> > antenna (sections,std::vector <float>(genes, 0.0f));
  
  // variables
  float max_outer_radius = 7.5;
  float max_radius = max_outer_radius;
  float min_length = 10.0; // in cm
  float max_length = 140;  // in cm
  float max_theta = atan(max_outer_radius/min_length);
  float min_A = -1.0; 
  float max_A = 1.0;
  float min_B = -1.0; 
  float max_B = 1.0;
  float R, L, A, B;
  for(int i=0; i<sections; i++)
  {
    // while the intersect condition is true, generate the side of an individual
    intersect = true;
    while(intersect==true)
    {
      std::uniform_real_distribution <float> distribution_radius(0, max_radius);          // Inner Radius
      R = distribution_radius(generator);
      
      std::uniform_real_distribution <float> distribution_length(min_length, max_length); // Length
      L = distribution_length(generator);
      
      std::uniform_real_distribution <float> distribution_A(min_A, max_A);                // linear coefficient
      A = distribution_A(generator);
      
      std::uniform_real_distribution <float> distribution_B(min_B, max_B);                // quadratic coefficient
      B = distribution_B(generator);
      
      // Take the individual and pass it to the constraint function and update the interesct condition
      intersect = ConstraintARA(R, L, A, B);
    }
    // store the variables into the antenna std::vector
    antenna[i][0] = R;
    antenna[i][1] = L;
    antenna[i][2] = A;
    antenna[i][3] = B;
  }
  return(antenna);
}
