# Git Overview
Provides the code the generate the results seen in 
https://asmedigitalcollection.asme.org/dynamicsystems/article/146/4/041001/1197166/A-Graph-Based-Technique-for-the-Automated-Control  
Two code sets are available. The first "layout_opt" is for the optimal layout problem and the second "validation" is to validate the modeling technique against experimental data.

## layout_opt

### Description
This code generates the map of points taken from an 8-user case study of University of Parma buildings and generates both the length-minimizing and loss-minimizing layouts of a DHN.  

### Running instructions
Use "layoutopt_runner.m" to solve the provided case study.  
If you would like to generate your own case study, first use "\structure\create_map.m" to generate your unique map. Then, make changes to the parameters at the top of "layoutopt_runner.m". 
To plot the results, use the file "make_figs.m".

Because this code uses branch and bound to find the true optimal solution, finding results with more than 8 users will be time and memory-intensive.  

## validation

### Description

### Running instructions

