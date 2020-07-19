//CSCI 5611 - Graph Search & Planning
//Change the below parameters to change the scenario/roadmap size
int numObstacles = 12;
int numNodes  = numObstacles*8;

boolean showPath = false;
boolean noPath = false;
PFont f;
float zOffset = -1100;
float xOffset = -500;
float yOffset = -400;
PShape tree,house,people,silo,rock,bush;
boolean showGraph = false;

Camera camera;
float dt = 1/frameRate;
   
//A list of circle obstacles
static int maxNumObstacles = 1000;
float maxCircleRad = 40;
float minCircleRad = 20;
Vec3 circlePos[] = new Vec3[maxNumObstacles]; //Circle positions
float circleRad[] = new float[maxNumObstacles];  //Circle radii

//A box obstacle
float boxW = 150;
float boxH = 150;
Vec3 boxTopLeft = new Vec3(xOffset+600,yOffset+100,zOffset);

//The agent we are controlling
boolean paused = true;
float agentRad = 30;
Vec3 agentPos; 
Vec3 agentVel = new Vec3(200,40,zOffset);
float goalSpeed = 100;
int curNode = 0;
Vec3 nextTarget;
float margin = 0;

float goalSize = 10;
Vec3 startPos;
Vec3 goalPos;

ArrayList<Integer> path = new ArrayList<Integer>();

static int maxNumNodes = 1000;
Vec3[] nodePos = new Vec3[maxNumNodes];

//Generate non-colliding PRM nodes
void generateRandomNodes(int numNodes, Vec3[] circleCenters, float[] circleRadii){
  for (int i=0;i<numNodes;i++) {
    //Vec3 randPos = new Vec3(random(xOffset,xOffset+width),random(yOffset,yOffset+height),zOffset);
    Vec3 randPos = new Vec3(random(xOffset+50,xOffset+950),random(yOffset+50,yOffset+700),zOffset);
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos);
    boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    while (insideAnyCircle || insideBox){
      //randPos = new Vec3(random(xOffset,xOffset+width),random(yOffset,yOffset+height),zOffset);
      randPos = new Vec3(random(xOffset+50,xOffset+950),random(yOffset+50,yOffset+700),zOffset);
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
    Vec3 randPos = new Vec3(random(xOffset+50,xOffset+950),random(yOffset+50,yOffset+700),zOffset+circleRad[i]);
    boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    while (insideBox) {
      randPos = new Vec3(random(xOffset+50,xOffset+950),random(yOffset+50,yOffset+700),zOffset+circleRad[i]);
      insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    }
    circlePos[i] = new Vec3(randPos.x,randPos.y,randPos.z);
  }
}

int strokeWidth = 2;
void setup(){
  size(1500,1200,P3D);
  camera = new Camera();
  generateCourse();
  generatePRM();
  f = loadFont("Cambria-Bold-48.vlw");
  tree = loadShape("PineTree_1.obj");
  silo = loadShape("Silo.obj");
  house = loadShape("House.obj");
  people = loadShape("Female_Dress.obj");
  rock = loadShape("Rock_1.obj");
  bush = loadShape("Plant_1.obj");
}

Vec3 computeAgentVel(){
  return nextTarget.minus(agentPos).normalized().times(goalSpeed);
}
void moveAgent(float dt){
    Vec3 dir = goalPos.minus(agentPos);
    float dist = agentPos.distanceTo(goalPos);
    hitInfo clide = rayCircleListIntersect(circlePos, circleRad, numObstacles, agentPos, dir.normalized(), dist); 
    if (!clide.hit || path.size()<2) {
      nextTarget = new Vec3(goalPos.x,goalPos.y,goalPos.z);
    } else {
      if ((curNode+1)<path.size()-1){
        Vec3 temp = nodePos[path.get(curNode+1)];
        dir = temp.minus(agentPos);
        dist = agentPos.distanceTo(temp);
        hitInfo clide2 = rayCircleListIntersect(circlePos, circleRad, numObstacles, agentPos, dir.normalized(), dist); 
        if (!clide2.hit) {
          curNode++;
        }
      }
          nextTarget = new Vec3(nodePos[path.get(curNode)].x,nodePos[path.get(curNode)].y,nodePos[path.get(curNode)].z);
    }
    if (agentPos.distanceTo(nextTarget)<2 && curNode<path.size()-1) {
      curNode++; //paused = true;
      nextTarget = new Vec3(nodePos[path.get(curNode)].x,nodePos[path.get(curNode)].y,nodePos[path.get(curNode)].z);
    }
  agentVel = computeAgentVel();
  if (agentPos.distanceTo(nextTarget)>2)agentPos.add(agentVel.times(dt));
}
Vec3 sampleFreePos(){
  Vec3 randPos = new Vec3(random(xOffset,xOffset+width),random(yOffset,yOffset+height),zOffset);
  boolean insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos);
  boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
  while (insideAnyCircle || insideBox){
    randPos = new Vec3(random(xOffset,xOffset+width),random(yOffset,yOffset+height),zOffset);
    insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos);
    insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
  }
  return randPos;
}

void generateCourse(){

  placeRandomObstacles(numObstacles);
  
  //startPos = new Vec3(-xOffset, -yOffset, zOffset); //sampleFreePos();
  //goalPos = new Vec3(xOffset, yOffset, zOffset+goalSize); //= sampleFreePos();
  startPos = new Vec3(xOffset, yOffset, zOffset); //sampleFreePos();
  goalPos = new Vec3(-xOffset, -yOffset, zOffset); //= sampleFreePos();

  generateRandomNodes(numNodes, circlePos, circleRad);    
}

void generatePRM(){
  agentPos = new Vec3(startPos.x, startPos.y, startPos.z);  
  curNode=1;
  path = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
  if (path.size() == 1 && path.get(0) == -1){
    noPath = true;
  } else { noPath = false;}
}

void nevigate(){ 
  
  //Update agent if not paused
  if (!paused){
    moveAgent(1.0/frameRate); 
  }
}

void draw(){
  //println("FrameRate:",frameRate);
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
  fill(#028a0f,50); //#567d46
  beginShape();
  vertex(-xOffset+agentRad, -yOffset+agentRad, zOffset);
  vertex(xOffset-agentRad, -yOffset+agentRad, zOffset);
  vertex(xOffset-agentRad, yOffset-agentRad, zOffset);
  vertex(-xOffset+agentRad, yOffset-agentRad, zOffset);
  endShape(CLOSE);
  popMatrix();
  
  //Update path, Update agents
  nevigate();
  //Draw the circle obstacles
  for (int i = 0; i < numObstacles; i++){
    Vec3 c = circlePos[i];
    float r = circleRad[i];
    float factor = 1;
    float offset = 40;
    if (r >= 38){  
      factor = 0.5;offset = 60;
      pushMatrix();
    translate(c.x,c.y,c.z-offset);
    noStroke();
    fill(255,40);
    specular(204, 102, 0);
    //sphere(r);
    rotateX(PI/2);
    scale(r*factor,r*factor,r*factor);
    shape(silo);
    popMatrix();
    
    } else if (r>30) {
      factor = 1;offset = 55;
      pushMatrix();
    translate(c.x,c.y,c.z-offset);
    noStroke();
    fill(255,40);
    specular(204, 102, 0);
    //sphere(r);
    rotateX(PI/2);
    scale(r*factor,r*factor,r*factor);
    shape(tree);
    popMatrix();
    } else{
      factor = 2.5;offset = 40;
    pushMatrix();
    translate(c.x,c.y,c.z-offset);
    noStroke();
    fill(255,40);
    specular(204, 102, 0);
    //sphere(r);
    rotateX(PI/2);
    scale(r*factor,r*factor,r*factor);
    shape(rock);
    popMatrix();
    }
  }
  
  //Draw the box obstacles
  pushMatrix();
  float factor=2.5;
  translate(boxTopLeft.x+boxW/2, boxTopLeft.y+boxH/2,zOffset-boxH/factor);
  //box(boxW, boxH, boxH);
  rotateX(PI/2);  
  scale(boxW/factor,boxH*1.5/factor,boxH/factor);
  //fill(#000080,50);
  ambientLight(250,20,250);   //More light…  
  //specular(204, 0, 220);
  shape(house);
  popMatrix();

  //Draw start
  pushMatrix();
  fill(#00ccff,180);
  translate(startPos.x,startPos.y,startPos.z+5);
  noStroke();
  //sphere(goalSize*2);
  box(goalSize*2,goalSize*2,5);
  popMatrix();
  
  //Draw goal
  pushMatrix();
  fill(250,30,50,180);
  translate(goalPos.x,goalPos.y,goalPos.z+5);
  noStroke();
  //sphere(goalSize*2);
  box(goalSize*2,goalSize*2,5);
  popMatrix();
  
  //Display text when there is no path
  if (noPath){  
    pushMatrix();
    textFont(f);
    textSize(100);//textAlign(CENTER);
    fill(#ff0000,204);
    text("No feasible path!",xOffset,yOffset+height/2,zOffset+100);
    popMatrix();
  }

  if (path.size() == 1 && path.get(0) == -1) return;
  
  //Draw Planned Path
   
    if (showGraph){
    //Draw PRM Nodes
    fill(255);
    //for (int i = 0; i < numNodes; i++){
    //  pu
    //  sphere(nodePos[i].x,nodePos[i].y,nodePos[i].z,2);
    //}
  
    //Draw graph
    stroke(100,100,100);
    strokeWeight(1);
    for (int i = 0; i < numNodes; i++){
      for (int j : neighbors[i]){
          line(nodePos[i].x,nodePos[i].y,nodePos[i].z,nodePos[j].x,nodePos[j].y,nodePos[j].z);
        }
      }
    }
   if (showPath){  
    stroke(20,255,40,100);
    strokeWeight(5);
    line(startPos.x,startPos.y,startPos.z,nodePos[path.get(0)].x,nodePos[path.get(0)].y,nodePos[path.get(0)].z);
    for (int i = 0; i < path.size()-1; i++){
      int curNode = path.get(i);
      int nextNode = path.get(i+1);
      line(nodePos[curNode].x,nodePos[curNode].y,nodePos[curNode].z,nodePos[nextNode].x,nodePos[nextNode].y,nodePos[nextNode].z);
    }
    line(goalPos.x,goalPos.y,goalPos.z,nodePos[path.get(path.size()-1)].x,nodePos[path.get(path.size()-1)].y,nodePos[path.get(path.size()-1)].z);
  }
  //Draw the agent
  pushMatrix();
  noStroke();
  translate(agentPos.x, agentPos.y, agentPos.z);
  rotate(-(float)atan2(agentVel.x, agentVel.y));
  scale(20);
  rotateZ(PI);
  rotateX(PI/2);
  shape(people);
  popMatrix(); 
  //println(camera.position);
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
    curNode=1;
    agentPos = new Vec3(startPos.x, startPos.y, startPos.z);
  }
  //generatePRM();

}

void keyReleased(){
  camera.HandleKeyReleased();
  //if (keyCode == SHIFT){
  //  shiftDown = false;
  //}
}

void mousePressed(){
  if (mouseButton == RIGHT){
    float curZ = -camera.position.z+zOffset;
    startPos = new Vec3(-mouseX*zOffset/width+xOffset, -mouseY*zOffset/width+yOffset,zOffset);
    agentPos = new Vec3(startPos.x, startPos.y, startPos.z);
  }
  else{
    goalPos = new Vec3(-mouseX*zOffset/width+xOffset, -mouseY*zOffset/width+yOffset,zOffset);
    agentPos = new Vec3(startPos.x, startPos.y, startPos.z);
  }
  generatePRM();
}

//helper functions
//void placeRandomObstacles(int numObstacles){
//  int factor = 4;
  
//    int numElements = int((xOffset*yOffset*4)/(maxCircleRad*2))+1;
//    Vec3[] potentialPos = new Vec3[numElements];
//    final IntList nums = new IntList(numElements);
//    int n=0;
    
//    for (int i=int(xOffset); i<int(-xOffset);i+=agentRad*factor){
//      for (int j=int(yOffset); j<int(-yOffset);j+=agentRad*factor){
//        potentialPos[n] = new Vec3(float(i),float(j),0);
//        nums.append(n);
//        n++;
//      }
//    }
//    nums.shuffle();
//    n=0; int i=0;
//    while(i<numObstacles){
//      int curIdx = nums.get(n); n++;
//      if (curIdx == 0 || curIdx == nums.size()-1) continue;
//      Vec3 randPos = new Vec3(potentialPos[curIdx].x,potentialPos[curIdx].y,zOffset+circleRad[i]);
//      //println(randPos);
//      boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
//      if (insideBox) {continue;} 
//      circleRad[i] = random(minCircleRad,maxCircleRad);
//      circlePos[i] = new Vec3(randPos.x,randPos.y,randPos.z);
//      println(circlePos[i]);
//      i++;
//    }
//}
