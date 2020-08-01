
static int M = 4; //number of pixels in each grid
static int Nx = int(1024/M), Ny=int(824/M); //number of grids in horizontal and vertical direction
float dt = 0.1; //time step

Fluid fluid;
PImage lamp;
int numGenies = 31;
PImage[] genies = new PImage[numGenies];
Vec2 lampPos, geniePos, smokePos;
boolean showGenie = false;
int counter = 0, genieToggle = 0;
boolean windEnable = false;

void settings(){
  size((Nx+1)*M,(Ny+1)*M);
}

void setup(){
  fluid = new Fluid(0.00001,0.00001);
  lamp = loadImage("pngwave500.png");
  for (int i=0; i<numGenies; i++){
    genies[i] = loadImage("hiclipart_genie"+(100+i*10)+".png");
  }
  lampPos = new Vec2(width*0.3, height-300);
  geniePos = new Vec2(lampPos.x-50, lampPos.y-500);//height*0.05);
  smokePos = new Vec2(lampPos.x+116, lampPos.y+110);
}

void draw(){
  println(frameRate);
  background(0);
  if (showGenie){
    genieToggle = min(int(counter/frameRate*30),(numGenies-1));
    geniePos = new Vec2(lampPos.x-100+(numGenies-genieToggle)*5, lampPos.y-320+(numGenies-genieToggle)*10);
    if (counter>(frameRate*(numGenies+30)/30)){counter=0;showGenie=false;fluid=new Fluid(0.00001,0.00001);}
    drawGenie(genieToggle);counter++;   
    fluid.fade(0.6);
  }else{
  generateSmoke();
  }
  if (windEnable) {fluid.addWind();}
  fluid.dens_step();
  fluid.vel_step();
  //Draw lamp
  pushMatrix();
  translate(lampPos.x,lampPos.y);
  image(lamp,0,0);
  popMatrix();
  if (fluid.getTotalDens() > fluid.dens.length*80){showGenie = true;}
  fluid.show();
  //fluid.showFlow();
  
  
}

void drawGenie(int n){
  pushMatrix();
  translate(geniePos.x,geniePos.y);
  image(genies[n],0,0);
  popMatrix();
}

void generateSmoke(){
  //Add smoke source
  int cx = int(smokePos.x/M);
  int cy = int(smokePos.y/M);
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      fluid.add_source(cx+i, cy+j, random(80, 255));
    }
  }
  for (int i = 0; i < 2; i++) {
    fluid.add_velocity(cx, cy, random(-0.08,0.08), -random(0.05,0.2));
  }
}

void mousePressed(){
  int cx = int(mouseX/M), cy = int(mouseY/M);
  if (mouseButton == LEFT){ 
    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        fluid.add_source(cx+i, cy+j, 100);
        fluid.add_velocity(cx, cy, random(-0.02,0.02), -random(0.05,0.2));
      }
    }
  } else {
    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        fluid.add_source(cx+i, cy+j, 0);
      }
    }
  }
}

void mouseDragged(){
  int cx = int(mouseX/M), cy = int(mouseY/M),cx0,cy0;
  float f = 0.02;
  if (mouseButton == LEFT){ 
    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        cx0=cx+i; cy0=cy+j;
        fluid.add_source(cx0, cy0, 150);
        fluid.add_velocity(cx, cy, (mouseX-pmouseX)*f, -random(0.05,0.2)+(mouseY-pmouseY)*f );
      }
    }
  } else {
    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {        
        cx0=cx+i; cy0=cy+j;
        fluid.add_source(cx0, cy0, 0);
        fluid.add_velocity(cx, cy, (mouseX-pmouseX)*f, (mouseY-pmouseY)*f );
      }
    }
  }
}

void keyPressed(){
  if (key == 'r'){
    showGenie = true;
  }
  if (key == ' ') {windEnable = true;}
}

void keyReleased(){
  if (key == ' ') {windEnable = false;}
}
