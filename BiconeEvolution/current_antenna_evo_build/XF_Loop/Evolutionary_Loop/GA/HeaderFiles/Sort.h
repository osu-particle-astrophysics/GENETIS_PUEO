#pragma once


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


void Sort(vector<float> & fitness, vector<vector<vector<float> > > & varInput, vector<int> & P_loc)
{
	int i,j,x,y;
	vector<int> O_loc;
	for(int z = 0; z < fitness.size(); z++)
	{
	O_loc.push_back(z);
	}

	for(i = 0; i < fitness.size(); i++)
	{
		double temp = fitness[i];
		int T = O_loc[i];
		vector<vector<vector<float>>> location (1,vector<vector<float> >(sections,vector <float>(genes, 0.0f)));
		for(int a = 0; a < sections; a++)
		{
			for(int b = 0; b < genes; b++)
			{
				location[0][a][b] = varInput[i][a][b];
				
			}
		}
		for(j = i; j > 0 && fitness[j-1] < temp; j--)
		{
			fitness[j] = fitness[j-1];
			P_loc[j] = P_loc[j-1];
			for(x = 0; x < sections; x++)
			{
				for(y = 0; y < genes; y++)
					{
						varInput[j][x][y] = varInput[j-1][x][y];
					}
			}
		}
		fitness[j]=temp;
		P_loc[j] = T;
		for(int a = 0; a < sections; a++)
                {
                        for(int b = 0; b < genes; b++)
                        {
                                varInput[j][a][b] = location[0][a][b];
                        }
                }
	}
}


