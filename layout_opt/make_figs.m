%make_figs  Creates figures for layout optimization paper.
%
%   DESCRIPTION:
%   
%
%   DEPENDENCIES: fig_spltnds, fig_graph,
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
