//CSCI 5611 HW 2 PDE Library
//Look at GroundTruth.pde and Integrator.pde for more instructions.
import java.util.*;

color[] myPalette = {#FFFFFF, #FFF000, #EF4444, #394BA0, #82C341, #EF4444, #D54799, #FAA31B, #88C6ED, #009F75};
color[] palette = myPalette;

PrintWriter output; //output datafile
PFont labelFont;
ArrayList<Float> x_all_eu, x_all_mid, x_all_rk4, x_all_heun;
ArrayList<Float> x_actual;

int c = 6; //Choosing functions
// 0:dx/dt=cos(t)
// 1: dx/dx = 2*t*cos(t*t)
// 2: dx/dt = 2
// 3: dx/dt = 2*t
// 4: dx/dt = t*t*t
// 5: dx/dt = x
// 6: dx/dt = sin(t) + t*cos(t) 
float x_start = 0; //0
float dt = 1; //1
int n_steps = 20;
float t_start = 0;
float t_end = t_start + n_steps * dt;
float[] t_display = new float[n_steps+1];
float d = 12; //size of the circle for ploting data points

String outputFileName;

void RunComparisons(int c) {
  println("==========\nComparison Against the Ground Truth\n==========");
  println();
  
  float x_end;
  float actual_end = correctActual(actual(t_end,c),t_start,x_start,c); // the real functions may have a different shift depending on the inital condition and the form of function, correct it
  
  ArrayList<Float> x_actual_raw = actualList(t_start,n_steps,dt,c);
  // the real functions may have a different shift depending on the inital condition and the form of function, correct it
  x_actual = new ArrayList<Float>();
  x_all_eu = new ArrayList<Float>();
  x_all_mid = new ArrayList<Float>();
  x_all_rk4 = new ArrayList<Float>();
  x_all_heun = new ArrayList<Float>();
  for (float val: x_actual_raw)
    x_actual.add(correctActual(val,t_start,x_start,c));
  
  
  //Integrate using Eulerian integration
  println("Eulerian: "+getFunction(c));
  x_end = eulerian(t_start,x_start,n_steps,dt,c);
  println("f(t) for t =",t_end,"is",x_end," Ground truth:", actual_end," Error is", actual_end-x_end);

  println("Printing Each Step--");
  x_all_eu = eulerianList(t_start,x_start,n_steps,dt,c);
  println("Aprox:",x_all_eu);
  println("Actual:",x_actual);
  

  //Integrate using Midpiont integration
  println("\nMidpoint: "+getFunction(c));
  x_end= midpoint(t_start,x_start,n_steps,dt,c);
  println("f(t) for t =",t_end,"is",x_end," Ground truth:", actual_end," Error is", actual_end-x_end);
  
  println("Printing Each Step--");
  x_all_mid = midpointList(t_start,x_start,n_steps,dt,c);
  println("Aprox:",x_all_mid);
  println("Actual:",x_actual);
  
  
  //Integrate using RK4 (4th order Runge–Kutta)
  println("\nRK4: "+getFunction(c));
  x_end= rk4(t_start,x_start,n_steps,dt,c);
  println("f(t) for t =",t_end,"is",x_end," Ground truth:", actual_end," Error is", actual_end-x_end);
  
  println("Printing Each Step--");
  x_all_rk4 = rk4List(t_start,x_start,n_steps,dt,c);
  println("Aprox:",x_all_rk4);
  println("Actual:",x_actual);
  
  
  //For comparison, this is Heun's method, a different 2nd order method (similar to midpoint)
  println("\nHeun: "+getFunction(c));
  x_end= heun(t_start,x_start,n_steps,dt,c);
  println("f(t) for t =",t_end,"is",x_end," Ground truth:", actual_end," Error is", actual_end-x_end);
  
  println("Printing Each Step--");
  x_all_heun = heunList(t_start,x_start,n_steps,dt,c);
  println("Aprox:",x_all_heun);
  println("Actual:",x_actual);
}

// the real functions may have a different shift depending on the inital condition, this function does the correction
float correctActual(float val, float t_start, float x_start, int c) {
  return x_start + val - actual(t_start,c);
}

void setup(){
  size(1500,1000);
  labelFont = loadFont("GillSansMT-48.vlw");
  Date d = new Date();
  long current = d.getTime()/1000; 
  outputFileName = c+"_x"+x_start+"_dt"+dt+"_"+current;
  output = createWriter("data_"+outputFileName+".txt");
  output.println("t,x,dxdt,method"); //print column names in data file
  
  // Compare with actual functions   
  RunComparisons(c);
  
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  
}

void draw(){
  background(#808080);//(#A9A9A9);
  textFont(labelFont);
  stroke(255);
  fill(255);
  
  float xAxisStart = 110;
  float xAxisEnd = width -110;
  float xAxisStep = (xAxisEnd - xAxisStart)/(n_steps+1);
  float yAxisStart = 120;
  float yAxisEnd = height -110;
  
  float maxX1 = Collections.max(x_all_eu);
  float maxX2 = Collections.max(x_all_mid);
  float maxX3 = Collections.max(x_all_heun);
  float maxX4 = Collections.max(x_all_rk4);
  float maxX5 = Collections.max(x_actual);
  float[] values1 = {maxX1, maxX2, maxX3, maxX4, maxX5};
  float maxX = ceil(max(values1));
  float minX1 = Collections.min(x_all_eu);
  float minX2 = Collections.min(x_all_mid);
  float minX3 = Collections.min(x_all_heun);
  float minX4 = Collections.min(x_all_rk4);
  float minX5 = Collections.min(x_actual);
  float[] values2 = {minX1, minX2, minX3, minX4, minX5};
  float minX = floor(min(values2));  
  float stepVal = (maxX-minX)/n_steps;
  
  //title
  textSize(45);
  textAlign(CENTER);
  text(getFunction(c), width/2, 50);
  textSize(30);textAlign(CENTER);
  text("x0 = "+x_start+", dt = "+dt+", t_end = "+(t_start+dt*n_steps), width/2, 90);
  
  // Line and labels for X axis
  textSize(30);
  textAlign(CENTER);
  line(xAxisStart, yAxisEnd-50, xAxisEnd, yAxisEnd-50);
  for (int i = 0; i <= n_steps; i++) {
    String s = nf(t_start+dt*i,0,1);
    text (s, i * xAxisStep + xAxisStart+40, yAxisEnd);
    stroke(180); strokeWeight(1);
    line(i * xAxisStep + xAxisStart+40, yAxisStart, i * xAxisStep + xAxisStart+40, yAxisEnd-50);
  }
 
  // Line and labels for Y axis
  textSize(30);
  textAlign(RIGHT);
  line(150, yAxisStart, 150, yAxisEnd);
  for (int i = 0; i <= n_steps; i++) {
    String s = nf(minX+stepVal*i,0,1);
    text (s, 135, yAxisEnd-70-i*(yAxisEnd-80-yAxisStart)/n_steps);
    stroke(180); strokeWeight(3);
    line(xAxisStart+40, yAxisEnd-80-i*(yAxisEnd-80-yAxisStart)/n_steps, xAxisEnd, yAxisEnd-80-i*(yAxisEnd-80-yAxisStart)/n_steps);
  }
  
  for (int i=0; i <= n_steps;i++){
    t_display[i] = (xAxisStart+40 + xAxisStep*i);
  }
  // Draw ground truth
  float x_display_p =0;
  d = 25; stroke(palette[0]); fill(palette[0]); strokeWeight(8);
  for (int i=0;i<x_actual.size();i++){
    float x_display = map(x_actual.get(i),minX,maxX,yAxisEnd-80,yAxisStart);    
    if (i==0) x_display_p = x_display;   
    square(t_display[i]-d/2, x_display-d/2, d);
    if (i>0) line(t_display[i-1], x_display_p,t_display[i], x_display);
    x_display_p = x_display;
  }
  int tloc = 160;
  square(tloc-d/2, yAxisEnd+50-d/2,d);
  line(tloc-25, yAxisEnd+50,tloc+25, yAxisEnd+50);
  textSize(22);textAlign(CENTER);
  text("Ground Truth",tloc+100, yAxisEnd+60);
  //Draw Eulerian
  d = 22; stroke(palette[1]); fill(palette[1]); strokeWeight(7);
  for (int i=0;i<x_all_eu.size();i++){
    float x_display = map(x_all_eu.get(i),minX,maxX,yAxisEnd-80,yAxisStart);    
    if (i==0) x_display_p = x_display;
    ellipse(t_display[i], x_display, d, d);
    if (i>0) line(t_display[i-1], x_display_p,t_display[i], x_display);
    x_display_p = x_display;
  }
  tloc += 225;
  ellipse(tloc, yAxisEnd+50,d,d);
  line(tloc-25, yAxisEnd+50,tloc+25, yAxisEnd+50);
  textSize(22);textAlign(CENTER);
  text("Eulerian",tloc+100, yAxisEnd+60);
  
  //Draw rk4 result
  d = 18; stroke(palette[3]); fill(palette[3]); strokeWeight(6);
  for (int i=0;i<x_all_rk4.size();i++){
    float x_display = map(x_all_rk4.get(i),minX,maxX,yAxisEnd-80,yAxisStart);    
    if (i==0) x_display_p = x_display;
    square(t_display[i]-d/2, x_display-d/2, d);
    if (i>0) line(t_display[i-1], x_display_p,t_display[i], x_display);
    x_display_p = x_display;
  }
  tloc += 225;
  square(tloc-d/2, yAxisEnd+50-d/2,d);
  line(tloc-25, yAxisEnd+50,tloc+25, yAxisEnd+50);
  textSize(22);textAlign(CENTER);
  text("rk4",tloc+100, yAxisEnd+60);
  
  //Draw heun result
  d = 18; stroke(palette[4]); fill(palette[4]); strokeWeight(5);
  for (int i=0;i<x_all_heun.size();i++){
    float x_display = map(x_all_heun.get(i),minX,maxX,yAxisEnd-80,yAxisStart);    
    if (i==0) x_display_p = x_display;
    ellipse(t_display[i], x_display, d, d*1.5);
    if (i>0) line(t_display[i-1], x_display_p,t_display[i], x_display);
    x_display_p = x_display;
  }
  tloc += 225;
  ellipse(tloc, yAxisEnd+50,d,d*1.5);
  line(tloc-25, yAxisEnd+50,tloc+25, yAxisEnd+50);
  textSize(22);textAlign(CENTER);
  text("heun",tloc+100, yAxisEnd+60);
  
  //Draw Midpoint result
  d = 12; stroke(palette[2]); fill(palette[2]); strokeWeight(4);
  for (int i=0;i<x_all_mid.size();i++){
    float x_display = map(x_all_mid.get(i),minX,maxX,yAxisEnd-80,yAxisStart);    
    if (i==0) x_display_p = x_display;
    stroke(palette[2]);
    //noFill();
    fill(palette[2]);
    ellipse(t_display[i], x_display, d, d);
    if (i>0) dottedLine(t_display[i-1], x_display_p,t_display[i], x_display,20);
    x_display_p = x_display;
  }
  tloc += 225;
  ellipse(tloc, yAxisEnd+50,d,d);
  dottedLine(tloc-25, yAxisEnd+50,tloc+25, yAxisEnd+50,5);
  textSize(22);textAlign(CENTER);
  text("Mid Point",tloc+100, yAxisEnd+60);
  
  //Save plot as an image
  save("plot_"+outputFileName+".jpg");
}

public String getFunction(int c){
  switch (c) {
    case 0:
      return "dx/dt = cos(t)";
    case 1:
      return "dx/dt = 2*t*cos(t*t)";      
    case 2:
      return "dx/dt = 2";      
    case 3:
      return "dx/dt = 2*t";      
    case 4:
      return "dx/dt = t*t*t";      
    case 5:
      return "dx/dt = x";      
    case 6:
      return "dx/dt = sin(t) + t*cos(t)";      
    default:
      return "none";      
    }
}

void dottedLine(float x1, float y1, float x2, float y2, float steps){
 for(int i=0; i<=steps; i++) {
   float x = lerp(x1, x2, i/steps);
   float y = lerp(y1, y2, i/steps);
   noStroke();
   ellipse(x, y,5,5);
 }
}
