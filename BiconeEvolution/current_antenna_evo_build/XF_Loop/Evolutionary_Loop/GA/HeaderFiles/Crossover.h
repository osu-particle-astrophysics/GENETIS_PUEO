#pragma once

// User Functions
#include "ConstraintARA.h"
#include "ConstraintPUEO.h"
#include "Selection.h"
#include "Mutation.h"

// Global Variables
extern int seed;
extern string design;
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

void Crossover(vector<vector<vector<float> > > & varInput, vector<vector<vector<float> > > & varOutput, vector<float> fitness, vector<int> P_loc, vector<int> & selected)
{
	// Start Flag
	cout << "Crossover Started" << endl;
	
	// Define Variables
	vector<int> locations;
	double swap;
	uniform_real_distribution<double> choice(0.0, 1.0);

	// call selection methods
	Selection(crossover_no, fitness, locations);

	// Check the size of location vector
	if(locations.size() != crossover_no)
	{
		cout << "error: parent vector is not proper length" << endl;
	}

	// Crossover two antennas to make 2 children
	for(int i=0; i<locations.size(); i=i+2)
	{
		for(int j=0; j<sections; j++)
		{
			// If the design self-intersects, find a new design
			bool intersect = true;
			while (intersect == true)
			{
				for(int k=0; k<genes; k++)
				{
					// Swap genes between parents to create the children
					swap = choice(generator);
					if(swap < .5)
					{
						varOutput[i+reproduction_no][j][k] = varInput[locations[i]][j][k];
						varOutput[i+1+reproduction_no][j][k] = varInput[locations[i+1]][j][k];
	                }
					else
	                {
						varOutput[i+reproduction_no][j][k] = varInput[locations[i+1]][j][k];
						varOutput[i+1+reproduction_no][j][k] = varInput[locations[i]][j][k];
	                }
				}
		  
				// Call constraint functions to make sure the designs are applicable
				if (design == "ARA")
				{
					bool intersect_A = true;
					float R_1= varOutput[i+reproduction_no][j][0];
					float L_1= varOutput[i+reproduction_no][j][1];
					float A_1= varOutput[i+reproduction_no][j][2];
					float B_1= varOutput[i+reproduction_no][j][3];
					intersect_A = ConstraintARA(R_1, L_1, A_1, B_1);
		     
					bool intersect_B = true;
					float R_2= varOutput[i+1+reproduction_no][j][0];
					float L_2= varOutput[i+1+reproduction_no][j][1];
					float A_2= varOutput[i+1+reproduction_no][j][2];
					float B_2= varOutput[i+1+reproduction_no][j][3];
					intersect_B = ConstraintARA(R_2, L_2, A_2, B_2);
			  
					if (intersect_A == false && intersect_B == false)
					{
						intersect = false;
					}
				}
				
				else if (design == "PUEO")
				{
					// Call constraint PUEO for variables
					bool intersect_A = true;
					float S_1= varOutput[i+reproduction_no][j][0];
					float H_1= varOutput[i+reproduction_no][j][1];
					float x0_1= varOutput[i+reproduction_no][j][2];
					float y0_1= varOutput[i+reproduction_no][j][3];
					float yf_1= varOutput[i+reproduction_no][j][4];
					float zf_1= varOutput[i+reproduction_no][j][5];
					float b_1= varOutput[i+reproduction_no][j][6];
					intersect_A = ConstraintPUEO(S_1, H_1, x0_1, y0_1, yf_1, zf_1, b_1);
		     
		     			bool intersect_B = true;
					float S_2= varOutput[i+reproduction_no][j][0];
					float H_2= varOutput[i+reproduction_no][j][1];
					float x0_2= varOutput[i+reproduction_no][j][2];
					float y0_2= varOutput[i+reproduction_no][j][3];
					float yf_2= varOutput[i+reproduction_no][j][4];
					float zf_2= varOutput[i+reproduction_no][j][5];
					float b_2= varOutput[i+reproduction_no][j][6];
					intersect_B = ConstraintPUEO(S_2, H_2, x0_2, y0_2, yf_2, zf_2, b_2);
					
					if (intersect_A == false && intersect_B == false)
					{
						intersect = false;
					}
				}     	  
			}
		}
		// Save location of the parent antennas
		selected.push_back(P_loc[locations[i]]);
		selected.push_back(P_loc[locations[1+i]]);
	}
	// Call Mutation to apply mutations on children
	Mutation(varOutput);
	
	// End Flag
	cout << "Crossover Complete" << endl;
}
