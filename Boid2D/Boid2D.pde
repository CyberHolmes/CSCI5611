//import java.util.*;
ArrayList flock;
int nBoids = 150;
PImage scene, tree1, tree2;
Vec2 spherePos = new Vec2(500,500);
Vec2 sphere2Pos = new Vec2(1000,500);
float sphereRadius = 100;
float sphere2Radius = 150;
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
  //fill(#ff4500);
  //sphereUpdate(1.0/frameRate);
  //circle(spherePos.x, spherePos.y, sphereRadius*2);
  //fill(#c0c0c0);
  //circle(sphere2Pos.x, sphere2Pos.y, sphere2Radius*2);
  //Iterator<Boid> it = flock.iterator();
  
  pushMatrix();
  beginShape();
  translate(spherePos.x-100, spherePos.y-100);

  texture(tree1);
  image(tree1,0,0);
  tint(255,255);
  // vertex( x, y, z, u, v) where u and v are the texture coordinates in pixels
  vertex(-sphereRadius, -sphereRadius, -sphereRadius, -sphereRadius);//-tree1.width/2,- tree1.width/2);
  vertex(sphereRadius, -sphereRadius, sphereRadius, -sphereRadius);//tree1.width/2, -tree1.height/2);
  vertex(sphereRadius, sphereRadius, sphereRadius, sphereRadius);//tree1.width/2, tree1.height/2);
  vertex(-sphereRadius, sphereRadius, -sphereRadius, sphereRadius);//-tree1.height/2, tree1.height/2);
  endShape();
  popMatrix();
  sphereUpdate(1.0/frameRate);
  pushMatrix();
  beginShape();
  translate(sphere2Pos.x-150, sphere2Pos.y-150);
  texture(tree2);
  image(tree2,0,0);
  tint(255,255);
  vertex(-sphere2Radius, -sphere2Radius, -sphere2Radius, -sphere2Radius);
  vertex(sphere2Radius, -sphere2Radius, sphere2Radius, -sphere2Radius);
  vertex(sphere2Radius, sphere2Radius, sphere2Radius, sphere2Radius);
  vertex(-sphere2Radius, sphere2Radius, -sphere2Radius, sphere2Radius);
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
    spherePos.x=900;spherePos.y=150;
  }
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) upPressed = false; 
  if (keyCode == DOWN) downPressed = false;
  if (keyCode == SHIFT) {shiftPressed = false;obstacleSpeed = 200;};
}
