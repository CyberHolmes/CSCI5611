int strokeWidth = 2;

class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
}

//Find the first point on a circle hit when starting at l_start and traveling in direction l_dir
//NOTE: This will only count collisions less than max_t away from l_start
hitInfo lineCircleIntesect(Vec3 center, float r, Vec3 l_start, Vec3 l_dir, float l_len, float max_t){
  hitInfo hit = new hitInfo();
  
  //Step 2: Compute W - a displacement vector pointing from the start of the line segment to the center of the circle
    Vec3 toCircle = center.minus(l_start);
    
    if(toCircle.length() <= r)
    {
      hit.hit = true;
      hit.t = toCircle.length();
    }
    
    //Step 3: Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
    float a = 1;  //Lenght of l_dir (we noramlized it)
    float b = -2*dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
    float c = sq(toCircle.length()) - (r+strokeWidth)*(r+strokeWidth); //different of squared distances
    
    float d = b*b - 4*a*c; //discriminant 
    
    if (d >=0 ){ 
      //If d is positive we know the line is colliding, but we need to check if the collision line within the line segment
      //  ... this means t will be between 0 and the lenth of the line segment
      float t1 = (-b - sqrt(d))/(2*a); //Optimization: we only take the first collision [is this safe?]
      //println(hit.t,t1,t2);
      if (t1 > 0 && t1 < l_len && t1 < max_t){
        hit.hit = true;
        hit.t = t1;
      } 
    }
    
  return hit;
}
