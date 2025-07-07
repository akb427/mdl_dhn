clc, clear, close all
%% Example Graph

nex.k = 16;
nex.u = 6;
nex.s = 1;
nex.p = 6*nex.u;
Gex = digraph([1 2 3 4 8 8 6],[2 3 4 8 5 6 7] ,[],string(0:nex.u+nex.s));

%% Load Results

load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Project Codes\Layout Optimization\struct8users.mat");
load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Project Codes\Layout Optimization\map8users.mat");
load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Project Codes\Layout Optimization\results_l_8users1.mat");
load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Project Codes\Layout Optimization\results_e_8users1.mat");
%% Plot
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

fig_spltnds
%fig_graph(Gex, nex)
fig_map(map, n);
fig_congraph;

%% Optimization Results

[trl_ce, trl_cl, tre_ce, tre_cl]=fig_layout(map,e.tr, l.tr,mdpts,n,pairs,e.c_comp,params);

%% Reset plot settings
set(groot,'defaultAxesTickLabelInterpreter','tex');  
set(groot,'defaulttextinterpreter','tex');
set(groot,'defaultLegendInterpreter','tex');