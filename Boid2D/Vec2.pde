//Vector Library [2D]
//CSCI 5611 Vector 2 Library [Solution]

//Instructions: Implement all of the following vector operations--

public class Vec2 {
  public float x, y;
  
  public Vec2(float x, float y){
    // Constructor
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ ", " + y +")";
  }
  
  public float length(){
    return sqrt(sq(x) + sq(y));
  }
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x,y+rhs.y);
  }
  
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x - rhs.x, y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  public Vec2 times(float rhs){
    return new Vec2(x*rhs, y*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
  }
  
  public void normalize(){
    float temp = this.length();
    if (temp != 0.0) {
      x /= temp;
      y /= temp;
    }    
  }
  
  public Vec2 normalized(){
    float temp = this.length();
    if (temp != 0.0) {
      return new Vec2(x/temp, y/temp);
    } else {
      return new Vec2(x,y);
    }
  }
  
  public float distanceTo(Vec2 rhs){
    return sqrt(sq(x-rhs.x)+sq(y-rhs.y));
  }
  
  public void clampToLength(float maxL){
    float magnitude = sqrt(x*x + y*y);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
    }
  }
  
  public void setToLength(float newL){
    float magnitude = sqrt(x*x + y*y);
    x *= newL/magnitude;
    y *= newL/magnitude;
  }
  
}

Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return new Vec2(interpolate(a.x,b.x,t), interpolate(a.y,b.y,t));
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b){
  return a.x*b.x+a.y*b.y;
}

float angle(Vec2 a, Vec2 b){
  return acos(dot(a,b)/(a.length()*b.length()));
}

Vec2 projAB(Vec2 a, Vec2 b){
  float temp1,temp;
  temp1 = sq(b.length());
  if (temp1 == 0){
    return b;
  } else {
    temp = dot(a,b)/sq(b.length());
    return new Vec2(temp*b.x, temp*b.y);
  }  
}
