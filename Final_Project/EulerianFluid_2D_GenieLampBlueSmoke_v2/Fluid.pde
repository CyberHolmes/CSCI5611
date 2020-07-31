//Convert 2d to 1d
int IX(int i, int j) {
  i=constrain(i,0,Nx+1); j=constrain(j,0,Ny+1);
  return i + (Nx+2)*j;};
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
  float[] dens, dens_prev;
  float[] val, val_prev;
  float Kdiff, Kvisc; //diffusion factor and viscosity factor
  
  Fluid(float Kd, float Kv){
    size = (Nx+2)*(Ny+2);
    u = new float[size];
    v = new float[size];
    u_prev = new float[size];
    v_prev = new float[size];
    dens = new float[size];
    dens_prev = new float[size];
    Kdiff = Kd;
    Kvisc = Kv;
    //val = new float[size];
    //val_prev = new float[size];
  }
  
  void add_source(int x, int y, float a){
    dens[IX(x,y)] = a;
  } 
  
  void dens_step () {
    //add_source ( x, y, a);
    SWAP ( dens_prev, dens ); diffuse ( 0, dens, dens_prev, Kdiff);
    SWAP ( dens_prev, dens ); advect ( 0, dens, dens_prev, u, v);
  }
  
  void vel_step ()
  {
  //add_source ( N, u, u_prev, dt ); add_source ( N, v, v_prev, dt );
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
    //colorMode(HSB, 255);
    //colorMode(RGB,100);
    for (int i = 0; i < Nx; i++) {
      for (int j = 0; j < Ny; j++) {
        float d = dens[IX(i, j)];
        if (d<20) continue;
        float x = i * M;
        float y = j * M;
        fill(#00ccff,d); //#00ccff  #0acbee
        noStroke();
        square(x, y, M);
      }
    }
  }
  void fade(float a) {
    for (int i = 0; i < size; i++) {
      float d = dens[i];
      dens[i] = constrain(d-a, 0, 255);
    }
  }
  float getTotalDens(){
    float res = 0;
    for (int i=0;i<size;i++){
      res += dens[i];
    }
    return res;
  }
  void addWind(){
    float offset = 0;
    for (int i=0;i<size;i++){
      float windx = map(noise(offset, offset), 0, 1, 0, 0.02);
      float windy = map(noise(offset+5000, offset+5000), 0, 1, -0.05, 0.05);
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
//    x[IX(0 ,i)] = b==1 ? x[IX(Nx,i)] : -x[IX(Nx,i)];
//    x[IX(Nx+1,i)] = b==1 ? x[IX(1,i)] : -x[IX(1,i)];
//  }
//  for ( i=1 ; i<=Nx ; i++ ) {
//    x[IX(i,0 )] = b==2 ? x[IX(i,Ny)] : -x[IX(i,Ny)];
//    x[IX(i,Ny+1)] = b==2 ? x[IX(i,1)] : -x[IX(i,1)];
//  }
//  x[IX(0 ,0 )] = 0.5*(x[IX(1,Ny+1)]+x[IX(0 ,Ny )]);
//  x[IX(0 ,Ny+1)] = 0.5*(x[IX(1,0 )]+x[IX(0 ,1)]);
//  x[IX(Nx+1,0 )] = 0.5*(x[IX(Nx,Ny+1)]+x[IX(Nx+1,Ny )]);
//  x[IX(Nx+1,Ny+1)] = 0.5*(x[IX(Nx,0 )]+x[IX(Nx+1,1)]);
//}
