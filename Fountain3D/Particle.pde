class Particle {
  Vec3 loc;
  Vec3 ploc;
  Vec3 vel;
  Vec3 acc;
  float life = 195;
  Vec3 gravity = new Vec3(0.0,0.2,0.0);
  Particle() {
    acc = new Vec3(0,0,0);
    vel = new Vec3(random(-1.5,1.5),-20+random(0,0.5),random(-1.5,1.5)); 
    loc = new Vec3(width/2+random(-1,1),height-10+random(-1,1),width/2+random(-1,1));
  }
 
  void run() {
    update();
    display();
  }
 
  void update() {
    ploc = loc;
    vel.add(gravity);    
    loc = loc.plus(vel);
    life -= 1;
    acc.mul(0);
  }
 
  void display() {    
    strokeWeight(8);
    stroke(#0077be, life+60);
    point(loc.x,loc.y,loc.z);   
  }
 
  boolean done() {
    if (life < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
