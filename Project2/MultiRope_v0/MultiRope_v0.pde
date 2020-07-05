//CSCI5611: Project 2 Part2-1
//Cloth implementation
//By Hailin Archer, 7/4/2020
import java.util.*;

Camera camera;

//Parameters
int numRows = 12;
int numCols = 5;
float ballSize = 10;
float spacing = 100;
float ks = 10; //spring constant
float kd = 12; //damping factor
float ka = 0.0001; //drag factor
float l0 = 30; //rest length
float clothXStart = 1400; //cloth position 600
float clothYStart = -300; 
float clothZStart = -800;
float dt = 1/frameRate;
float gravity = 0.9;
boolean dragEnable = true;
boolean lineDetectEnable = true;

float floor= 220;

//Sphere parameters
float sphereRadius = 100;
Vec3 spherePos = new Vec3(clothXStart+numCols*spacing*0.5+clothZStart,floor-sphereRadius,clothZStart-120);
Vec3 sphereVel = new Vec3(0,0,0);
float sphereSpeed = 100;
float COR = 0;
boolean jPressed = false;
boolean lPressed = false;
//boolean iPressed = false;
//boolean kPressed = false;
boolean uPressed = false;
boolean oPressed = false;
float kf = 1; //velocity loss factor due to friction with the ball

//Enable wind
boolean bPressed = false;

PImage img;
//PImage backdrop;

Vec3[][] pos = new Vec3[numRows][numCols];
Vec3[][] vel = new Vec3[numRows][numCols];
Vec3[][] acc = new Vec3[numRows][numCols];

void setup(){
  size(1657,1440,P3D);
  camera = new Camera();
  surface.setTitle("Multi Balls");
  setupClothNodes();
}

void setupClothNodes(){
  for (int j=0; j< numCols; j++){
    float c=random(-20,20);
    for (int i=0; i<numRows; i++){
      pos[i][j]=new Vec3(clothXStart + spacing*j+clothZStart,clothYStart+l0*i, clothZStart+c*i);
      vel[i][j] = new Vec3(0,0,0);
    }
  }
}

void draw(){
  background(#77b5fe); //#77b5fe#87ceeb
  camera.Update(dt);
  specular(120, 120, 180);  //Setup lights… 
  ambientLight(90,90,90);   //More light…
  lightSpecular(255,255,255); shininess(10);  //More light…
  directionalLight(200, 200, 200, -1, 1, -1); //More light…
  fill(#008080);
  rotateY(PI/4);  
  noStroke();
  for (int j=0; j< numCols; j++){ 
    update(0.02);
    for (int i=0; i<numRows-1; i++){      
      pushMatrix();
      noStroke();
      fill(#d4af37);//FF6347(red)
      translate(pos[i+1][j].x,pos[i+1][j].y,pos[i+1][j].z);
      sphere(ballSize);
      popMatrix();
      strokeWeight(5);
      stroke(#d4af37);
      line(pos[i][j].x,pos[i][j].y,pos[i][j].z,pos[i+1][j].x,pos[i+1][j].y,pos[i+1][j].z);
    }

  }
  sphereUpdate(dt);
  noStroke();  
  pushMatrix();
  fill(#ff7400);//FF6347(red)ff7400(orange)
  translate(spherePos.x, spherePos.y, spherePos.z);
  sphere(sphereRadius);
  popMatrix();
  fill(51);
  beginShape();
  vertex(-width, floor, -width);
  vertex(width, floor, -width);
  vertex(width, floor, width);
  vertex(-width, floor, width);
  endShape(CLOSE);  
  println("frameRate="+frameRate);
}

void update(float dt){  
  Vec3[][] vel_new = new Vec3[numRows][numCols];
  Vec3 temp = new Vec3(0,0,0);
  arrayCopy(vel, vel_new);
  //Downward force
  for (int j=0; j< numCols; j++){
    for (int i=0; i<numRows-1; i++){
      //Compute string length
      Vec3 e = pos[i+1][j].minus(pos[i][j]);
      float l = e.length();
      e.mul(1.0/l);
      float v1 = dot(vel[i][j],e);
      float v2 = dot(vel[i+1][j],e);
      float f_down = -ks*(l0-l)-kd*(v1-v2);
      temp = e.times(f_down*dt);
      vel_new[i][j].add(temp);
      vel_new[i+1][j].subtract(temp);
    }
  }

  //Add wind
  if (bPressed){
    float xoff = 0;
    float zoff = 0;
    for (int j = 0; j < numCols; j++) {
      float yoff = 0;
      for (int i = 0; i < numRows; i++) {
        float n = noise(xoff, yoff);
        //particles[i][j].display();
        float windx = map(noise(xoff, yoff, zoff), 0, 1, -5, 5);
        float windy = map(noise(xoff+5000, yoff+5000, zoff), 0, 1, -5, 0);
        float windz = map(noise(xoff+3000, yoff+3000, zoff), 0, 1, 0, 30);
        Vec3 wind = new Vec3(windx, windy, windz);
        vel_new[i][j].add(wind.times(dt));
        yoff += 0.1;
      }
      xoff += 0.1;
    }
    zoff += 0.1;
  }

  //Add gravity
  for (int j=0; j< numCols; j++){
    for (int i=0; i<numRows; i++){
      vel_new[i][j].y += gravity;
    }
  }
  
  //Fix top
  for (int j=0; j< numCols; j++){
    vel_new[0][j] = new Vec3(0,0,0);
  }
  //Update position
  arrayCopy(vel_new,vel);
  for (int j=0; j< numCols; j++){
    for (int i=0; i<numRows; i++){
      pos[i][j] = pos[i][j].plus(vel[i][j].times(dt));
    }
  }
  
  //detect collision
  for (int i=0;i<numRows;i++){
    for (int j=0;j<numCols;j++){
      if ((pos[i][j].y+ballSize)>floor){
        vel[i][j].y *= -.9;
        vel[i][j].mul(1); //slow down on the floor
        pos[i][j].y = floor - ballSize;
      }
      for (int ii=3;ii<numRows;ii++){
        for (int jj=3;jj<numCols;jj++){
          if ((ii!=i && jj!=j) && (pos[i][j].minus(pos[ii][jj]).length()<=ballSize)){
            Vec3 normal = pos[i][j].minus(pos[ii][jj]);
            normal.normalize();
            pos[i][j] = pos[ii][jj].plus(normal.times(ballSize*2).times(1.01));
            Vec3 velNormal = normal.times(dot(vel[i][j],normal));
            vel[i][j]=vel[i][j].minus(velNormal.times(1+COR)).times(kf);
          }
        }
      }
      
      float posAdjustFactor = 1.0001;
      float backoff = ballSize;
      if (lineDetectEnable) {
        if (i<numRows-1 && j<numCols-1){
        Vec3 l1 = pos[i+1][j].minus(pos[i][j]);
        float l1_len = l1.length();
        hitInfo hit1 = lineCircleIntesect(spherePos, sphereRadius, pos[i][j], l1.normalized(), l1_len, 9999);
        if ((hit1.hit && hit1.t>0)){
          Vec3 normal = pos[i][j].minus(spherePos);
          normal.normalize();
          pos[i][j] = spherePos.plus(normal.times(sphereRadius+backoff).times(posAdjustFactor));
          Vec3 velNormal = normal.times(dot(vel[i][j],normal));
          vel[i][j]=vel[i][j].minus(velNormal.times(1+COR)).times(kf);
          //vel[i][j].add(projAB(sphereVel,normal));
          normal = pos[i+1][j].minus(spherePos);
          normal.normalize();
          pos[i+1][j] = spherePos.plus(normal.times(sphereRadius+backoff).times(posAdjustFactor));
          velNormal = normal.times(dot(vel[i+1][j],normal));
          vel[i+1][j]=vel[i+1][j].minus(velNormal.times(1+COR)).times(kf);
          //vel[i+1][j].add(projAB(sphereVel,normal));
        }
        }
      }
      float d = spherePos.distanceTo(pos[i][j]);
      if (d<(sphereRadius+ballSize)){
        Vec3 normal = pos[i][j].minus(spherePos);
        normal.normalize();
        pos[i][j] = spherePos.plus(normal.times(sphereRadius+backoff).times(posAdjustFactor));
        Vec3 velNormal = normal.times(dot(vel[i][j],normal));
        vel[i][j]=vel[i][j].minus(velNormal.times(1+COR)).times(kf);
        //vel[i][j].add(projAB(sphereVel,normal));
      }
    }
  } 
}

void keyPressed()
{
  camera.HandleKeyPressed();
  if (key == 'j') jPressed = true;
  if (key == 'l') lPressed = true;
  //if (key == 'i') iPressed = true;
  //if (key == 'k') kPressed = true;
  if (key == 'u') uPressed = true;
  if (key == 'o') oPressed = true;
  if (key == 'b') bPressed = true;
}

void keyReleased()
{
  camera.HandleKeyReleased();
  if (key == 'r'){
    println("Reseting the System");
    setupClothNodes();
  }
  if (key == 'j') jPressed = false;
  if (key == 'l') lPressed = false;
  //if (key == 'i') iPressed = false;
  //if (key == 'k') kPressed = false;
  if (key == 'u') uPressed = false;
  if (key == 'o') oPressed = false;
  if (key == 'b') bPressed = false;
}

void sphereUpdate(float dt){  
  sphereVel = new Vec3(0,0,0);
  if (jPressed) sphereVel.add(new Vec3(-sphereSpeed,0,0));
  if (lPressed) sphereVel.add(new Vec3(sphereSpeed,0,0));
  //if (iPressed) sphereVel.add(new Vec3(0,-sphereSpeed,0));
  //if (kPressed) sphereVel.add(new Vec3(0,sphereSpeed,0));
  if (uPressed) sphereVel.add(new Vec3(0,0,-sphereSpeed));
  if (oPressed) sphereVel.add(new Vec3(0,0,sphereSpeed));
  spherePos.add(sphereVel.times(dt));  
}
