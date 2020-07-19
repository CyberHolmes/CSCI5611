//CSCI 5611 - Graph Search & Planning
//Hailin Archer

boolean showPath = false;
boolean noPath = false;
PFont f;
float zPosGlobal = -1500;
float xStart = -500;
float yStart = -400;
PShape tree,house,p1,p2,p3,p4;
boolean toggle = true;

Camera camera;
float dt = 1/frameRate;

//Change the below parameters to change the scenario/roadmap size
int numObstacles = 10;
int numNodes  = 80;
    
//A list of circle obstacles
static int maxNumObstacles = 1000;
float maxCircleRad = 40;
float minCircleRad = 30;
Vec3 circlePos[] = new Vec3[maxNumObstacles]; //Circle positions
float circleRad[] = new float[maxNumObstacles];  //Circle radii

//A box obstacle
float boxW = 100;
float boxH = 100;
Vec3 boxTopLeft = new Vec3(xStart+500,yStart+400,zPosGlobal+boxH);

//The agent we are controlling
int numAgents = 4;
boolean paused = true;
float agentRad = 30;
Vec3[] agentPos = new Vec3[numAgents]; 
Vec3[] agentVel = new Vec3[numAgents]; 
Vec3[] agentAcc = new Vec3[numAgents];
float goalSpeed = 90;
int[] curNode = new int[numAgents];
Vec3[] nextTarget = new Vec3[numAgents]; 
float margin = 5;
float k_goal = 40; 
float k_avoid = 350;
float maxSpeed = 200;

float goalSize = 10;
Vec3[] startPos = new Vec3[numAgents];
Vec3[] goalPos = new Vec3[numAgents];

ArrayList<Integer>[] path = new ArrayList[numAgents];

static int maxNumNodes = 1000;
Vec3[] nodePos = new Vec3[maxNumNodes];

//Generate non-colliding PRM nodes
void generateRandomNodes(int numNodes, Vec3[] circleCenters, float[] circleRadii){
  for (int i = 0; i < numNodes; i++){
    Vec3 randPos = new Vec3(random(xStart,xStart+width),random(yStart,yStart+height),zPosGlobal);
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos);
    boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    while (insideAnyCircle || insideBox){
      randPos = new Vec3(random(xStart,xStart+width),random(yStart,yStart+height),zPosGlobal);
      insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos);
      insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    }
    nodePos[i] = randPos;
  }
}

void placeRandomObstacles(int numObstacles){
  //Initial obstacle position
  for (int i = 0; i < numObstacles; i++){
    circleRad[i] = random(minCircleRad,maxCircleRad);
    Vec3 randPos = new Vec3(random(xStart+50,xStart+950),random(yStart+50,yStart+700),zPosGlobal+circleRad[i]);
    boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    while (insideBox) {
      randPos = new Vec3(random(xStart+50,xStart+950),random(yStart+50,yStart+700),zPosGlobal+circleRad[i]);
      insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    }
    circlePos[i] = new Vec3(randPos.x,randPos.y,randPos.z);
  }
}

int strokeWidth = 2;
void setup(){
  size(1024,768,P3D);
  camera = new Camera();
  generateCourse();
  generatePRM();
  f = loadFont("Cambria-Bold-48.vlw");
  tree = loadShape("tree1.obj");
  house = loadShape("Silo.obj");
  p1 = loadShape("Female_Dress.obj");
  p2 = loadShape("Male_Shirt.obj");
  p3 = loadShape("Female_Casual.obj");
  p4 = loadShape("Male_LongSleeve.obj");
}

Vec3 computeAgentVel(int id){
  
  return nextTarget[id].minus(agentPos[id]).normalized().times(goalSpeed);
}
void moveAgent(float dt){
  for (int i=0; i<numAgents; i++){
    Vec3 dir = goalPos[i].minus(agentPos[i]);
    float dist = agentPos[i].distanceTo(goalPos[i]);
    hitInfo clide = rayCircleListIntersect(circlePos, circleRad, numObstacles, agentPos[i], dir.normalized(), dist); 
    if (!clide.hit || path[i].size()<2) {
      nextTarget[i] = new Vec3(goalPos[i].x,goalPos[i].y,goalPos[i].z);
    } else {
      if ((curNode[i]+1)<path[i].size()-1){
        Vec3 temp = nodePos[path[i].get(curNode[i]+1)];
        dir = temp.minus(agentPos[i]);
        dist = agentPos[i].distanceTo(temp);
        hitInfo clide2 = rayCircleListIntersect(circlePos, circleRad, numObstacles, agentPos[i], dir.normalized(), dist); 
        if (!clide2.hit) {
          curNode[i]++;
        }
      }
          nextTarget[i] = new Vec3(nodePos[path[i].get(curNode[i])].x,nodePos[path[i].get(curNode[i])].y,nodePos[path[i].get(curNode[i])].z);
    }
    if (agentPos[i].distanceTo(nextTarget[i])<2 && curNode[i]<path[i].size()-1) {
      curNode[i]++; //paused = true;
    }
  agentAcc[i] = computeAgentForces(i);
  agentVel[i].add(agentAcc[i].times(dt));
  agentVel[i].clampToLength(maxSpeed);
  if (agentPos[i].distanceTo(nextTarget[i])>2)agentPos[i].add(agentVel[i].times(dt));
  }
  
}
Vec3 sampleFreePos(){
  Vec3 randPos = new Vec3(random(xStart,xStart+width),random(yStart,yStart+height),zPosGlobal);
  boolean insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos);
  boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
  while (insideAnyCircle || insideBox){
    randPos = new Vec3(random(xStart,xStart+width),random(yStart,yStart+height),zPosGlobal);
    insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos);
    insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
  }
  return randPos;
}

void generateCourse(){

  placeRandomObstacles(numObstacles);
  
  startPos[0] = new Vec3(xStart, yStart, zPosGlobal); 
  goalPos[0] = new Vec3(-xStart, -yStart, zPosGlobal+goalSize);
  startPos[1] = new Vec3(xStart, -yStart, zPosGlobal); 
  goalPos[1] = new Vec3(-xStart, yStart, zPosGlobal+goalSize);
  startPos[2] = new Vec3(-xStart, yStart, zPosGlobal); 
  goalPos[2] = new Vec3(xStart, -yStart, zPosGlobal+goalSize);
  startPos[3] = new Vec3(-xStart, -yStart, zPosGlobal); 
  goalPos[3] = new Vec3(xStart, yStart, zPosGlobal+goalSize);
  
  agentVel[0] = new Vec3(200,40,zPosGlobal+agentRad*2);
  agentVel[1] = new Vec3(200,40,zPosGlobal+agentRad*2);
  agentVel[2] = new Vec3(200,40,zPosGlobal+agentRad*2);
  agentVel[3] = new Vec3(200,40,zPosGlobal+agentRad*2); 

  generateRandomNodes(numNodes, circlePos, circleRad);    
}

void generatePRM(){
  for (int i=0; i<numAgents; i++){
  agentPos[i] = new Vec3(startPos[i].x, startPos[i].y, startPos[i].z);  
  curNode[i]=1;
  path[i] = planPath(startPos[i], goalPos[i], circlePos, circleRad, numObstacles, nodePos, numNodes);
  if (path[i].size() == 1 && path[i].get(0) == -1){
    noPath = true;
  } else { noPath = false;}
  }
}

void nevigate(){   
  //Update agent if not paused
  if (!paused){
    moveAgent(1.0/frameRate); 
  }
}

void draw(){
  println("FrameRate:",frameRate);
  camera.Update(dt);
  background(0);
  specular(120, 120, 180);  //Setup lights… 
  ambientLight(200,200,200);   //More light…
  lightSpecular(255,255,255); shininess(10);  //More light…
  directionalLight(220, 220, 255, -1, 1, -1); //More light…
  
  //draw a platform
  pushMatrix();
  stroke(255);
  strokeWeight(3);
  fill(#028a0f,100); //#567d46
  beginShape();
  vertex(-xStart+agentRad*2, -yStart+agentRad*2, zPosGlobal);
  vertex(xStart-agentRad*2, -yStart+agentRad*2, zPosGlobal);
  vertex(xStart-agentRad*2, yStart-agentRad*2, zPosGlobal);
  vertex(-xStart+agentRad*2, yStart-agentRad*2, zPosGlobal);
  endShape(CLOSE);
  popMatrix();
  
  //Update path, Update agents
  nevigate();
  //Draw the circle obstacles
  for (int i = 0; i < numObstacles; i++){
    Vec3 c = circlePos[i];
    float r = circleRad[i];
    pushMatrix();
    translate(c.x,c.y,c.z-40);
    noStroke();
    //fill(#00ff00,40);
    specular(204, 102, 0);
    //sphere(r);
    rotateX(PI/2);
    scale(r,r,r);
    shape(tree);
    popMatrix();
  }
  
  //Draw the box obstacles
  pushMatrix();
  translate(boxTopLeft.x+boxW/2, boxTopLeft.y+boxH/2,zPosGlobal);
  rotateX(PI/2);
  float factor=4;
  scale(boxW/factor,boxH/factor,boxH/factor);
  //specular(204, 102, 0);
  shape(house);
  popMatrix();

  //Draw start
  for (int j=0;j<numAgents;j++){
  //pushMatrix();
  //fill(#00ccff,180);
  //translate(startPos[j].x,startPos[j].y,startPos[j].z-10);
  //noStroke();
  ////sphere(goalSize*2);
  //box(goalSize,goalSize,5);
  //popMatrix();
  
  //Draw goal
  pushMatrix();
  fill(250,30,50,180);
  translate(goalPos[j].x,goalPos[j].y,goalPos[j].z-10);
  noStroke();
  box(goalSize,goalSize,5);
  popMatrix();
  
  //Display text when there is no path
  if (noPath){  
    pushMatrix();
    textFont(f);
    textSize(100);//textAlign(CENTER);
    fill(#ff0000,204);
    text("No feasible path!",xStart,yStart+height/2,zPosGlobal+100);
    popMatrix();
  }

  if (path[j].size() == 1 && path[j].get(0) == -1) continue;
  
  //Draw Planned Path
  if (showPath){
    stroke(20,255,40,100);
    strokeWeight(5);
    line(startPos[j].x,startPos[j].y,startPos[j].z,nodePos[path[j].get(0)].x,nodePos[path[j].get(0)].y,nodePos[path[j].get(0)].z);
    for (int i = 0; i < path[j].size()-1; i++){
      int cNode = path[j].get(i);      
      int nNode = path[j].get(i+1);
      line(nodePos[cNode].x,nodePos[cNode].y,nodePos[cNode].z,nodePos[nNode].x,nodePos[nNode].y,nodePos[nNode].z);
    }
    line(goalPos[j].x,goalPos[j].y,goalPos[j].z,nodePos[path[j].get(path[j].size()-1)].x,nodePos[path[j].get(path[j].size()-1)].y,nodePos[path[j].get(path[j].size()-1)].z);
  }
  //Draw the green agent
  pushMatrix();
  noStroke();
  translate(agentPos[j].x, agentPos[j].y, agentPos[j].z);
  rotate(-(float)atan2(agentVel[j].x, agentVel[j].y));
  scale(20);
  rotateZ(PI);
  rotateX(PI/2);
  switch (j){
  case 1:  shape(p1); break;
  case 2:  shape(p2); break;
  case 3:  shape(p3); break;
  default:  shape(p4); break;
  }
  popMatrix();
  }
}


boolean shiftDown = false;
void keyPressed(){
  camera.HandleKeyPressed();
  if (key == 'r'){
    generateCourse();
    generatePRM();
    paused = true;
    return;
  }
  
  if (key == ' ') paused = !paused;
  
  if (key == 'p') showPath = !showPath;
  
  float speed = 20;
  if (key == 'l'){
    boxTopLeft.x += speed;
    paused = true;
    generatePRM();
  }
  if (key == 'j'){
    boxTopLeft.x -= speed;
    paused = true;
    generatePRM();
  }
  if (key == 'i'){
    boxTopLeft.y -= speed;
    paused = true;
    generatePRM();
  }
  if (key == 'k'){
    boxTopLeft.y += speed;
    paused = true;
    generatePRM();
  }
  if (key == 'o'){
    paused = true;
    for (int i=0;i<numAgents;i++){
    curNode[i]=1;
    agentPos[i] = new Vec3(startPos[i].x, startPos[i].y, startPos[i].z);
    }
  }

}

void keyReleased(){
  camera.HandleKeyReleased();
}

float computeTTC(Vec3 pos1, Vec3 vel1, float radius1, Vec3 pos2, Vec3 vel2, float radius2){
  Vec3 relativeVel = vel1.minus(vel2);
   return rayCircleIntersectTime(pos2, radius1+radius2, pos1, relativeVel);
}

// Compute attractive forces to draw agents to their goals, 
// and avoidance forces to anticipatory avoid collisions
Vec3 computeAgentForces(int id){
  Vec3 acc = new Vec3(0,0,0);
  Vec3 goalVel = computeAgentVel(id);//goalPos[id].minus(agentPos[id]);
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
