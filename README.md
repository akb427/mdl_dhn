
# layout_opt

## Description
This code generates the map of points taken from an 8-user case study of University of Parma buildings and generates both the length-minimizing and loss-minimizing layouts of a DHN.  
https://asmedigitalcollection.asme.org/dynamicsystems/article/146/4/041001/1197166/A-Graph-Based-Technique-for-the-Automated-Control  

## Running instructions: 
Use the layoutopt_runner file to solve the case study.  
If you would like to generate your own case study, first use the "\structure\create_map.m" file to generate your unique map. Then, make changes to the parameters at the top of the layoutopt_runner.m file. 
To plot the results, use the file "make_figs.m".

Because this code uses branch and bound to find the true optimal solution, finding results with more than 8 users will be time and memory prohibative.  

