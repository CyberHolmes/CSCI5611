//Vector Library [2D]
//CSCI 5611 Vector 3 Library [Incomplete]

//Instructions: Add 3D versions of all of the 2D vector functions
//              Vec3 must also support the cross product.
public class Vec3 {
  public float x, y, z;
  
  public Vec3(float x, float y, float z){
    this.x=x;this.y=y;this.z=z;
  }
  
  public String toString(){
    return "(" + x+ ", " + y + ", " + z +")";
  }
  
  public float length(){
    return sqrt(sq(x)+sq(y)+sq(z));
  }
  
  public Vec3 plus(Vec3 rhs){
    return new Vec3(x+rhs.x,y+rhs.y,z+rhs.z);
  }
  
  public void add(Vec3 rhs){
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }
  
  public Vec3 minus(Vec3 rhs){
    return new Vec3(x-rhs.x,y-rhs.y,z-rhs.z);
  }
  
  public void subtract(Vec3 rhs){
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }
  
  public Vec3 times(float rhs){
    return new Vec3(x*rhs,y*rhs,z*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }
  
  public void normalize(){
    float temp = this.length();
    if (temp != 0.0) {
      x /= temp;
      y /= temp;
      z /= temp;
    }
  }
  
  public Vec3 normalized(){
    float temp = this.length();
    if (temp != 0.0) {
      return new Vec3(x/temp,y/temp,z/temp);
    } else {
      return new Vec3(x,y,z);
    }
  }
  
  public float distanceTo(Vec3 rhs){
    return sqrt(sq(x-rhs.x)+sq(y-rhs.y)+sq(z-rhs.z));
  }
}

Vec3 interpolate(Vec3 a, Vec3 b, float t){
  return new Vec3(interpolate(a.x,b.x,t),interpolate(a.y,b.y,t),interpolate(a.z,b.z,t)); 
}

float dot(Vec3 a, Vec3 b){
  return a.x*b.x+a.y*b.y+a.z*b.z;
}

Vec3 cross(Vec3 a, Vec3 b){
  return new Vec3(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x);
}

Vec3 projAB(Vec3 a, Vec3 b){
  float temp1,temp;
  temp1 = sq(b.length());
  if (temp1 == 0){
    return b;
  } else {
    temp = dot(a,b)/sq(b.length());
    return new Vec3(temp*b.x, temp*b.y,temp*b.z);
  }
}
