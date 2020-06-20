// CSCI 5611 HW 1 Part 2: Simulation

import java.util.*;
ParticleSystem ps;

void setup() {
  size(800,800,P3D);
  surface.setTitle("3D Blue Fountain [by Hailin Archer]");
  smooth();
  ps = new ParticleSystem();
  stroke(255);
  strokeWeight(4);
}
 
void draw() {
  println("frameRate="+frameRate);
  println("numParticles="+ps.particles.size());
  background(0);  
  
  translate(width/2, height/2, -1500);
  rotateY(frameCount*0.01);

  //Draw a platform to show the fountain
  stroke(255);
  strokeWeight(1);
  fill(#00ab66);
  beginShape();
  vertex(-width, height, -width);
  vertex(width, height, -width);
  vertex(width, height, width);
  vertex(-width, height, width);
  endShape(CLOSE);
  ps.run();
  ps.addParticle();

}
