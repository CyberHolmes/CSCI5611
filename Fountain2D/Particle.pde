class Particle {
  Vec2 loc;
  Vec2 ploc;
  Vec2 vel;
  Vec2 acc;
  float life = 200;
  Vec2 gravity = new Vec2(0.0,0.15);
  Particle() {
    acc = new Vec2(0,0);
    vel = new Vec2(random(-1,1),-15+random(0.5)); 
    loc = new Vec2(width/2-128+random(-1,1),height-245+random(-1,1));
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
    stroke(#ADD8E6,life+50); 
    point(loc.x,loc.y); 
  }
 
  boolean done() {
    if (life < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
