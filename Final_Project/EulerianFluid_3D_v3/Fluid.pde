//Most functions in 3D Fluid are adapted from Mike Ash's Fluid Simulation For Dummies
//, which is based on Jos Stam's Real_Time Fluid Dynamics for Games
int IX(int i, int j, int k) {
  i=constrain(i,0,N-1); j=constrain(j,0,N-1);k=constrain(k,0,N-1);
  return i + (N)*j + (N)*(N)*k;};

class Fluid{
  int size;
    float diff;
    float visc;
    
    float[] dens0;
    float[] dens;
    
    float[] Vx;
    float[] Vy;
    float[] Vz;

    float[] Vx0;
    float[] Vy0;
    float[] Vz0;
    
    Fluid(float Kd, float Kv) {
      size = N*N*N;
      diff = Kd;
      visc = Kv;
      
      dens0 = new float[size];
      dens = new float[size];
      Vx = new float[size];
      Vy = new float[size];
      Vz = new float[size];
      Vx0 = new float[size];
      Vy0 = new float[size];
      Vz0 = new float[size];      
    }
    
    void addDensity(int x, int y, int z, float a){
      dens[IX(x,y,z)]=a;
    }
    
    void addVelocity(int x, int y, int z, float dx, float dy, float dz){
      int idx = IX(x,y,z);
      Vx[idx] += dx;
      Vy[idx] += dy;
      Vz[idx] += dz;
    }
    
    void update(){
      for (int i=0; i<size; i++){
        if (dens[i]>30) {
          float dv=dens[i]/10000;
          Vy[i] -= dv; Vx[i] += dv*random(-0.8,0.8); Vz[i] += dv*random(-0.8,0.8);         
        }
        Vy[i] = min(Vy[i], VyMax);
        Vx[i] = min(Vx[i], VyMax);
        Vz[i] = min(Vz[i], VyMax);
      }
      diffuse(1, Vx0, Vx, visc, dt, 4);
      diffuse(2, Vy0, Vy, visc, dt, 4);
      diffuse(3, Vz0, Vz, visc, dt, 4);
      
      project(Vx0, Vy0, Vz0, Vx, Vy, 3);
      
      advect(1, Vx, Vx0, Vx0, Vy0, Vz0, dt);
      advect(2, Vy, Vy0, Vx0, Vy0, Vz0, dt);
      advect(3, Vz, Vz0, Vx0, Vy0, Vz0, dt);
      
      project(Vx, Vy, Vz, Vx0, Vy0, 3);
      
      diffuse(0, dens0, dens, diff, dt, 4);
      advect(0, dens, dens0, Vx, Vy, Vz, dt);
    }
    void show() {    
    //colorMode(HSB, 255);
    //colorMode(RGB,100);
    for (int k=0 ; k< N ; k++ ) {
     for (int j = 0; j < N; j++) {
      for (int i = 0; i < N; i++) {
        float d = dens[IX(i, j, k)];
        if (d<20) continue;
        float x = i * (M)+xStart;
        float y = j * (M)+yStart;
        float z = k * (M)+zStart;
        float r = d/85;
        float g = (d - 85)/85;
        float b = (d - 170)/85;
        pushMatrix();
        translate(x,y,z);
        noStroke(); 
        if (d>60){
          fill(r*255,g*255,b*255,d-20);        
        } else if (d>20) {
          fill(180,d+20);
        }
        box(M);
        popMatrix();
      }
     }
    }
  }
  void fade(float a) {
    for (int i = 0; i < size; i++) {
      float d = dens[i];
      dens[i] = constrain(d-a, 0, 255);
    }
  }
  void addWind(){
    float offset = 0;
    for (int i=0;i<size;i++){
      float windx = map(noise(offset, offset,offset), 0, 1, 0, 0.02);
      float windy = map(noise(offset+5000, offset+5000,offset), 0, 1, -0.05, 0.05);
      float windz = map(noise(offset+3000, offset+3000, offset), 0, 1, -0.05, 0.05);
      Vx[i] += windx*dt;
      Vy[i] += windy*dt;
      Vz[i] += windz*dt;
      offset += 0.1;
    }
  }
}

void set_bnd(int b, float[] x)
{
    for(int j = 1; j < N - 1; j++) {
        for(int i = 1; i < N - 1; i++) {
            x[IX(i, j, 0  )] = b == 3 ? -x[IX(i, j, 1  )] : x[IX(i, j, 1  )];
            x[IX(i, j, N-1)] = b == 3 ? -x[IX(i, j, N-2)] : x[IX(i, j, N-2)];
        }
    }
    for(int k = 1; k < N - 1; k++) {
        for(int i = 1; i < N - 1; i++) {
            x[IX(i, 0  , k)] = b == 2 ? -x[IX(i, 1  , k)] : x[IX(i, 1  , k)];
            x[IX(i, N-1, k)] = b == 2 ? -x[IX(i, N-2, k)] : x[IX(i, N-2, k)];
        }
    }
    for(int k = 1; k < N - 1; k++) {
        for(int j = 1; j < N - 1; j++) {
            x[IX(0  , j, k)] = b == 1 ? -x[IX(1  , j, k)] : x[IX(1  , j, k)];
            x[IX(N-1, j, k)] = b == 1 ? -x[IX(N-2, j, k)] : x[IX(N-2, j, k)];
        }
    }
    
    x[IX(0, 0, 0)]       = 0.33f * (x[IX(1, 0, 0)]
                                  + x[IX(0, 1, 0)]
                                  + x[IX(0, 0, 1)]);
    x[IX(0, N-1, 0)]     = 0.33f * (x[IX(1, N-1, 0)]
                                  + x[IX(0, N-2, 0)]
                                  + x[IX(0, N-1, 1)]);
    x[IX(0, 0, N-1)]     = 0.33f * (x[IX(1, 0, N-1)]
                                  + x[IX(0, 1, N-1)]
                                  + x[IX(0, 0, N)]);
    x[IX(0, N-1, N-1)]   = 0.33f * (x[IX(1, N-1, N-1)]
                                  + x[IX(0, N-2, N-1)]
                                  + x[IX(0, N-1, N-2)]);
    x[IX(N-1, 0, 0)]     = 0.33f * (x[IX(N-2, 0, 0)]
                                  + x[IX(N-1, 1, 0)]
                                  + x[IX(N-1, 0, 1)]);
    x[IX(N-1, N-1, 0)]   = 0.33f * (x[IX(N-2, N-1, 0)]
                                  + x[IX(N-1, N-2, 0)]
                                  + x[IX(N-1, N-1, 1)]);
    x[IX(N-1, 0, N-1)]   = 0.33f * (x[IX(N-2, 0, N-1)]
                                  + x[IX(N-1, 1, N-1)]
                                  + x[IX(N-1, 0, N-2)]);
    x[IX(N-1, N-1, N-1)] = 0.33f * (x[IX(N-2, N-1, N-1)]
                                  + x[IX(N-1, N-2, N-1)]
                                  + x[IX(N-1, N-1, N-2)]);
}

void lin_solve(int b, float[] x, float[] x0, float a, float c, int iter)
{
    float cRecip = 1.0 / c;
    for (int k = 0; k < iter; k++) {
        for (int m = 1; m < N - 1; m++) {
            for (int j = 1; j < N - 1; j++) {
                for (int i = 1; i < N - 1; i++) {
                    x[IX(i, j, m)] =
                        (x0[IX(i, j, m)]
                            + a*(    x[IX(i+1, j  , m  )]
                                    +x[IX(i-1, j  , m  )]
                                    +x[IX(i  , j+1, m  )]
                                    +x[IX(i  , j-1, m  )]
                                    +x[IX(i  , j  , m+1)]
                                    +x[IX(i  , j  , m-1)]
                           )) * cRecip;
                }
            }
        }
        set_bnd(b, x);
    }
}

void diffuse (int b, float[] x, float[] x0, float diff, float dt, int iter)
{
    float a = dt * diff * (N - 2) * (N - 2);
    lin_solve(b, x, x0, a, 1 + 6 * a, iter);
}

void project(float[] velocX, float[] velocY, float[] velocZ, float[] p, float[] div, int iter)
{
    for (int k = 1; k < N - 1; k++) {
        for (int j = 1; j < N - 1; j++) {
            for (int i = 1; i < N - 1; i++) {
                div[IX(i, j, k)] = -0.5f*(
                         velocX[IX(i+1, j  , k  )]
                        -velocX[IX(i-1, j  , k  )]
                        +velocY[IX(i  , j+1, k  )]
                        -velocY[IX(i  , j-1, k  )]
                        +velocZ[IX(i  , j  , k+1)]
                        -velocZ[IX(i  , j  , k-1)]
                    )/N;
                p[IX(i, j, k)] = 0;
            }
        }
    }
    set_bnd(0, div); 
    set_bnd(0, p);
    lin_solve(0, p, div, 1, 6, iter);
    
    for (int k = 1; k < N - 1; k++) {
        for (int j = 1; j < N - 1; j++) {
            for (int i = 1; i < N - 1; i++) {
                velocX[IX(i, j, k)] -= 0.5f * (  p[IX(i+1, j, k)]
                                                -p[IX(i-1, j, k)]) * N;
                velocY[IX(i, j, k)] -= 0.5f * (  p[IX(i, j+1, k)]
                                                -p[IX(i, j-1, k)]) * N;
                velocZ[IX(i, j, k)] -= 0.5f * (  p[IX(i, j, k+1)]
                                                -p[IX(i, j, k-1)]) * N;
            }
        }
    }
    set_bnd(1, velocX);
    set_bnd(2, velocY);
    set_bnd(3, velocZ);
}

void advect(int b, float[] d, float[] d0,  float[] velocX, float[] velocY, float[] velocZ, float dt)
{
    float i0, i1, j0, j1, k0, k1;
    
    float dtx = dt * (N - 2);
    float dty = dt * (N - 2);
    float dtz = dt * (N - 2);
    
    float s0, s1, t0, t1, u0, u1;
    float tmp1, tmp2, tmp3, x, y, z;
    
    int i, j, k;
    
    for(k = 1; k < N - 1; k++) {
        for(j = 1; j < N - 1; j++) { 
            for(i = 1; i < N - 1; i++) {
                tmp1 = dtx * velocX[IX(i, j, k)];
                tmp2 = dty * velocY[IX(i, j, k)];
                tmp3 = dtz * velocZ[IX(i, j, k)];
                x    = i - tmp1; 
                y    = j - tmp2;
                z    = k - tmp3;
                
                x= constrain(x, 0.5, N+0.5);
                y= constrain(y, 0.5, N+0.5);
                z= constrain(z, 0.5, N+0.5);
                i0 = floor(x); 
                i1 = i0 + 1;
                j0 = floor(y);
                j1 = j0 + 1; 
                k0 = floor(z);
                k1 = k0 + 1;
                
                s1 = x - i0; 
                s0 = 1 - s1; 
                t1 = y - j0; 
                t0 = 1 - t1;
                u1 = z - k0;
                u0 = 1 - u1;
                
                int i0i = int(i0);
                int i1i = int(i1);
                int j0i = int(j0);
                int j1i = int(j1);
                int k0i = int(k0);
                int k1i = int(k1);
                
                d[IX(i, j, k)] = 
                
                    s0 * ( t0 * (u0 * d0[IX(i0i, j0i, k0i)]
                                +u1 * d0[IX(i0i, j0i, k1i)])
                        +( t1 * (u0 * d0[IX(i0i, j1i, k0i)]
                                +u1 * d0[IX(i0i, j1i, k1i)])))
                   +s1 * ( t0 * (u0 * d0[IX(i1i, j0i, k0i)]
                                +u1 * d0[IX(i1i, j0i, k1i)])
                        +( t1 * (u0 * d0[IX(i1i, j1i, k0i)]
                                +u1 * d0[IX(i1i, j1i, k1i)])));
            }
        }
    }
    set_bnd(b, d);
}
