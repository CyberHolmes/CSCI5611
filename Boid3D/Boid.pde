static float boidHeight = 20.0;
static float boidWidth = 12.0;
static float perceptionRadius = 120;
static float perceptionAngle = PI*1.5;
static float separationRadius = 60;
static float alignFactor = 30; //2
static float cohesionFactor = 20; //4
static float maxForce = 200; //10
static float targetSpeed = 25; //10 
static float COR = 1; //bounce factor
static float dt = .1;
static float maxSpeed = 30; //10
Vec3 origin = new Vec3(0,0,0);
float a = boidHeight;


class Boid{
  Vec3 pos;
  Vec3 vel;
  Vec3 acc;
  
  Boid(){
    //this.pos = new Vec3(width/2+random(-width/6, width/6), height/2+random(-height/8, height/8),width/2+random(-width/6, width/6));
    this.pos = new Vec3(random(width),random(height),random(width));
    this.vel = new Vec3(random(-10,10),random(-10,10),random(-10,10));
    
    this.vel.setToLength(maxSpeed);
    this.acc = new Vec3(0,0,0);    
  }
  
  void show(){
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    Vec3 angleToRotate = angle(vel);
    rotateX(-angleToRotate.x);
    rotateY(-angleToRotate.y);
    rotateZ(-angleToRotate.z);
    stroke(255);
    fill(255,255,255);
    triangle(boidWidth/2.0, -boidHeight/2.0, 0, boidHeight/2.0,-boidWidth/2.0,-boidHeight/2.0); 
    beginShape();
    vertex(-a, -a, -a);
    vertex( a, -a, -a);
    vertex(0, 0, a);

    vertex( a, -a, -a);
    vertex( a,  a, -a);
    vertex(   0,    0,  a);

    vertex( a, a, -a);
    vertex(-a, a, -a);
    vertex(   0,   0,  a);

    vertex(-a,  a, -a);
    vertex(-a, -a, -a);
    vertex(   0,    0,  a);
    endShape();
    popMatrix();
  }
  
  ArrayList getNeighbors(ArrayList flock){
    ArrayList neighbors = new ArrayList();
    Vec3 dPos;
    
    for (int i=0; i<flock.size(); i++){
      Boid b = (Boid)flock.get(i);
      if (b == this) continue;
      dPos = pos.minus(b.pos);
      if (dPos.length()>perceptionRadius) continue;   
      if (angle(vel,dPos)>perceptionAngle) continue;
      neighbors.add(b);
    }
    return neighbors;
  }
  
  void update(ArrayList neighbors){
    Vec3 dPos;
    Vec3 avgVel = new Vec3(0,0,0), avgPos = new Vec3(0,0,0);
    Vec3 alignForce = new Vec3(0,0,0), cohesionForce = new Vec3(0,0,0), separationForce = new Vec3(0,0,0);
    Vec3 tempf = new Vec3(0,0,0);
    
    Vec3 steerAngle = new Vec3(0,0.1,0);
    boolean collision = false;
    int nNeighbors = neighbors.size();
    if (nNeighbors > 1) {
      for (int i=0; i<nNeighbors; i++){
        Boid b = (Boid)neighbors.get(i);
        dPos = pos.minus(b.pos);
      
        float dPosMag = dPos.length();
      
        if (dPosMag < separationRadius) {
          tempf = dPos.normalized();
          if (dPosMag < boidHeight*1.2) {
            tempf.setToLength(1000.0/pow(dPosMag,2));
          } else {
            tempf.setToLength(400.0/pow(dPosMag,2));
          }
          if (dPosMag < boidHeight*1.2) {
              collision = true;
          }
            //tempf.setToLength(400.0/pow(dPosMag,2));
            if (abs(angle(vel,b.vel)-PI)<0.01) vel.plus(steerAngle);
            separationForce.add(tempf);
        } 
        if (!collision) {
          avgVel = avgVel.plus(b.vel);
          avgPos = avgPos.plus(b.pos);
        }
      }

      avgVel.mul(1/(nNeighbors-1));    
      alignForce = avgVel.minus(vel).normalized();
      alignForce = alignForce.times(alignFactor);
    
      //alignForce = alignForce.plus(alignForce.times(alignFactor));
      alignForce.clampToLength(maxForce);
    
      avgPos = avgPos.times(1/(nNeighbors-1));
      cohesionForce=avgPos.minus(pos).normalized();
      cohesionForce = cohesionForce.times(cohesionFactor);
      cohesionForce.clampToLength(maxForce);
    
      acc = separationForce.plus(cohesionForce).plus(alignForce);
    }
    //Goal Speed
    Vec3 targetVel = vel;
    targetVel.setToLength(targetSpeed);
    Vec3 goalSpeedForce = targetVel.minus(vel);
    goalSpeedForce.times(1);
    goalSpeedForce.clampToLength(maxForce);
    acc = acc.plus(goalSpeedForce);
    Vec3 randVec = new Vec3(random(-0.8,0.8),random(-0.8,0.8),random(-0.8,0.8));
    acc.add(randVec.times(5.0)); //wander force
    if (Float.isNaN(acc.x)) exit();
    vel = vel.plus(acc.times(dt));
    vel.clampToLength(maxSpeed);
    pos = pos.plus(vel.times(dt));
    if (Float.isNaN(pos.x)) exit();
    acc.mul(0);
  }
  
  void adjustForBoundary(){
    if (pos.y > height){
      pos.y = height;
      vel.y *= -COR;
    }
    if (pos.y < a){
      pos.y = a;
      vel.y *= -COR;
    }
    if (pos.x > width-a){
      pos.x = width-a;
      vel.x *= -COR;
    }
    if (pos.x < a){
      pos.x = a;
      vel.x *= -COR;
    }
    if (pos.z > width-a){
      pos.z = width-a;
      vel.z *= -COR;
    }
    if (pos.z < a){
      pos.z = a;
      vel.z *= -COR;
    }
    vel.clampToLength(maxSpeed);
  }
}
