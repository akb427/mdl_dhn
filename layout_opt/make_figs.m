%make_figs  Creates figures for layout optimization paper.
%
%   DESCRIPTION:
%   Used to plot the figures for the layout optimization paper. Plots the 6
%   user sample graph, the 2 illustrative figures of the prize sets and
%   split node types, and plots to compare the results between the two
%   optimization objectives.
%
%   DEPENDENCIES: fig_graph, fig_spltnds, fig_congraph, fig_map, fig_layout
%
%   SEE ALSO: layoutopt_runner

%% Initialize workspace

clc, clear, close all
pth = pwd;
addpath(fullfile(pth, 'figures'));
addpath(fullfile(pth, 'solveBnB'));

%% Load Results

pth = pwd;
load(pth+"\structure\struct8users.mat", 'mdpts', 'n', 'pairs');
load(pth+"\case study\map8users.mat",'map');
load(pth+"\case study\results_l_8users1.mat", 'l', 'params');
load(pth+"\case study\results_e_8users1.mat", 'e');

%% Example Graph

nex.k = 16;
nex.u = 6;
nex.s = 1;
nex.p = 6*nex.u;
Gex = digraph([1 2 3 4 8 8 6],[2 3 4 8 5 6 7] ,[],string(0:nex.u+nex.s));

fig_graph(Gex, nex) 

%% Plot Illustrative plots

fig_spltnds
fig_congraph(pth);

%% Optimization Results

fig_map(map, n);

[e,l] = fig_layout(map, e, l, mdpts, n, pairs, params);
prrd_e = (l.cost_enthalpy-e.cost_enthalpy)/l.cost_enthalpy;
