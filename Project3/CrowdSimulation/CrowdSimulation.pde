//CSCI 5611 - Crowd Simulation - Hailin Archer

//Tuning parameters
static int maxNumAgents = 20;
int numAgents = 20;
float k_goal = 20;
float k_avoid = 250;
float agentRad = 30;
float goalSpeed = 100;
float maxSpeed = 200;

Camera camera;
float dt = 1/frameRate;

float zPosGlobal = -1500;
float xStart = -500;
float yStart = -400;
PShape p1,p2,p3,p4;
boolean toggle = true;
boolean scene1 = true, scene2 = false, scene3 = false;
//The agent states
Vec3[] agentPos = new Vec3[maxNumAgents];
Vec3[] agentVel = new Vec3[maxNumAgents];
Vec3[] agentAcc = new Vec3[maxNumAgents];

//The agent goals
Vec3[] startPos = new Vec3[maxNumAgents];
Vec3[] goalPos = new Vec3[maxNumAgents];

//previous rotation angle
float pAngle = 0;
float margin = 100; //scene margin

void setup(){
  size(1024,768,P3D);
  camera = new Camera();
  setStartAndGoal();
  p1 = loadShape("Male_Casual.obj");
  p2 = loadShape("Male_Shirt.obj");
  p3 = loadShape("Female_Casual.obj");
  p4 = loadShape("Male_LongSleeve.obj");
  
  //Set initial velocities to cary agents towards their goals
  for (int i = 0; i < numAgents; i++){
    agentVel[i] = goalPos[i].minus(agentPos[i]);
    if (agentVel[i].length() > 0)
      agentVel[i].setToLength(goalSpeed);
  }
}

//Return at what time agents 1 and 2 collide if they keep their current velocities
// or -1 if there is no collision.
float computeTTC(Vec3 pos1, Vec3 vel1, float radius1, Vec3 pos2, Vec3 vel2, float radius2){
  Vec3 relativeVel = vel1.minus(vel2);
   return rayCircleIntersectTime(pos2, radius1+radius2, pos1, relativeVel);
}

// Compute attractive forces to draw agents to their goals, 
// and avoidance forces to anticipatory avoid collisions
Vec3 computeAgentForces(int id){
  //TODO: Make this better
  Vec3 acc = new Vec3(0,0,0);
  Vec3 goalVel = goalPos[id].minus(agentPos[id]);
  if (goalVel.length() > goalSpeed) goalVel.setToLength(goalSpeed);
  Vec3 goalForce = (goalVel.minus(agentVel[id]));
  acc.add(goalForce.times(k_goal));
  
  if (goalVel.length() < 3) return acc;
 
  for (int i=0; i<numAgents; i++){
    if (i==id) continue;
    float ttc = computeTTC(agentPos[id], agentVel[id], agentRad, agentPos[i], agentVel[i], agentRad);
    if (ttc>0){
      Vec3 d = agentVel[id].times(ttc);
      Vec3 futurePos = agentPos[id].plus(d);
      Vec3 d2 = agentVel[i].times(ttc);
      Vec3 futurePos2 = agentPos[i].plus(d2);
      Vec3 futureRelPosVec = futurePos.minus(futurePos2).normalized();
      Vec3 avoidanceF = futureRelPosVec.times(k_avoid*(1/ttc));    
      acc.add(avoidanceF);
    }
  }
  return acc;
}
//Update agent positions & velocities based acceleration
void moveAgent(float dt){
  //Compute accelerations for every agents
  for (int i = 0; i < numAgents; i++){
    agentAcc[i] = computeAgentForces(i);
  }
  //Update position and velocity using (Eulerian) numerical integration
  for (int i = 0; i < numAgents; i++){
    agentVel[i].add(agentAcc[i].times(dt));
    agentVel[i].clampToLength(maxSpeed);
    agentPos[i].add(agentVel[i].times(dt));
  }
}

boolean paused = true;
void draw(){
  println("frameRate="+frameRate);
  camera.Update(dt);
  //Update agent if not paused
  if (!paused){
    moveAgent(1.0/frameRate);
  }
  
  background(#81c4ff);
  specular(120, 120, 180);  //Setup lights… 
  ambientLight(200,200,200);   //More light…
  lightSpecular(255,255,255); shininess(10);  //More light…
  directionalLight(220, 220, 255, -1, 1, -1); //More light…
  
  //draw a platform
  pushMatrix();
  stroke(150);
  strokeWeight(2);
  fill(#d3d3d3,100); //#567d46  #028a0f
  beginShape();
  vertex(-xStart+agentRad+margin, -yStart+agentRad+margin, zPosGlobal);
  vertex(xStart-agentRad-margin, -yStart+agentRad+margin, zPosGlobal);
  vertex(xStart-agentRad-margin, yStart-agentRad-margin, zPosGlobal);
  vertex(-xStart+agentRad+margin, yStart-agentRad-margin, zPosGlobal);
  endShape(CLOSE);
  popMatrix();
  
  //Draw orange goal rectangle
  fill(255,150,50);
  for (int i = 0; i < numAgents; i++){
    pushMatrix();
    noStroke();
    fill(255,150,50,100);
    translate(goalPos[i].x-10, goalPos[i].y-10,goalPos[i].z-30);
    box(20,20,5);
    popMatrix();
  }
  
  //Draw the agents
  fill(20,200,150);
  for (int i = 0; i < numAgents; i++){
    pushMatrix();
    noStroke();
    fill(20,200,150,50);
    translate(agentPos[i].x, agentPos[i].y,agentPos[i].z-agentRad);
    float curAngle =(float)atan2(agentVel[i].x, agentVel[i].y); 
    rotate(-curAngle);
    pAngle = curAngle;
    scale(agentRad);
    rotateZ(PI);
    rotateX(PI/2);
    switch (i % 4){
      case 1:  shape(p1); break;
  case 2:  shape(p2); break;
  case 3:  shape(p3); break;
  default:  shape(p4); break;
    }
    popMatrix();
  }
}

//Pause/unpause the simulation
void keyPressed(){
  camera.HandleKeyPressed();
  if (key == ' ') paused = !paused;
  if (key == 'r'){
    setStartAndGoal();
    paused = true;
    return;
  }
  if (key == '1'){
    scene1 = true;
    scene2 = false;
    scene3 = false;
    setStartAndGoal();
    paused = true;
    return;
  }
  if (key == '2'){
    scene1 = false;
    scene2 = true;
    scene3 = false;
    setStartAndGoal();
    paused = true;
    return;
  }
  if (key == '3'){
    scene1 = false;
    scene2 = false;
    scene3 = true;
    setStartAndGoal();
    paused = true;
    return;
  }
  if (key == 'o'){
    for (int i=0;i<numAgents;i++){
      agentPos[i]=new Vec3(startPos[i].x,startPos[i].y,startPos[i].z);
    }
    paused = true;
    return;
  }
}

void keyReleased(){
  camera.HandleKeyReleased();
}

//helper functions
void setStartAndGoal(){
  int factor = 4;
  if (scene1){
    int numElements = int((xStart*yStart*4)/(agentRad*factor*agentRad*factor))+10;
    Vec3[] potentialPos = new Vec3[numElements];
    final IntList nums = new IntList(numElements);
    int n=0;
    for (int i=int(xStart); i<int(-xStart);i+=agentRad*factor){
      for (int j=int(yStart); j<int(-yStart);j+=agentRad*factor){
        potentialPos[n] = new Vec3(float(i),float(j),0);
        nums.append(n);
        n++;
      }
    }
    nums.shuffle();
    n=0;
    for (int i=0;i<numAgents;i++){
      int curIdx = nums.get(n); n++;
      agentPos[i] = new Vec3(potentialPos[curIdx].x,potentialPos[curIdx].y,zPosGlobal+agentRad);
      startPos[i] = new Vec3(potentialPos[curIdx].x,potentialPos[curIdx].y,zPosGlobal+agentRad);
      curIdx = nums.get(n); n++;
      goalPos[i] = new Vec3(potentialPos[curIdx].x,potentialPos[curIdx].y,zPosGlobal+agentRad);
    }
  } 
  if (scene2) {
    int numElements = int((xStart*yStart*2)/(agentRad*factor*agentRad*factor))+10;
    Vec3[] potentialPos1 = new Vec3[numElements];
    Vec3[] potentialPos2 = new Vec3[numElements];
    final IntList nums1 = new IntList(numElements);
    final IntList nums2 = new IntList(numElements);
    int n=0;
    for (int i=int(xStart); i<0;i+=agentRad*factor){
      for (int j=int(yStart); j<int(-yStart);j+=agentRad*factor){
        potentialPos1[n] = new Vec3(float(i),float(j),0);
        nums1.append(n);
        n++;
      }
    }
    n=0;
    for (int i=0; i<int(-xStart);i+=agentRad*factor){
      for (int j=int(yStart); j<int(-yStart);j+=agentRad*factor){
        potentialPos2[n] = new Vec3(float(i),float(j),0);
        nums2.append(n);
        n++;
      }
    }
    nums1.shuffle();
    nums2.shuffle();
    n=0;
    for (int i=0;i<numAgents;i++){
      int curIdx1 = nums1.get(n);
      agentPos[i] = new Vec3(potentialPos1[curIdx1].x,potentialPos1[curIdx1].y,zPosGlobal+agentRad);
      startPos[i] = new Vec3(potentialPos1[curIdx1].x,potentialPos1[curIdx1].y,zPosGlobal+agentRad);
      int curIdx2 = nums2.get(n);
      goalPos[i] = new Vec3(potentialPos2[curIdx2].x,potentialPos2[curIdx2].y,zPosGlobal+agentRad);
      n++;
    }
  }
  if (scene3) {
    int numAgents1 = numAgents/2, numAgents2 = numAgents1;
    float deltaX = -xStart/numAgents*4+2, deltaY = -yStart/numAgents*4;
    for (int i=0;i<numAgents1;i++){
      agentPos[i] = new Vec3(xStart+deltaX*i,yStart,zPosGlobal+agentRad);
      startPos[i] = new Vec3(xStart+deltaX*i,yStart,zPosGlobal+agentRad);
      goalPos[i] = new Vec3(xStart+deltaX*i,-yStart,zPosGlobal+agentRad);
    }
    for (int i=numAgents1;i<numAgents;i++){
      //goalPos[i] = new Vec3(xStart+deltaX*(i-numAgents1),yStart,zPosGlobal+agentRad);
      //agentPos[i] = new Vec3(xStart+deltaX*(i-numAgents1),-yStart,zPosGlobal+agentRad);
      agentPos[i] = new Vec3(xStart,yStart+deltaY*(i-numAgents1),zPosGlobal+agentRad);
      startPos[i] = new Vec3(xStart,yStart+deltaY*(i-numAgents1),zPosGlobal+agentRad);
      goalPos[i] = new Vec3(-xStart,yStart+deltaY*(i-numAgents1),zPosGlobal+agentRad);
    }
  }
}
