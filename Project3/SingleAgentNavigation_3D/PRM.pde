//CSCI5611 HW3 Part 1 - Hailin Archer
//Modified existing code and additions:
//  1. Added A* search algorithm, enabled by default
//  2. planPath: add start node and goal node to node network before building graph
//  3. return empty path if there is direct unobstructed path between start and goal

//Here, we represent our graph structure as a neighbor list
//You can use any graph representation you like
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node
ArrayList<Float>[] cost = new ArrayList[maxNumNodes];

//Variables for A* search algorithm
float inf = 99999; //infinity value for initial scores (A* algorithm)

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(Vec3[] centers, float[] radii, int numObstacles, Vec3[] nodePos, int numNodes){
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      Vec3 dir = nodePos[j].minus(nodePos[i]).normalized();
      float distBetween = nodePos[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
      }
    }
  }
}

ArrayList<Integer> planPath(Vec3 startPos, Vec3 goalPos, Vec3[] centers, float[] radii, int numObstacles, Vec3[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  connectNeighbors(centers, radii, numObstacles, nodePos, numNodes);

  path = runAStar(nodePos, numNodes, startPos, goalPos, centers, radii);

  return path;
}

//A* search method
ArrayList<Integer> runAStar(Vec3[] nodePos, int numNodes, Vec3 startPos, Vec3 goalPos, Vec3[] centers, float[] radii){
  ArrayList<Integer> path = new ArrayList();
  boolean goalFound = false;
  ArrayList<Integer> fringe = new ArrayList();  //New empty fringe  
  float[] hScore = new float[maxNumNodes];
  float[] gScore = new float[maxNumNodes];
  float[] fScore = new float[maxNumNodes];
  
  //Check if there is direct unobstructed path between start and goal
  //Vec3 dir = goalPos.minus(startPos).normalized();
  //float l = goalPos.distanceTo(startPos);
  //hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, startPos, dir, l);
  //if (!circleListCheck.hit){
  //  goalFound = true;
  //  return path;
  //}
  ////Add start/goal to node network
  int startID = numNodes; nodePos[numNodes++]=startPos;
  int goalID = numNodes; nodePos[numNodes++]=goalPos;
  neighbors[startID] = new ArrayList<Integer>(); //initialize neighborlist for start
  neighbors[goalID] = new ArrayList<Integer>(); //initialize neighborlist for goal 
  
  // add start node to fringe
  //println("\nBeginning Search");
  visited[startID] = true;
  fringe.add(startID);
  //visited[goalID] = true;
  //fringe.add(goalID);
  for (int i = 0; i < numNodes; i++) { //exclude goal ID
    visited[i] = false;
    parent[i] = -1; //No parent yet
    hScore[i] = nodePos[i].distanceTo(goalPos); //asign hscore
    gScore[i] = inf;
    fScore[i] = inf;
    // check if nodes are in sight with goal, if it is, add to fringe
    Vec3 dir = goalPos.minus(nodePos[i]).normalized();
    float l = goalPos.distanceTo(nodePos[i]);
    hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, l);
    if (!circleListCheck.hit && i!=goalID){
      fringe.add(i);
      visited[i] = true;      
      neighbors[goalID].add(i);
      neighbors[i].add(goalID);
    }
    dir = startPos.minus(nodePos[i]).normalized();
    l = startPos.distanceTo(nodePos[i]);
    circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, l);
    if (!circleListCheck.hit && i!=startID){
      //fringe.add(i);
      //visited[i] = true;
      neighbors[startID].add(i);
      neighbors[i].add(startID);
      parent[i] = startID;
    }
  }  
  
  gScore[startID] = 0;
  fScore[startID] = hScore[startID];
  //println("Adding node", startID, "(start) to the fringe.");
  //println(" Current Fringe: ", fringe);
  
  while (fringe.size() > 0){    
    int currentNode= fringe.get(0);
    if (currentNode == goalID){
      goalFound = true;
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
      goalFound = true;
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
  
  if (fringe.size() == 0 && !goalFound){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
    
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  //path.add(0,goalID); //no need to add goal node anymore
  //print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  return path;
}
