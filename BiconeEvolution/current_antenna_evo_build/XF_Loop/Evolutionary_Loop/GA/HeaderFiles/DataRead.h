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


void DataRead(vector<vector<vector<float> > >& varInput, vector<float>& fitness)
{
  int DNA_GARBAGE_END = 9;
  ifstream generationDNA;
  generationDNA.open("generationDNA.csv");
  int csv_file_size = DNA_GARBAGE_END + (population * sections);
  string csvContent[csv_file_size];                              // Contain each line of the csv file
  string strToDbl;                                               // Data change from string to float, then written into verInput or fitness

  // This loop reads through the .csv file line by line
  // If we're in data (past line 9), it reads in the line

  for(int i=0; i<csv_file_size; i++)
    {
      getline(generationDNA, csvContent[i]);
      if (i>=DNA_GARBAGE_END)
	{
	  double j=floor((i-DNA_GARBAGE_END)/sections);         // Figure out which individual we're looking at
	  int p=i-DNA_GARBAGE_END - sections * j;               // pulls out which row of their matrix we're looking at
	  istringstream stream(csvContent[i]);
	  for (int k=0; k<genes; k++)
	    {
	      getline(stream, strToDbl, ',');
	      varInput[j][p][k] = atof(strToDbl.c_str());
	    }
	}
    }

  generationDNA.close();

  // Now we need to read fitness scores:

  ifstream fitnessScores;
  fitnessScores.open("fitnessScores.csv");
  string fitnessRead[population+2];

  for (int i=0; i<(population+2); i++)
    {
      getline(fitnessScores, fitnessRead[i]);
      if (i>=2)
	{
	  fitness[i-2] = atof(fitnessRead[i].c_str());
	  if (fitness[i-2]<0)
	    {
	      fitness[i-2] = 0;                                 // If the fitness Score is less than 0, we set it to 0 to not throw things off
 	    }
	}
    }
  
  fitnessScores.close();

}
