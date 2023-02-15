#pragma once

// User Functions
#include "ConstraintARA.h"
#include "ConstraintPUEO.h"

// Global Variables
extern int seed;
extern std::default_random_engine generator;
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

void Mutation(vector<vector<vector<float> > > & varOutput)
{
	// Start Flag
	cout << "Mutation Started" << endl;
	
	// Set random number generator
	uniform_real_distribution<float> select(0.0, 1.0);

	// itterate over individuals and genes to determine for mutations
	for(int i=reproduction_no; i<crossover_no+reproduction_no; i++)
	{
		for(int j=0; j<sections; j++)
		{
			// Set the intersect condition
			bool intersect = true;
			
			// Initialize vector to store temporary values as to not lose data
			vector<float> temp;
			
			// Attempt mutations and check if viable
			while (intersect == true)
			{
				// Make sure temp is cleared between loops
				temp.clear();
				for(int k=0; k<genes; k++)
				{
					// Save gene into temp
					temp.push_back(varOutput[i][j][k]);
					float s = select(generator);
				
					// See if this gene will be mutated
					if(s <= mutation_rate/100.0)
					{
						// Set distribution based on current gene
						normal_distribution<float> mutate(varOutput[i][j][k], sigma*varOutput[i][j][k]);
					
						// Save the mutated value into temp
						temp[k] = (mutate(generator));
					}	
				}
				
				// Check to see if the antenna is viable
				if (design == "ARA")
				{
					intersect = ConstraintARA(temp[0], temp[1], temp[2], temp[3]);
				}
				else if (design == "PUEO")
				{
					intersect = ConstraintPUEO(temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6]);
				}
			}
			// Save temp values back to the output vector
			for (int k=0; k<genes; k++)
			{
				varOutput[i][j][k] = temp[k];
			}
			// Clear temp
			temp.clear();
		}
	}
	// End Flag
	cout << "Mutation Complete" << endl;
}
