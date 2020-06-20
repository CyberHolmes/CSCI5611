// Boid Simulation: CSCI5611 Project 1
// By Hailin Archer 6/15/2020
// Scene image: unsplash.com
// Tree image: pluspng.com

ArrayList flock;
int nBoids = 300;
PImage scene, tree1, tree2;
Vec2 spherePos = new Vec2(500,500);
Vec2 sphere2Pos = new Vec2(1000,500);
float sphereRadius = 100;
float sphere2Radius = 140;
float obstacleSpeed = 200;
Vec2 sphereVel = new Vec2(0,0);
boolean leftPressed, rightPressed, upPressed, downPressed, shiftPressed;

void setup(){
  size(1500,1000);
  smooth();  
  flock = new ArrayList();
  for (int i=0; i<nBoids; i++){
    flock.add(new Boid());    
  }  
  scene = loadImage("img2.jpg");
  tree1 = loadImage("TreeTop4.png");
  tree2 = loadImage("TreeTop5.png");
}

void draw(){  
  background(scene);
  noStroke();
  println("frameRate="+frameRate);
  println("numBoids="+flock.size());
  sphereUpdate(1.0/frameRate);
  pushMatrix();
  translate(spherePos.x-sphereRadius, spherePos.y-sphereRadius);
  image(tree1,0,0);
  tint(255,255);
  popMatrix();
  
  pushMatrix();
  translate(sphere2Pos.x-sphere2Radius, sphere2Pos.y-sphere2Radius);
  image(tree2,0,0);
  tint(255,255);
  popMatrix();  
  
  for (int i=0; i<flock.size(); i++){
    Boid b = (Boid)flock.get(i);
    b.update(b.getNeighbors(flock));
    b.adjustForBoundary();
    b.adjustForObstacleSphere(spherePos, sphereRadius);
    b.adjustForObstacleSphere(sphere2Pos, sphere2Radius);
    b.show();    
  }
}

void sphereUpdate(float dt){  
  sphereVel = new Vec2(0,0);
  if (leftPressed) sphereVel.add(new Vec2(-obstacleSpeed,0));
  if (rightPressed) sphereVel.add(new Vec2(obstacleSpeed,0));
  if (upPressed) sphereVel.add(new Vec2(0,-obstacleSpeed));
  if (downPressed) sphereVel.add(new Vec2(0,obstacleSpeed));
  if (sphereVel.length() > 0.0){
    sphereVel = sphereVel.normalized();
    sphereVel.mul(obstacleSpeed*(shiftPressed?2:1));
  }  
  spherePos.add(sphereVel.times(dt));  
  spherePos.x = max(sphereRadius, spherePos.x);
  spherePos.x = min(spherePos.x, width-sphereRadius);  
  spherePos.y = max(sphereRadius, spherePos.y);
  spherePos.y = min(spherePos.y, height-sphereRadius);  
}

void keyPressed(){
  if (keyCode == LEFT) leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (keyCode == UP) upPressed = true; 
  if (keyCode == DOWN) downPressed = true;
  if (keyCode == SHIFT) {shiftPressed = true;obstacleSpeed = 400;};
}

void keyReleased(){
  if (key == 'r'){
    println("Reseting the System");
    spherePos.x=500;spherePos.y=500;
    for (int i = flock.size() - 1; i >= 0; i--) {
        flock.remove(i);
    }
    for (int i=0; i<nBoids; i++){
      flock.add(new Boid());    
    }
  }
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) upPressed = false; 
  if (keyCode == DOWN) downPressed = false;
  if (keyCode == SHIFT) {shiftPressed = false;obstacleSpeed = 200;};
}
