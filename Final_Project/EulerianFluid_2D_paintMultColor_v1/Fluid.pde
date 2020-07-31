//Convert 2d to 1d
int IX(int i, int j) {
  i=constrain(i,0,Nx+1); j=constrain(j,0,Ny+1);
  int res=i + (Nx+2)*j;
  return res;}
//Swap two arrays
void SWAP(float[] x0, float[] x) {
  float tmp;
  for (int i=0;i<x0.length;i++){
    tmp = x0[i];
    x0[i]=x[i];
    x[i]=tmp;
  }
}

class Fluid{
  int size;
  float[] u, v, u_prev, v_prev;
  float[] dens_r, dens_r_prev,dens_g,dens_g_prev,dens_b,dens_b_prev;
  float[] val, val_prev;
  float Kdiff, Kvisc; //diffusion factor and viscosity factor
  
  Fluid(float Kd, float Kv){
    size = (Nx+2)*(Ny+2);
    u = new float[size];
    v = new float[size];
    u_prev = new float[size];
    v_prev = new float[size];
    dens_r = new float[size];
    dens_r_prev = new float[size];
    dens_g = new float[size];
    dens_g_prev = new float[size];
    dens_b = new float[size];
    dens_b_prev = new float[size];
    Kdiff = Kd;
    Kvisc = Kv;
  }
  
  void add_source(int x, int y, int c, float a){
    int idx = IX(x,y);
    switch (c){
      case 0: 
        dens_r[idx] = (a-baseColor[0]) % 255;
        dens_g[idx] = (0-baseColor[1]) % 255;
        dens_b[idx] = (0-baseColor[2]) % 255;
        break;
      case 1: 
        dens_r[idx] = (0-baseColor[0]) % 255;
        dens_g[idx] = (a-baseColor[1]) % 255;
        dens_b[idx] = (0-baseColor[2]) % 255;
        break;
      default:
        dens_r[idx] = (0-baseColor[0]) % 255;
        dens_g[idx] = (0-baseColor[1]) % 255;
        dens_b[idx] = (a-baseColor[2]) % 255;
        break;
    }    
  } 
  
  void dens_step () {
    SWAP ( dens_r_prev, dens_r ); diffuse ( 0, dens_r, dens_r_prev, Kdiff);
    SWAP ( dens_r_prev, dens_r ); advect ( 0, dens_r, dens_r_prev, u, v);
    SWAP ( dens_g_prev, dens_g ); diffuse ( 0, dens_g, dens_g_prev, Kdiff);
    SWAP ( dens_g_prev, dens_g ); advect ( 0, dens_g, dens_g_prev, u, v);
    SWAP ( dens_b_prev, dens_b ); diffuse ( 0, dens_b, dens_b_prev, Kdiff);
    SWAP ( dens_b_prev, dens_b ); advect ( 0, dens_b, dens_b_prev, u, v);
  }
  
  void vel_step ()
  {
    SWAP ( u_prev, u ); diffuse (1, u, u_prev,Kvisc);
    SWAP ( v_prev, v ); diffuse (2, v, v_prev,Kvisc);
    project (u, v, u_prev, v_prev );
    SWAP ( u_prev, u ); SWAP ( v_prev, v );
    advect ( 1, u, u_prev, u_prev, v_prev); advect ( 2, v, v_prev, u_prev, v_prev);
    project ( u, v, u_prev, v_prev );
  }
  
  void add_velocity(int x, int y, float du, float dv) {
    int index = IX(x, y);
    u[index] += du;
    v[index] += dv;
  }

  void show() {    
    for (int i = 0; i < Nx; i++) {
      for (int j = 0; j < Ny; j++) {
        float x = i * M;
        float y = j * M;
        int idx = IX(i, j);
        float r = dens_r[idx];
        float g = dens_g[idx];
        float b = dens_b[idx];
        //fill(constrain(r+100,0,255),constrain(g,0,255),constrain(b+,0,255));
        fill(r+baseColor[0],g+baseColor[1],b+baseColor[2]);
        noStroke();
        square(x, y, M);
      }
    }
  }
  void fade(float a) {
    for (int i = 0; i < size; i++) {
      float r = dens_r[i];
      float g = dens_g[i];
      float b = dens_b[i];
      dens_r[i] = max(r-a, 0); //constrain(r-a, 0, 255);
      dens_g[i] = max(r-a, 0); //constrain(r-a, 0, 255);
      dens_b[i] = max(r-a, 0); //constrain(r-a, 0, 255);
    }
  }
  void showFlow() {

    for (int i = 0; i < Nx; i++) {
      for (int j = 0; j < Ny; j++) {
        float x = i * M;
        float y = j * M;
        float vx = u[IX(i, j)];
        float vy = v[IX(i, j)];
        stroke(0);
        strokeWeight(1);
        if (!(abs(vx) < 0.1 && abs(vy) <= 0.1)) {
          line(x, y, x+vx*M, y+vy*M );
        }
      }
    }
  }
  void addWind(){
    float offset = 0;
    for (int i=0;i<size;i++){
      float windx = map(noise(offset, offset), 0, 1, -5, 10);
      float windy = map(noise(offset+5000, offset+5000), 0, 1, -5, 5);
      u[i] += windx*dt;
      v[i] += windy*dt;
      offset += 0.1;
    }
  }
}

void diffuse (int b, float[]  x, float[]  x0, float diff)
{
  int i, j, k;
  float a=dt*diff*Nx*Ny;
  for ( k=0 ; k<20 ; k++ ) {
    for ( i=1 ; i<=Nx ; i++ ) {
      for ( j=1 ; j<=Ny ; j++ ) {
        x[IX(i,j)] = (x0[IX(i,j)] + a*(x[IX(i-1,j)]+x[IX(i+1,j)]+
         x[IX(i,j-1)]+x[IX(i,j+1)]))/(1+4*a);
      }
    }
    set_bnd (b, x );
  }
}

void advect ( int b, float[]  d, float[]  d0, float[]  u, float[]  v)
{
  int i, j, i0, j0, i1, j1;
  float x, y, s0, t0, s1, t1, dt0x, dt0y;
  dt0x = dt*Nx; dt0y = dt*Ny;
  for ( i=1 ; i<=Nx ; i++ ) {
    for ( j=1 ; j<=Ny ; j++ ) {
      x = i-dt0x*u[IX(i,j)]; y = j-dt0y*v[IX(i,j)];
      if (x<0.5) x=0.5; if (x>Nx+0.5) x=Nx+ 0.5; i0=(int)x; i1=i0+1;
      if (y<0.5) y=0.5; if (y>Ny+0.5) y=Ny+ 0.5; j0=(int)y; j1=j0+1;
      s1 = x-i0; s0 = 1-s1; t1 = y-j0; t0 = 1-t1;
      d[IX(i,j)] = s0*(t0*d0[IX(i0,j0)]+t1*d0[IX(i0,j1)])+
       s1*(t0*d0[IX(i1,j0)]+t1*d0[IX(i1,j1)]);
    }
  }
  set_bnd (b, d );
}

void project ( float[]  u, float[]  v, float[]  p, float[]  div )
{
  int i, j, k;
  float hx, hy;
  hx = 1.0/Nx; hy = 1.0/Ny;
  for ( i=1 ; i<=Nx ; i++ ) {
    for ( j=1 ; j<=Ny ; j++ ) {
      div[IX(i,j)] = -0.5*hx*(u[IX(i+1,j)]-u[IX(i-1,j)])
        -0.5*hy*(v[IX(i,j+1)]-v[IX(i,j-1)]);
      p[IX(i,j)] = 0;
    }
  }
  set_bnd (0, div ); set_bnd (0, p );
  for ( k=0 ; k<20 ; k++ ) {
    for ( i=1 ; i<=Nx ; i++ ) {
      for ( j=1 ; j<=Ny ; j++ ) {
        p[IX(i,j)] = (div[IX(i,j)]+p[IX(i-1,j)]+p[IX(i+1,j)]+
         p[IX(i,j-1)]+p[IX(i,j+1)])/4;
      }
    }
    set_bnd (0, p );
  }
  for ( i=1 ; i<=Nx ; i++ ) {
    for ( j=1 ; j<=Ny ; j++ ) {
      u[IX(i,j)] -= 0.5*(p[IX(i+1,j)]-p[IX(i-1,j)])/hx;
      v[IX(i,j)] -= 0.5*(p[IX(i,j+1)]-p[IX(i,j-1)])/hy;
    }
  }
  set_bnd (1, u ); set_bnd (2, v );
}

void set_bnd ( int b, float[]  x )
{
  int i;
  for ( i=1 ; i<=Ny ; i++ ) {
    x[IX(0 ,i)] = b==1 ? -x[IX(1,i)] : x[IX(1,i)];
    x[IX(Nx+1,i)] = b==1 ? -x[IX(Nx,i)] : x[IX(Nx,i)];
  }
  for ( i=1 ; i<=Nx ; i++ ) {
    x[IX(i,0 )] = b==2 ? -x[IX(i,1)] : x[IX(i,1)];
    x[IX(i,Ny+1)] = b==2 ? -x[IX(i,Ny)] : x[IX(i,Ny)];
  }
  x[IX(0 ,0 )] = 0.5*(x[IX(1,0 )]+x[IX(0 ,1)]);
  x[IX(0 ,Ny+1)] = 0.5*(x[IX(1,Ny+1)]+x[IX(0 ,Ny )]);
  x[IX(Nx+1,0 )] = 0.5*(x[IX(Nx,0 )]+x[IX(Nx+1,1)]);
  x[IX(Nx+1,Ny+1)] = 0.5*(x[IX(Nx,Ny+1)]+x[IX(Nx+1,Ny )]);
}

//void set_bnd ( int b, float[]  x )
//{
//  int i;
//  for ( i=1 ; i<=Ny ; i++ ) {
//    x[IX(0 ,i)] = b==1 ? -x[IX(Nx,i)] : x[IX(Nx,i)];
//    x[IX(Nx+1,i)] = b==1 ? -x[IX(1,i)] : x[IX(1,i)];
//  }
//  for ( i=1 ; i<=Nx ; i++ ) {
//    x[IX(i,0 )] = b==2 ? x[IX(i,Ny)] : x[IX(i,Ny)];
//    x[IX(i,Ny+1)] = b==2 ? x[IX(i,1)] : x[IX(i,1)];
//  }
//  x[IX(0 ,0 )] = 0.5*(x[IX(1,Ny+1)]+x[IX(0 ,Ny )]);
//  x[IX(0 ,Ny+1)] = 0.5*(x[IX(1,0 )]+x[IX(0 ,1)]);
//  x[IX(Nx+1,0 )] = 0.5*(x[IX(Nx,Ny+1)]+x[IX(Nx+1,Ny )]);
//  x[IX(Nx+1,Ny+1)] = 0.5*(x[IX(Nx,0 )]+x[IX(Nx+1,1)]);
//}
