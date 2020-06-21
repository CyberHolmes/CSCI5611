// Boid3D Simulation: CSCI5611 Project 1
// By Hailin Archer 6/20/2020

ArrayList flock;
int nBoids = 200;

void setup(){
  size(1500,1500, P3D);
  smooth();  
  flock = new ArrayList();
  for (int i=0; i<nBoids; i++){
  flock.add(new Boid());   
  }
}

void draw(){  
  background(51);
  noStroke();
  translate(width/2, height/2, -width*2);
  rotateY(frameCount*0.005);

  //Draw boundary of the boid space (a cube)
  stroke(255);
  strokeWeight(1);
  fill(#00ab66, 50);
  beginShape();
  vertex(0, height, -0);
  vertex(width, height, -0);
  vertex(width, height, width);
  vertex(0, height, width);
  endShape(CLOSE);
  noFill();
  beginShape();
  vertex(0, 0, -0);
  vertex(width, 0, -0);
  vertex(width, 0, width);
  vertex(0, 0, width);
  endShape(CLOSE);
  beginShape();
  vertex(width, 0, -0);
  vertex(width, height, -0);
  vertex(width, height, width);
  vertex(width, 0, width);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, -0);
  vertex(0, height, -0);
  vertex(0, height, width);
  vertex(0, 0, width);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, width);
  vertex(0, height, width);
  vertex(width, height, width);
  vertex(width, 0, width);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, width);
  vertex(0, height, width);
  vertex(width, height, width);
  vertex(width, 0, width);
  endShape(CLOSE);  
  
  for (int i=0; i<flock.size(); i++){
    Boid b = (Boid)flock.get(i);
    b.update(b.getNeighbors(flock));
    b.adjustForBoundary();
    b.show();    
  }
  println("numBoids="+flock.size());
  println("frameRate="+frameRate);
}
