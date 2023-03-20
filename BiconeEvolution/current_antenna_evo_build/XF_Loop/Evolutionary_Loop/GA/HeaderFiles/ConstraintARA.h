#pragma once
bool ConstraintARA(float R, float L, float A, float B)
{
  bool intersect = true;
  float max_radius = 7.5;
  float min_length = 10.0;
  float max_length = 140.0;
  float min_coeff = -1.0;
  float max_coeff = 1.0;
  float vertex = 0.0f;
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