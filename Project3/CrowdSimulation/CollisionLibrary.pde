
boolean rayCircleIntersect(Vec3 center, float r, Vec3 l_start, Vec3 l_dir, float max_t){
  
  //Compute displacement vector pointing from the start of the line segment to the center of the circle
  Vec3 toCircle = center.minus(l_start);
  
  //Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
  float a = l_dir.length();  
  float b = -2*dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
  float c = toCircle.lengthSqr() - (r*r); //different of squared distances
  
  float d = b*b - 4*a*c; //discriminant 
  
  if (d >=0 ){ 
    //If d is positive we know the line is colliding, but we need to check if the collision line within the line segment
    //  ... this means t will be between 0 and the length of the line segment
    float t1 = (-b - sqrt(d))/(2*a); 
    float t2 = (-b + sqrt(d))/(2*a); 
    //println(hit.t,t1,t2);
    if (t1 > 0 && t1 < max_t){ //We intersect the circle
      return true;
    }
    else if (t1 < 0 && t2 > 0){ //We start in the circle
      return true; 
    }
    
  }
  
  return false;
}

float rayCircleIntersectTime(Vec3 center, float r, Vec3 l_start, Vec3 l_dir){
  
  //Compute displacement vector pointing from the start of the line segment to the center of the circle
  Vec3 toCircle = center.minus(l_start);
  
  //Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
  float a = l_dir.length(); 
  float b = -2*dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
  float c = toCircle.lengthSqr() - (r*r); //different of squared distances
  
  float d = b*b - 4*a*c; //discriminant 
  
  if (d >=0 ){ 
    //If d is positive we know the line is colliding
    float t = (-b - sqrt(d))/(2*a); //Optimization: we typically only need the first collision! 
    if (t >= 0) return t;
    return -1;
  }
  
  return -1; //We are not colliding, so there is no good t to return 
}
