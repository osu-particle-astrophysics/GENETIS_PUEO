#include <time.h>
#include <math.h>
#include <random>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <vector>
#include <chrono>
#include <thread>
#include <math.h>
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

void DataWrite( vector<vector<vector<float> > >& varVector, vector<int> selected)
{
  ofstream generationDNA;
  generationDNA.open("generationDNA.csv");
  generationDNA << "Hybrid of Roulette and Tournament -- Thanks to Cal Poly / Jordan Potter" << "\n";
  generationDNA << "Author was David Liu" << "\n";
  generationDNA << "Notable contributors: Julie Rolla, Hannah Hasan, and Adam Blenk" << "\n";
  generationDNA << "Done at The Ohio State University" << "\n";
  generationDNA << "Working on behalf of Dr. Amy Connolly" << "\n";
  generationDNA << "And the ANITA project" << "\n";
  generationDNA << "Revision date: 21 March 2018 1800 EST" << "\n";
	
  /*for(int i=0;i<freq_coeffs;i++)
    {
      if(i==freq_coeffs-1)
	{
	  generationDNA << freqVector[i] << "\n";
	}
      else
	{
	  generationDNA << freqVector[i] << ",";
	}
     }
     */
     
  generationDNA << "Matrices for this Generation: " << "\n";
  for(int i=0;i<population;i++)
    {
      for(int j=0;j<sections;j++)
	{
	  for(int k=0;k<genes;k++)
	    {
	      if(k==(genes-1))
		{
		  generationDNA << varVector[i][j][k] << "\n";
		}
	      else
		{
		  generationDNA << varVector[i][j][k] << ",";
		}
	    }
	}
    }
  generationDNA.close();
  
  
  // PARENT LOCATION FILE
  if (generation == 0)
    {
      ofstream Parents;
      Parents.open("parents.csv");
      Parents << "Location of individuals used to make this generation:" << endl;
      Parents << "Seed: " << seed << endl;
      Parents << "\n" << endl;
      Parents << "Current Gen, Parent 1, Parent 2, Operator" << endl;
      int j=0;

      for(int i=0; i<population; i++)
	{
	  if( i<reproduction_no )
	    {
	      Parents << setw(2) << i+1 << ", " << setw(2) << selected[i]+1 << setw(2) << ", NA, Reproduction" << endl;
	    }
	  else if( i>=reproduction_no && i<crossover_no+reproduction_no )
	    {
	      if( j%2 == 0 )
		{
		  Parents << setw(2) << i+1 << ", " << setw(2) << selected[i]+1 << ", " << setw(2) << selected[i+1]+1 << ", Crossover" << endl;
		}
	      else if( j%2 != 0 )
		{
		  Parents << setw(2) << i+1 << ", " << setw(2) << selected[i-1]+1 << ", " << setw(2) << selected[i]+1 << ", Crossover" << endl;
		}
	      j=j+1;
	    }
	  else
	    {
	      Parents << setw(2) << i+1 << ", NA, NA, Immigration" << endl;
	    }
	}
      Parents.close();
    }
}
