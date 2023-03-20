#pragma once
extern int population;
extern string design;

void Initialize(std::vector<std::vector<std::vector<float> > > & varOutput)
{
// if the experiment is ARA, then call GenerateARA 
  if(design == "ARA")
  {
    for(int i=0; i<population; i++)
    {
      varOutput[i] = GenerateARA(); 
    }
  }
  
// if the experiment is PUEO, then call GeneratePUEO 
   if(design == "PUEO")
  {
    for(int i=0; i<population; i++)
    {
      varOutput[i] = GeneratePUEO();
    }
  }
}
