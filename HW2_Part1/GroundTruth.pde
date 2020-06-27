//Different functions to test with PDEs, both the derivative and the actual function

//TODO:
//  -Try: dx/dx = 2*t*cos(t*t)
//        dx/dt = 2
//        dx/dt = 2*t
//        dx/dt = t*t*t
//        dx/dt = x
//        dx/dt = sin(t) + t*cos(t) 
float dxdt(float t, float x){
  switch (c) {
    case 0:
      return cos(t);
    case 1:
      return 2*t*cos(t*t);
    case 2:
      return 2;
    case 3:
      return 2*t;
    case 4:
      return t*t*t;
    case 5:
      return x;
    case 6:
      return sin(t) + t*cos(t);
    default:
      return 0;
  }
}

//In practice we the derivative will typically be complex enough that we don't know the actual answer
//   but for this asignment, lets practice with simple functions we know the anti-derivative of.
//   note, do not worry about any constant shift here, it will be corrected in testing time
float actual(float t){
  switch (c) {
    case 0:
      return sin(t);
    case 1:
      return sin(t*t);
    case 2:
      return 2*t;
    case 3:
      return t*t;
    case 4:
      return pow(t,4)/4;
    case 5:
      return exp(t);
    case 6:
      return t*sin(t);
    default:
      return 0;
  }
}

//Return's a list of the actual values from t_start to t_end (also ignores shifts as the "actual" function)
ArrayList<Float> actualList(float t_start, int n_steps, float dt){
  ArrayList<Float> xVals = new ArrayList<Float>();
  float t = t_start;
  float x = actual(t);
  xVals.add(actual(t));
  for (int i = 0; i < n_steps; i++){
    t += dt;
    x = actual(t);
    xVals.add(x);
  }
  return xVals;
}
