# Readme #
## Achieved Elements in this Assignment:  
* Added midpoint algorithm to _Integrator.pde_  
* Added all 7 underlying functions to _GroundTruth.pde_  
* Added plotting codes to _HW2_Part1_v2.pde_  
* Added data file saving codes to _HW2_Part1_v2.pde_   
 

## To select which function to evaluate, set initial conditions, step size and number of steps:
#### Set corresponding global variables (line 13 through 23 in HW2_Part1)
>int c = 6; //Choosing functions  
>> //0: dx/dt=cos(t)  
>> //1: dx/dx = 2*t*cos(t^2)  
>> //2: dx/dt = 2  
>> //3: dx/dt = 2*t  
>> //4: dx/dt = t^3  
>> //5: dx/dt = x  
>> //6: dx/dt = sin(t) + t*cos(t)   
>float x_start = 0; //start value  
>float dt = 1; //step size  
>int n_steps = 20; //number of steps  
>float t_start = 0; 
  
#### Examples of output plots  
![alt text](https://github.com/CyberHolmes/CSCI5611/blob/master/HW2_Part1/outputData%26Plots/plot_6_x_0.0_dt_1.0_steps_20_1593218849.jpg)  
