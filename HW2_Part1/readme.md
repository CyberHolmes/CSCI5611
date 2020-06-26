# Readme #
    
This program package contains 3 .pde files and one data folder containing a font file.  
This program compares 4 numerical integration methods with ground truth (underlying function evaluation).  
This program evaluates 7 different functions controlled by a global variable c (defined in HW2_Part1.pde).  
This program outputs comparison results in console, as well as a csv .txt file.  
This program also plots data and saves the plot as a .jpg file.  
All results files are saved in the same folder as the program them selves.  

## To select which function to evluate, set initial conditions, step size and number of steps:
#### Set corresponding global vaiables (line 13 through 23 in HW2_Part1)
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
![alt text](https://github.com/CyberHolmes/CSCI5611/blob/master/HW2_Part1/outputData%26Plots/plot_6_x0.0_dt1.0_1593122041.jpg)  
![alt text](https://github.com/CyberHolmes/CSCI5611/blob/master/HW2_Part1/outputData%26Plots/plot_0_x0.0_dt1.0_1593121768.jpg)  
