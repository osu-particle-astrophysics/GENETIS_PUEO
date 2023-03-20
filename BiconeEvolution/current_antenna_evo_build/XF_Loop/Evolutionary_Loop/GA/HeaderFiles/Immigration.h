#pragma once

extern int reproduction_no;
extern int crossover_no;
extern int population;
extern string design;

void Immigration(vector<vector<vector<float> > > & varOutput)
{
  // Start Flag
  cout << "Immigration Started" << endl;

  // if the experiment is ARA, then call GenerateARA 
  if(design == "ARA")
  {
    for(int i=reproduction_no + crossover_no; i<population; i++)
    {
      varOutput[i] = GenerateARA(); 
    }
  }
  
// if the experiment is PUEO, then call GeneratePUEO 
   if(design == "PUEO")
  {
    for(int i=reproduction_no + crossover_no; i<population; i++)
    {
      varOutput[i] = GeneratePUEO();
    }
  }
  
  // End Flag
  cout << "Immigration Complete" << endl;
}
