static int Nx = 50, Ny=50, Nz=50; //number of grids in horizontal and vertical direction
//int N = 50;
static int M = 4; //number of pixels in each grid
float Sx = Nx*M, Sy = Ny*M, Sz = Nz*M;
float dt = 0.1; //time step
float VyMax = 1;

Fluid fluid;
float t=0;

float zStart = -600;
float xStart = -120;
float yStart = -120;

boolean windEnable = false;
PShape log;
float logX = Nx/2*M+xStart,logY = Ny*M+yStart,logZ = Nz/2*M+zStart;

Camera camera;

void settings(){
  size((Nx)*M+1000,(Nx)*M+800, P3D);
}

void setup(){
  camera = new Camera();
  fluid = new Fluid(0.00005,0.000001);
  log = loadShape("WoodLog.obj");
}

void draw(){
  println(frameRate);
  camera.Update(1/frameRate);
  background(255); 
  specular(120, 120, 180);  //Setup lights… 
  ambientLight(200,200,200);   //More light…  
  lightSpecular(255,255,255); shininess(10);  //More light…
  directionalLight(220, 220, 255, -1, 1, -1); //More light…
  //Add smoke source
  int cx = int(Nx/2);
  int cy = int(Ny-2);
  int cz = int(Nz/2);
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
  pushMatrix();
  noStroke();
  fill(#6a4940);
  translate(logX, logY, logZ);
  scale(35);
  rotateY(PI/4);
  rotateZ(PI);
  shape(log);
  rotateY(PI/2);
  shape(log);
  popMatrix();
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
  vertex(0, Sy, -0);
  vertex(Sx, Sy, -0);
  vertex(Sx, Sy, Sz);
  vertex(0, Sy, Sz);
  endShape(CLOSE);
  noFill();
  beginShape();
  vertex(0, 0, -0);
  vertex(Sx, 0, -0);
  vertex(Sx, 0, Sz);
  vertex(0, 0, Sz);
  endShape(CLOSE);
  beginShape();
  vertex(Sx, 0, -0);
  vertex(Sx, Sy, -0);
  vertex(Sx, Sy, Sz);
  vertex(Sx, 0, Sz);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, -0);
  vertex(0, Sy, -0);
  vertex(0, Sy, Sz);
  vertex(0, 0, Sz);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, Sz);
  vertex(0, Sy, Sz);
  vertex(Sx, Sy, Sz);
  vertex(Sx, 0, Sz);
  endShape(CLOSE);
  beginShape();
  vertex(0, 0, Sz);
  vertex(0, Sy, Sz);
  vertex(Sx, Sy, Sz);
  vertex(Sx, 0, Sz);
  endShape(CLOSE);
  popMatrix();
}
