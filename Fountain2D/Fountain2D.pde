// CSCI 5611 HW 1 Part 2: Particle Systems Simulation
// A whale blows water stream
// Whale image credit: pngguru.com
import java.util.*;
ParticleSystem ps;

PImage whale;
PGraphics pg;

void setup() {
  size(1500,1125);  
  surface.setTitle("2D Fountain [by Hailin Archer]");
  smooth();
  ps = new ParticleSystem();
  whale = loadImage("whale3.png");
  stroke(255);
  strokeWeight(4);
  background(0);
}
 
void draw() {
  println("frameRate="+frameRate);
  println("numParticles="+ps.particles.size());
  background(0,0,0,10);
  ps.run();
  ps.addParticle();
  
  pushMatrix();
  translate(width/2-250, height-500);
  image(whale,0,0);
  tint(255,255);
  popMatrix();
  
}
