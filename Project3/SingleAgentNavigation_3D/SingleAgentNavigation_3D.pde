//CSCI 5611 - Graph Search & Planning

boolean showPath = false;
boolean noPath = false;
PFont f;
float zPosGlobal = -1500;
float xStart = -500;
float yStart = -400;
PShape tree,house,animal,people,people1;
boolean toggle = true;

Camera camera;
float dt = 1/frameRate;

//Change the below parameters to change the scenario/roadmap size
int numObstacles = 10;
int numNodes  = 80;
    
//A list of circle obstacles
static int maxNumObstacles = 1000;
float maxCircleRad = 40;
float minCircleRad = 20;
Vec3 circlePos[] = new Vec3[maxNumObstacles]; //Circle positions
float circleRad[] = new float[maxNumObstacles];  //Circle radii

//A box obstacle
float boxW = 100;
float boxH = 100;
Vec3 boxTopLeft = new Vec3(xStart+500,yStart+400,zPosGlobal+boxH);

//The agent we are controlling
boolean paused = true;
float agentRad = 30;
Vec3 agentPos; 
Vec3 agentVel = new Vec3(200,40,zPosGlobal+agentRad*2);
float goalSpeed = 100;
int curNode = 0;
Vec3 nextTarget;
float margin = 5;

float goalSize = 10;
Vec3 startPos;
Vec3 goalPos;

ArrayList<Integer> path = new ArrayList<Integer>();

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
  animal = loadShape("Sheep.obj");
  people = loadShape("Female_Dress.obj");
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
    }
  agentVel = computeAgentVel();
  if (agentPos.distanceTo(nextTarget)>2)agentPos.add(agentVel.times(dt));
  
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
  
  //startPos = new Vec3(-xStart, -yStart, zPosGlobal); //sampleFreePos();
  //goalPos = new Vec3(xStart, yStart, zPosGlobal+goalSize); //= sampleFreePos();
  startPos = new Vec3(xStart, yStart, zPosGlobal); //sampleFreePos();
  goalPos = new Vec3(-xStart, -yStart, zPosGlobal+goalSize); //= sampleFreePos();

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
  println("FrameRate:",frameRate);
  camera.Update(dt);
  background(0); //#87ceeb
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
  vertex(-xStart+agentRad, -yStart+agentRad, zPosGlobal);
  vertex(xStart-agentRad, -yStart+agentRad, zPosGlobal);
  vertex(xStart-agentRad, yStart-agentRad, zPosGlobal);
  vertex(-xStart+agentRad, yStart-agentRad, zPosGlobal);
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
  pushMatrix();
  fill(#00ccff,180);
  translate(startPos.x,startPos.y,startPos.z);
  noStroke();
  //sphere(goalSize*2);
  box(goalSize*2,goalSize*2,5);
  popMatrix();
  
  //Draw goal
  pushMatrix();
  fill(250,30,50,180);
  translate(goalPos.x,goalPos.y,goalPos.z-5);
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
    text("No feasible path!",xStart,yStart+height/2,zPosGlobal+100);
    popMatrix();
  }

  if (path.size() == 1 && path.get(0) == -1) return;
  
  //Draw Planned Path
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
    startPos = new Vec3(mouseX, mouseY,zPosGlobal);
    //println("New Start is",startPos.x, startPos.y);
  }
  else{
    goalPos = new Vec3(mouseX, mouseY,zPosGlobal);
    //println("New Goal is",goalPos.x, goalPos.y);
  }
  generatePRM();
}
