#pragma once
extern float max_S;
extern float max_H;

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
  }else if((4/30)*z_f > (beta*100) || (7*z_f) < (beta*100)){
    intersect = true;
  }else{
    intersect = false;
  }
  return intersect;
}
