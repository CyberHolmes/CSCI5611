//CSCI5611 HW3 Hailin Archer Implementation 1:
//Modified existing code and additions:
//  1. Added A* search algorithm, enabled by default
//  2. Two planPath options: 
//      2.1 Add start and goal to node network before drawing graph; 
//      2.2 Separate getNeibors() function to find nearest valid nodes for start and goal
//  3. return empty path if there is direct unobstructed path between start and goal

//Here, we represent our graph structure as a neighbor list
//You can use any graph representation you like
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node

//Variables for A* search algorithm
float[] hScore = new float[maxNumNodes];
float[] hScore2 = new float[maxNumNodes];
float inf = 99999; //infinity value for initial scores (A* algorithm)
Boolean AStarEnable = true;
Boolean BFSEnable = false;

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = nodePos[j].minus(nodePos[i]).normalized();
      float distBetween = nodePos[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
      }
    }
  }
}

//getNeighbors method, neighbor with the shortest distance to me is on top
ArrayList<Integer> getNeighbors(Vec2 point, Vec2[] centers, float[] radii, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> neighborList = new ArrayList<Integer>();
  ArrayList<Float> distList = new ArrayList<Float>();
  //float minDist = 999999;
  for (int i = 0; i < numNodes; i++){
    float dist = nodePos[i].distanceTo(point)+hScore2[i];
    boolean inserted = false;
    Vec2 dir = point.minus(nodePos[i]).normalized();
    hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, dist);
    if (!circleListCheck.hit){
      //if (dist < minDist){
      //minDist = dist;
      //neighborList.add(0,i);
      //} else
      //{neighborList.add(i);}
      int ii=0;
      for (ii=0; ii<distList.size()-1; ii++){
        if (dist<distList.get(ii)) {distList.add(ii,dist); neighborList.add(ii,i);inserted = true; break;}
      }
      if (!inserted) {distList.add(ii,dist); neighborList.add(ii,i);}
    }
  }
  return neighborList;
}

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  connectNeighbors(centers, radii, numObstacles, nodePos, numNodes);
  //Check if there is direct unobstructed path between start and goal
  Vec2 dir = goalPos.minus(startPos).normalized();
  float l = goalPos.distanceTo(startPos);
  hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, startPos, dir, l);
  if (!circleListCheck.hit){
    return path;
  }
  //Variables to keep track of start and goal direct neighbors
  ArrayList<Integer> startNeighbors = getNeighbors(startPos, centers, radii, nodePos, numNodes);
  ArrayList<Integer> goalNeighbors = getNeighbors(goalPos, centers, radii, nodePos, numNodes);
  if (startNeighbors.isEmpty()) return path; //if there is no direct node to start, return empty path
  if (goalNeighbors.isEmpty()) return path;

  boolean done = false;
  int startID = startNeighbors.get(0);
    startNeighbors.remove(0);
    int goalID = goalNeighbors.get(0);
    goalNeighbors.remove(0);
  while (AStarEnable && !done){
    println("Op2: AStar Search Method");    
    calchScore(numNodes, goalID);
    path = runAStar(nodePos, numNodes, startID, goalID);
    done = true;
    if (path.size() == 1 && path.get(0) == -1){ //If no path found, try the next direct neighbor
      if (!startNeighbors.isEmpty()) {
        startID = startNeighbors.get(0);
        startNeighbors.remove(0);
        done = false;
      }
      if (done) { //only check if all neighbors of start had been visited
        if (!goalNeighbors.isEmpty()) {
          goalID = goalNeighbors.get(0);
          goalNeighbors.remove(0);
          done = false;
        }
      }      
    }
  }
  while (BFSEnable && !done){
    println("Op2: BFS Search Method");    
    path = runBFS(nodePos, numNodes, startID, goalID);
    done = true;
    if (path.size() == 1 && path.get(0) == -1){ //If no path found, try the next direct neighbor
      if (!startNeighbors.isEmpty()) {
        startID = startNeighbors.get(0);
        startNeighbors.remove(0);
        done = false;
      }
      if (done) { //only check if all neighbors of start had been visited
        if (!goalNeighbors.isEmpty()) {
          goalID = goalNeighbors.get(0);
          goalNeighbors.remove(0);
          done = false;
        }
      }      
    }
  }  
  return path;
}

//BFS (Breadth First Search)
ArrayList<Integer> runBFS(Vec2[] nodePos, int numNodes, int startID, int goalID){
  ArrayList<Integer> fringe = new ArrayList();  //New empty fringe
  ArrayList<Integer> path = new ArrayList();
  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }

  //println("\nBeginning Search");
  
  visited[startID] = true;
  fringe.add(startID);
  //println("Adding node", startID, "(start) to the fringe.");
  //println(" Current Fringe: ", fringe);
  
  while (fringe.size() > 0){
    int currentNode = fringe.get(0);
    fringe.remove(0);
    if (currentNode == goalID){
      //println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int neighborNode = neighbors[currentNode].get(i);
      if (!visited[neighborNode]){
        visited[neighborNode] = true;
        parent[neighborNode] = currentNode;
        fringe.add(neighborNode);
        //println("Added node", neighborNode, "to the fringe.");
        //println(" Current Fringe: ", fringe);
      }
    } 
  }
  
  if (fringe.size() == 0){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
    
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  //print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  return path;
}

//A* search method
ArrayList<Integer> runAStar(Vec2[] nodePos, int numNodes, int startID, int goalID){
  ArrayList<Integer> fringe = new ArrayList();  //New empty fringe
  ArrayList<Integer> path = new ArrayList();
  float[] gScore = new float[maxNumNodes];
  float[] fScore = new float[maxNumNodes];
  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
    gScore[i] = inf;
    fScore[i] = inf;
  }
  //println("startID="+startID+"goalID="+goalID);
  visited[startID] = true;
  fringe.add(startID);
  gScore[startID] = 0;
  fScore[startID] = hScore[startID];
  //println("Adding node", startID, "(start) to the fringe.");
  //println(" Current Fringe: ", fringe);
  
  while (fringe.size() > 0){    
    int currentNode= fringe.get(0);
    if (currentNode == goalID){
      //println("Goal found!");
      break;
    }
    float lowest = fScore[currentNode];
    int index = 0;
    for (int i=1; i<fringe.size(); i++){
      int nextNode = fringe.get(i);      
      if (lowest> fScore[nextNode]) {
        currentNode = nextNode;
        lowest = fScore[nextNode];
        index = i;
      }
    }
    fringe.remove(index);
    if (currentNode == goalID){
      //println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int neighborNode = neighbors[currentNode].get(i);
      float temp_gScore = gScore[currentNode] + nodePos[currentNode].distanceTo(nodePos[neighborNode]);
      if (temp_gScore < gScore[neighborNode]){
        visited[neighborNode] = true;
        parent[neighborNode] = currentNode;
        gScore[neighborNode] = temp_gScore;
        fScore[neighborNode] = gScore[neighborNode] + hScore[neighborNode];
        if (!fringe.contains(neighborNode)){
        fringe.add(neighborNode);
        //println("Added node", neighborNode, "to the fringe.");
        //println(" Current Fringe: ", fringe);
        }
      }
    } 
  }
  
  if (fringe.size() == 0){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
    
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  //print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  return path;
}
//Helper function for A* search method
void calchScore(int numNodes, int goalID){
  for (int i=0; i < numNodes; i++) {
    hScore[i] = nodePos[i].distanceTo(nodePos[goalID]);
  }
}

void calchScore2(int numNodes){
  for (int i=0; i < numNodes; i++) {
    hScore2[i] = nodePos[i].distanceTo(goalPos);
  }
}

ArrayList<Integer> planPath2(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  nodePos[numNodes] = new Vec2(startPos.x, startPos.y);numNodes++;
  int startID = numNodes-1;
  nodePos[numNodes] = new Vec2(goalPos.x, goalPos.y);numNodes++;
  int goalID = numNodes-1;
  
  connectNeighbors(centers, radii, numObstacles, nodePos, numNodes);
  //int startID = closestNode(startPos, nodePos, numNodes);
  //int goalID = closestNode(goalPos, nodePos, numNodes);
  
  if (AStarEnable){
    println("op1: AStar Search Method");
    calchScore(numNodes, goalID);
    path = runAStar(nodePos, numNodes, startID, goalID);
  }
  if (BFSEnable) { 
    println("op1: BFS Search Method");
    path = runBFS(nodePos, numNodes, startID, goalID);
  } 
  if (path.get(0) != -1) {
    path.remove(0); //pop off start node from path
    path.remove(path.size()-1); //remove extra goal node
  }
  return path;
}
