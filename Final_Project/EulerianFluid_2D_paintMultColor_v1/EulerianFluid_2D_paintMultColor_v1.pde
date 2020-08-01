
static int M = 6; //number of pixels in each grid
static int Nx = int(1024/M), Ny=int(824/M); //number of grids in horizontal and vertical direction
float dt = 0.01; //time step
float viscosity = 0.0010, diffusionRate = 0.0000001;
float viscosityMax = 0.8, diffusionRateMax = 0.2;
float rateIncreaseFactor = 1;
boolean windEnable = false;
boolean showDensity = false; //show fluid density at mouse position

Fluid fluid;
PFont font;

int colorChoice =0; //brush color
static int brushSizeMin = 0, brushSizeMax = int(30/M);
int brushSize = 4;
float[] baseColor = new float[3]; //background color

void settings(){
  size((Nx)*M,(Ny)*M);
}

void setup(){
  fluid = new Fluid(diffusionRate,viscosity);
  font = loadFont("Calibri-40.vlw");
  baseColor[0]=135;//1;//50; //250;
  baseColor[1]=206;//200;//205;//215;
  baseColor[2]=235;//94;//50;//0;
}

void draw(){
  println(frameRate);
  //background(0);
  String txt = "Viscosity: "+nf(viscosity,0,5)+", Diffusion: "+nf(diffusionRate,0,6);
  String txt2 = "Background: "+nf(baseColor[0],0,0)+", "+nf(baseColor[1],0,0)+", "+nf(baseColor[2],0,0);
  int cx = int(mouseX/M), cy = int(mouseY/M);  
  if (windEnable) {fluid.addWind();}
  fluid.dens_step();
  fluid.vel_step();
  fluid.show();
  //fluid.showFlow();
  textFont(font);
  textSize(40);
  fill(255-baseColor[0],255-baseColor[1],255-baseColor[2],204);
  text(txt,1,40);
  text(txt2,1,80);
  String txt4 = "BrushSize: "+(brushSize*2+1)*M;
  text(txt4, width*0.7,40);
  if (showDensity){
  String txt3 = nf((fluid.dens_r[IX(cx,cy)]+baseColor[0]),0,0)+", "
          +nf((fluid.dens_g[IX(cx,cy)]+baseColor[1]),0,0)+", "
          +nf((fluid.dens_b[IX(cx,cy)]+baseColor[2]),0,0);
  //String txt3 = nf((fluid.dens_r[IX(cx,cy)]),0,0)+", "
  //        +nf((fluid.dens_g[IX(cx,cy)]),0,0)+", "
  //        +nf((fluid.dens_b[IX(cx,cy)]),0,0);
  text(txt3,1,height-40);
  }
}

void mousePressed(){
  int cx = int(mouseX/M), cy = int(mouseY/M);
  float val = 255;
    for (int i = -brushSize; i <= brushSize; i++) {
      for (int j = -brushSize; j <= brushSize; j++) {
        fluid.add_source(cx+i, cy+j, colorChoice, val);
        fluid.add_velocity(cx, cy, random(0.05,0.2), random(0.05,0.2) );
      }
    }
}

void mouseDragged(){
  int cx = int(mouseX/M), cy = int(mouseY/M),cx0,cy0;
  float f = 0.02;
  float val = 255;
  //if (mouseButton == LEFT){ 
    for (int i = -brushSize; i <= brushSize; i++) {
      for (int j = -brushSize; j <= brushSize; j++) {
        cx0=cx+i; cy0=cy+j;
        fluid.add_source(cx0, cy0, colorChoice, val);     
        fluid.add_velocity(cx, cy, (mouseX-pmouseX)*f, (mouseY-pmouseY)*f );
      }
    }
  //} else {
  //  for (int i = -brushSize; i <= brushSize; i++) {
  //    for (int j = -brushSize; j <= brushSize; j++) {        
  //      cx0=cx+i; cy0=cy+j;
  //      fluid.add_source(cx0, cy0, colorChoice, 0);
  //      fluid.add_velocity(cx, cy, (mouseX-pmouseX)*f, (mouseY-pmouseY)*f );
  //    }
  //  }
  //}
}

void keyPressed(){
  if (key == 'r' /*&& keyCode == CONTROL*/){
    fluid = new Fluid(diffusionRate,viscosity);    
  }
  if (key =='f' /*&& keyCode == CONTROL*/){fluid.fade(1);}
  if (key == ' ') windEnable = true;
  if ( keyCode == LEFT )  diffusionRate -= 0.00001*rateIncreaseFactor;
  if ( keyCode == RIGHT ) diffusionRate += 0.00001*rateIncreaseFactor;
  if ( keyCode == UP )    viscosity += 0.0001*rateIncreaseFactor;
  if ( keyCode == DOWN )  viscosity -= 0.0001*rateIncreaseFactor;  
  diffusionRate = constrain(diffusionRate,0.000001,diffusionRateMax);
  viscosity = constrain(viscosity,0.000001,viscosityMax);
  fluid.Kdiff = diffusionRate; fluid.Kvisc = viscosity;
  if ( key == '1' ) colorChoice =0;
  if ( key == '2' ) colorChoice =1;
  if ( key == '3' ) colorChoice =2;
  if ( key == 'i' ) baseColor[0] = (baseColor[0] + 1) % 254;
  if ( key == 'l' ) baseColor[1] = (baseColor[1] + 1) % 254;
  if ( key == 'o' ) baseColor[2] = (baseColor[2] + 1) % 254;
  if ( key == 'k' ) baseColor[0] = (baseColor[0] - 1)>1? (baseColor[0] - 1):254;
  if ( key == 'j' ) baseColor[1] = (baseColor[1] - 1)>1? (baseColor[1] - 1):254;
  if ( key == 'u' ) baseColor[2] = (baseColor[2] - 1)>1? (baseColor[2] - 1):254;
  if ( key == 'w' ) brushSize = min(brushSize+1,brushSizeMax);
  if ( key == 'q' ) brushSize = max(brushSize-1,brushSizeMin);
  if ( key == 's' ) showDensity = !showDensity;
  if (keyCode == SHIFT) {rateIncreaseFactor = 10;}
  for (int i=0; i<3; i++){
    if (baseColor[i]==0) baseColor[i]=1;
  }
}

void keyReleased(){
  if (key == ' ') windEnable = false;
  if (keyCode == SHIFT) {rateIncreaseFactor = 1;}
}
