//CSCI5611: Project 2 Part2-1
//Cloth implementation
//By Hailin Archer, 7/2/2020
//Flag image credit: https://pixabay.com/illustrations/american-flag-usa-flag-symbol-2144392/
import java.util.*;

Camera camera;

//Parameters
int numRows = 40;
int numCols = 40;
float spacing = 10;
float ks = 10; //spring constant
float kd = 12; //damping factor
float ka = 0.0001; //drag factor
float l0 = spacing; //rest length
float clothXStart = 600; //cloth position 600
float clothYStart = -300; 
float clothZStart = -800;
float dt = 1/frameRate;
float gravity = 0.025;
boolean dragEnable = true;
boolean lineDetectEnable = true;

//Sphere parameters
Vec3 spherePos = new Vec3(clothXStart+numCols*spacing*0.5+clothZStart,clothYStart+405,clothZStart+120);
Vec3 sphereVel = new Vec3(0,0,0);
float sphereRadius = 100;
float sphereSpeed = 100;
float COR = 0;
boolean jPressed = false;
boolean lPressed = false;
boolean iPressed = false;
boolean kPressed = false;
boolean uPressed = false;
boolean oPressed = false;
float kf = 0.9; //velocity loss factor due to friction with the ball

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
  surface.setTitle("My Cloth");
  setupClothNodes();
  img = loadImage("Flag1.png"); //MountRushmore1.png
  //backdrop = loadImage("MountRushmore1.png"); //not used due to rendering cost
}

void setupClothNodes(){
  for (int j=0; j< numCols; j++){
    for (int i=0; i<numRows; i++){
      pos[i][j]=new Vec3(clothXStart + spacing*j+clothZStart,clothYStart, clothZStart + spacing*i);
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
  //rotateY(PI/4);
  noStroke();
  textureMode(NORMAL);
  for (int i=0; i<numRows-1; i++){
    update(dt);     
    beginShape(TRIANGLE_STRIP);
    texture(img);
    for (int j=0; j< numCols-1; j++){      
      float x1 = pos[i][j].x;
      float y1 = pos[i][j].y;
      float z1 = pos[i][j].z;
      float u = map(j,0,numCols-1,0,1);
      float v1 = map(i,0,numRows-1,0,1);
      vertex(x1,y1,z1,u,v1);
      float x2 = pos[i+1][j].x;
      float y2 = pos[i+1][j].y;
      float z2 = pos[i+1][j].z;
      float v2= map(i+1,0,numRows-1,0,1);
      vertex(x2,y2,z2,u,v2);
    }
    endShape();
  }
  sphereUpdate(dt);
  noStroke();  
  pushMatrix();
  fill(#ff7400);//FF6347(red)ff7400(orange)
  translate(spherePos.x, spherePos.y, spherePos.z);
  sphere(sphereRadius);
  popMatrix();
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

  //Horizontal force
  temp = new Vec3(0,0,0);
  for (int j=0; j< numCols-1; j++){
    for (int i=0; i<numRows; i++){
      //Compute string length
      Vec3 e = pos[i][j+1].minus(pos[i][j]);
      float l = e.length();
      e.mul(1.0/l);
      float v1 = dot(vel[i][j],e);
      float v2 = dot(vel[i][j+1],e);
      float f_side = -ks*(l0-l)-kd*(v1-v2);
      temp = e.times(f_side*dt);
      vel_new[i][j].add(temp);
      vel_new[i][j+1].subtract(temp);
    }
  }

  //Drag force: To do only do calculation if velocity is bigger than some value
  if (dragEnable){
    temp = new Vec3(0,0,0);
    for (int i=1; i<numRows; i++){
      for (int j=0; j< numCols-1; j++){    
        Vec3 v_surface = vel[i][j].plus(vel[i-1][j+1]).plus(vel[i][j+1]).plus(vel[i-1][j]).times(0.25);
        Vec3 edge1 = pos[i-1][j+1].minus(pos[i][j]);
        Vec3 edge2 = pos[i-1][j].minus(pos[i][j+1]);
        Vec3 edgeCross = cross(edge1,edge2);
        Vec3 f_drag = edgeCross.times((dot(v_surface,edgeCross)*v_surface.length())/(2*edgeCross.length()));      
        temp = f_drag.times(dt*ka*0.25);
        vel_new[i][j].subtract(temp);
        vel_new[i-1][j+1].subtract(temp);
        vel_new[i][j+1].subtract(temp);
        vel_new[i-1][j].subtract(temp);
      }
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
        float windx = map(noise(xoff, yoff, zoff), 0, 1, -1, 1);
        float windy = map(noise(xoff+5000, yoff+5000, zoff), 0, 1, -0.5, 0);
        float windz = map(noise(xoff+3000, yoff+3000, zoff), 0, 1, 0, 3);
        Vec3 wind = new Vec3(windx, windy, windz);
        vel_new[i][j].add(wind.times(dt));
        yoff += 0.1;
      }
      xoff += 0.1;
    }
    zoff += 0.1;
  }

  //Add gravity and friction
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
      float posAdjustFactor = 1.01;
      float backoff = 2;
      if (lineDetectEnable) {
        if (i<numRows-1 && j<numCols-1){
        Vec3 l1 = pos[i+1][j].minus(pos[i][j]);
        Vec3 l2 = pos[i+1][j+1].minus(pos[i][j]);
        Vec3 l3 = pos[i][j+1].minus(pos[i][j]);
        float l1_len = l1.length();
        float l2_len = l2.length();
        float l3_len = l3.length();
        hitInfo hit1 = lineCircleIntesect(spherePos, sphereRadius, pos[i][j], l1.normalized(), l1_len, 9999);
        hitInfo hit2 = lineCircleIntesect(spherePos, sphereRadius, pos[i][j], l2.normalized(), l2_len, 9999);
        hitInfo hit3 = lineCircleIntesect(spherePos, sphereRadius, pos[i][j], l3.normalized(), l3_len, 9999);
        if ((hit1.hit && hit1.t>0) || (hit2.hit && hit2.t>0) || (hit3.hit && hit3.t>0)){
          Vec3 normal = pos[i][j].minus(spherePos);
          normal.normalize();
          pos[i][j] = spherePos.plus(normal.times(sphereRadius+backoff).times(posAdjustFactor));
          Vec3 velNormal = normal.times(dot(vel[i][j],normal));
          vel[i][j]=vel[i][j].minus(velNormal.times(1+COR)).times(kf);
          //vel[i][j].add(projAB(sphereVel,normal));
        }
        if (hit1.hit && hit1.t>0){
          Vec3 normal = pos[i+1][j].minus(spherePos);
          normal.normalize();
          pos[i+1][j] = spherePos.plus(normal.times(sphereRadius+backoff).times(posAdjustFactor));
          Vec3 velNormal = normal.times(dot(vel[i+1][j],normal));
          vel[i+1][j]=vel[i+1][j].minus(velNormal.times(1+COR)).times(kf);
          //vel[i+1][j].add(projAB(sphereVel,normal));
        }
        if (hit2.hit && hit2.t>0){
          Vec3 normal = pos[i+1][j+1].minus(spherePos);
          normal.normalize();
          pos[i+1][j+1] = spherePos.plus(normal.times(sphereRadius+backoff).times(posAdjustFactor));
          Vec3 velNormal = normal.times(dot(vel[i+1][j+1],normal));
          vel[i+1][j+1]=vel[i+1][j+1].minus(velNormal.times(1+COR)).times(kf);
          //vel[i+1][j+1].add(projAB(sphereVel,normal));
        }
        if (hit3.hit && hit3.t>0){
          Vec3 normal = pos[i][j+1].minus(spherePos);
          normal.normalize();
          pos[i][j+1] = spherePos.plus(normal.times(sphereRadius+backoff).times(posAdjustFactor));
          Vec3 velNormal = normal.times(dot(vel[i][j+1],normal));
          vel[i][j+1]=vel[i][j+1].minus(velNormal.times(1+COR)).times(kf);
          //vel[i][j+1].add(projAB(sphereVel,normal));
        }
        }
      }
      float d = spherePos.distanceTo(pos[i][j]);
      if (d<(sphereRadius+backoff)){
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
  if (key == 'i') iPressed = true;
  if (key == 'k') kPressed = true;
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
  if (key == 'i') iPressed = false;
  if (key == 'k') kPressed = false;
  if (key == 'u') uPressed = false;
  if (key == 'o') oPressed = false;
  if (key == 'b') bPressed = false;
}

void sphereUpdate(float dt){  
  sphereVel = new Vec3(0,0,0);
  if (jPressed) sphereVel.add(new Vec3(-sphereSpeed,0,0));
  if (lPressed) sphereVel.add(new Vec3(sphereSpeed,0,0));
  if (iPressed) sphereVel.add(new Vec3(0,-sphereSpeed,0));
  if (kPressed) sphereVel.add(new Vec3(0,sphereSpeed,0));
  if (uPressed) sphereVel.add(new Vec3(0,0,-sphereSpeed));
  if (oPressed) sphereVel.add(new Vec3(0,0,sphereSpeed));
  spherePos.add(sphereVel.times(dt));  
}
