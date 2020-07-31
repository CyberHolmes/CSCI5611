//static int Nx = 20, Ny=15, Nz=15; //number of grids in horizontal and vertical direction
int N = 50;
static int M = 4; //number of pixels in each grid
float S = N*M;
float dt = 0.1; //time step
float VyMax = 1;

Fluid fluid;
float t=0;

float zStart = -600;
float xStart = -120;
float yStart = -120;

boolean windEnable = false;

Camera camera;

void settings(){
  size((N)*M+1000,(N)*M+800, P3D);
}

void setup(){
  camera = new Camera();
  fluid = new Fluid(0.00005,0.000001);
}

void draw(){
  println(frameRate);
  camera.Update(1/frameRate);
  background(255);  
  //Add smoke source
  int cx = int(N/2);//smokePos.x/M);
  int cy = int(N-2);//smokePos.y/M);
  int cz = int(N/2);//smokePos.z/M);
  for (int i = -6; i <= 6; i++) {
    for (int j = 0; j <= 5; j++) {
      for (int k = -6; k <= 6; k++) {
      fluid.addDensity(cx+i, cy+j, cz+k, random(180, 255)); //random(80, 200)
      }
    }
  }
  if (windEnable) {fluid.addWind();}
  fluid.update();
  fluid.show();  
  fluid.fade(0.1);
  drawPlatForm();
}

void keyPressed(){
  camera.HandleKeyPressed();
  if (key == 'r'){
    fluid = new Fluid(0.00005,0.000001);
  }
  if (key == ' ') {windEnable = true;}
}

void keyReleased(){
  camera.HandleKeyReleased();
  if (key == ' ') {windEnable = false;}
}

void drawPlatForm(){
  pushMatrix();
  translate(xStart, yStart, zStart);
  stroke(0);
  strokeWeight(1);
  fill(#00ab66, 50);
  beginShape();
  vertex(0, S, -0);
  vertex(S, S, -0);
  vertex(S, S, S);
  vertex(0, S, S);
  endShape(CLOSE);
  noFill();
  beginShape();
  vertex(0, 0, -0);
  vertex(S, 0, -0);
  vertex(S, 0, S);
  vertex(0, 0, S);
  endShape(CLOSE);
  beginShape();
  vertex(S, 0, -0);
  vertex(S, S, -0);
  vertex(S, S, S);
  vertex(S, 0, S);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, -0);
  vertex(0, S, -0);
  vertex(0, S, S);
  vertex(0, 0, S);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, S);
  vertex(0, S, S);
  vertex(S, S, S);
  vertex(S, 0, S);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, S);
  vertex(0, S, S);
  vertex(S, S, S);
  vertex(S, 0, S);
  endShape(CLOSE);
  popMatrix();
}
