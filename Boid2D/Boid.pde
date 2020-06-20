static float boidHeight = 20.0;
static float boidWidth = 12.0;
static float perceptionRadius = 60;
static float perceptionAngle = PI*1.5;
static float separationRadius = 20;
static float alignFactor = 60; //2
static float cohesionFactor = 2; //4
static float maxForce = 20; //10
static float targetSpeed = 15; //10 
static float COR = 0.7; //bounce factor
static float dt = .1;
static float obstaclePerceptionR = 150;
static float maxSpeed = 20; //10

class Boid{
  Vec2 pos;
  Vec2 vel;
  Vec2 acc;
  
  Boid(){
    this.pos = new Vec2(width/2+random(-width/6, width/6), height/2+random(-height/8, height/8));
    this.vel = new Vec2(random(-1,1),random(-1,1));
    this.vel.setToLength(maxSpeed);
    this.acc = new Vec2(0,0);
  }
  
  void show(){
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-(float)atan2(vel.x, vel.y));
    stroke(0);
    fill(0);
    triangle(boidWidth/2.0, -boidHeight/2.0, 0, boidHeight/2.0,-boidWidth/2.0,-boidHeight/2.0);    
    popMatrix();
  }
  
  ArrayList getNeighbors(ArrayList flock){
    ArrayList neighbors = new ArrayList();
    Vec2 dPos;
    
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
    Vec2 dPos;
    Vec2 avgVel = new Vec2(0,0), avgPos = new Vec2(0,0);
    Vec2 alignForce = new Vec2(0,0), cohesionForce = new Vec2(0,0), separationForce = new Vec2(0,0);
    Vec2 tempf = new Vec2(0,0);
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
        separationForce.add(tempf);
      }
      
      avgVel.add(b.vel);
      avgPos.add(b.pos);
    }
    avgVel.mul(1/(nNeighbors-1));    
    alignForce = avgVel.minus(vel).normalized();
    alignForce = alignForce.times(alignFactor);
    alignForce.clampToLength(maxForce);
    //alignForce = alignForce.plus(alignForce.times(alignFactor));
    
    avgPos.mul(1/(nNeighbors-1));
    cohesionForce=avgPos.minus(pos).normalized();
    cohesionForce = cohesionForce.times(cohesionFactor);
    cohesionForce.clampToLength(maxForce);
    
    acc = separationForce.plus(cohesionForce).plus(alignForce);
    }
    //Goal Speed
    Vec2 targetVel = vel;
    targetVel.setToLength(targetSpeed);
    Vec2 goalSpeedForce = targetVel.minus(vel);
    goalSpeedForce.times(1);
    goalSpeedForce.clampToLength(maxForce);
    acc = acc.plus(goalSpeedForce);
    Vec2 randVec = new Vec2(random(-0.8,0.8),random(-0.8,0.8));
    acc.add(randVec.times(5.0)); //wander force
    vel = vel.plus(acc.times(dt));
    pos = pos.plus(vel.times(dt));
    acc.mul(0);
  }
  
  void adjustForBoundary(){
    if (pos.x < 0) pos.x += width;
    if (pos.x > width) pos.x -= width;
    if (pos.y < 0) pos.y += height;
    if (pos.y > height) pos.y -= height;  
  }
  
  void adjustForObstacleSphere(Vec2 p, float r){
    float d = pos.distanceTo(p);
    if (d < (r+obstaclePerceptionR) && interceptSphere(p, r)){
      //Vec2 normal = (pos.minus(p)).normalized();
      Vec2 sphereDirection = pos.minus(p).normalized();
      Vec2 velTowardsSphere = projAB(vel.plus(sphereVel),sphereDirection);
      Vec2 orthVec = new Vec2(1,-sphereDirection.x/sphereDirection.y);
      orthVec.normalize();
      orthVec.mul(pow(velTowardsSphere.length()/d*50,2));
      vel.add(orthVec); //solution
    }
    if (d < (r+boidHeight)){
      Vec2 normal = (pos.minus(p)).normalized();
      pos = p.plus(normal.times(r+boidHeight).times(1.01));
      Vec2 velNormal = normal.times(dot(vel,normal));
      vel.subtract(velNormal.times(1 + COR));
      vel.add(projAB(sphereVel,normal)); //solution
    }
  }
   
  Boolean interceptSphere(Vec2 p, float r) {
    float angleBoundary,d,vel2SphereAngle;    
    d = pos.distanceTo(p);
    angleBoundary = asin(r/d);
    //println("angleBoundary="+angleBoundary);
    vel2SphereAngle = angle(p.minus(pos),vel);
    //println("vel2SphereAngle="+vel2SphereAngle);
    if (vel2SphereAngle > angleBoundary) {
      return false;
    } else {
      return true;
    }
  }
}
