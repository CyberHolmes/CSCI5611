//

static int n = 60; //number of cells
float dx = 600.0/n; //500 pixels long
float g = 9.8; //???
float volume;
float dt = 0.01; //update rate

float h[] = new float[n]; //Height
float hu[] = new float[n]; //Momentum
float dhdt[] = new float[n]; //Height
float dhudt[] = new float [n]; //Momentum
//Midpoint helpers
float h_mid[] = new float[n]; //Height
float hu_mid[] = new float[n]; //Momentum
float dhdt_mid[] = new float[n]; //Height
float dhudt_mid[] = new float [n]; //Momentum

//Boundary condition switch
boolean periodic = true;
boolean free = false;
boolean reflective = false;

void update(float dt){
  //Compute midpoint heights and momentums
  for (int i=0; i<n-1; i++){
    h_mid[i] = (h[i+1]+h[i])/2;
    hu_mid[i] = (hu[i+1]+hu[i])/2;
  }
  //Update dhdt_mid and dhudt_mid based on SWE
  for (int i=0; i<n-1; i++){
    //Compute dhdt_mid
    float dhudx_mid = (hu[i+1]-hu[i])/dx;
    dhdt_mid[i] = -dhudx_mid;
    //Compute dhu/dt (mid)
    float dhu2dx_mid = (sq(hu[i+1])/h[i+1]-sq(hu[i])/h[i])/dx;
    float dgh2dx_mid = g*(sq(h[i+1])-sq(h[i]))/dx;
    dhudt_mid[i] = -(dhu2dx_mid + .5*dgh2dx_mid);
  }
  //Integrate midpoint
  for (int i=0; i<n-1; i++){
    h_mid[i] += dhdt_mid[i]*dt/2;
    hu_mid[i] += dhudt_mid[i]*dt/2;
  }
  //Update dhdt and dhudt based on SWE with midpoints
  for (int i=1; i<n-1; i++){
    //Compute dhdt
    float dhudx = (hu_mid[i] - hu_mid[i-1])/dx;
    dhdt[i] = -dhudx;
    
    //Compute dhu/dt
    float dhu2dx = (sq(hu_mid[i])/h_mid[i] - sq(hu_mid[i-1])/h_mid[i-1])/dx;
    float dgh2dx = g*(sq(h_mid[i])-sq(h_mid[i-1]))/dx;
    dhudt[i] = -(dhu2dx +.5*dgh2dx);
  }
  //Ingegrate heights and momentum
  float new_volume = 0;
  for (int i=1; i<n-1; i++){
    h[i] += dhdt[i]*dt;
    hu[i] += dhudt[i]*dt;
    new_volume += h[i];
  }
  //normalizing volume
  if (abs(new_volume-volume)>10){
  for (int i=1; i<n-1; i++){
    h[i] = h[i]*volume/new_volume;
  }
  }
  //Boundary Update: Periodic
  if (periodic) {
  h[0]=h[n-2];
  h[n-1]=h[1];
  hu[0]=hu[n-2];
  hu[n-1]=hu[1];
  }
  //Boundary Update: Free
  if (free) {
  h[0]=h[1];
  h[n-1]=h[n-2];
  hu[0]=hu[1];
  hu[n-1]=hu[n-2];
  }
  //Boundary Update: Reflective
  if (reflective) {
  h[0]=h[1];
  h[n-1]=h[n-2];
  hu[0]=hu[1];
  hu[n-1]=hu[n-2];
  }
}

void setup(){
  size(600,500);
  background(0);
  //Set up initial values
  setupInitialValue();
  noStroke();
  fill(0,0,255);
  float a = h[0]+(h[0]-h[1])/2;
  for (int i=0; i<n-1; i++){
    float b = (h[i]+h[i+1])/2;
    beginShape();
    vertex(dx*i,height-a);
    vertex(dx*(i+1)+1,height-b);
    vertex(dx*(i+1)+1,height);
    vertex(dx*i,height);
    endShape(CLOSE); 
    a = b;
  }
  beginShape();
  vertex(dx*(n-1),height-a);
  vertex(width,height-h[n-1]);
  vertex(width,height);
  vertex(dx*(n-1),height);
  endShape(CLOSE);
}
void setupInitialValue(){
  volume = 0;
  for (int i=0; i<n; i++){
    h[i]=400-log(i+1)*50;
    
    //h[i]=random(200,280);
    hu[i]=0;
    volume += h[i];
  }
}

void draw(){
  background(0);
  noStroke();
  fill(0,0,255);  
  update(1/frameRate);
  float a = h[0]+(h[0]-h[1])/2;
  for (int i=0; i<n-1; i++){
    float b = (h[i]+h[i+1])/2;
    //update(dt);
    beginShape();
    vertex(dx*i,height-a);
    vertex(dx*(i+1)+1,height-b);
    vertex(dx*(i+1)+1,height);
    vertex(dx*i,height);
    endShape(CLOSE); 
    a = b;
  }
  beginShape();
  vertex(dx*(n-1),height-a);
  vertex(width,height-h[n-1]);
  vertex(width,height);
  vertex(dx*(n-1),height);
  endShape(CLOSE);
  println("frameRate="+frameRate);
}

void keyPressed()
{
  if (key == '1') {
    println("Switch boundary condition to periodic.");
    periodic = true; free = false; reflective = false;
  }
  if (key == '2') {
    println("Switch boundary condition to free.");
    periodic = false; free = true; reflective = false;
  }
  if (key == '3') {
    println("Switch boundary condition to reflective.");
    periodic = false; free = false; reflective = true;
  }  
}
void keyReleased()
{
  if (key == 'r'){
    println("Reseting the System.");
    setupInitialValue();
    //periodic = true; free = false; reflective = false;
  }
}
