%make_figs  One-line summary of what the function does.
%
%   DESCRIPTION:
%   
%
%   DEPENDENCIES: fig_spltnds, 
%
%   SEE ALSO: layoutopt_runner


%% Initialize workspace

clc, clear, close all
pth = pwd;
addpath(fullfile(pth, 'figures'));

%% Example Graph

nex.k = 16;
nex.u = 6;
nex.s = 1;
nex.p = 6*nex.u;
Gex = digraph([1 2 3 4 8 8 6],[2 3 4 8 5 6 7] ,[],string(0:nex.u+nex.s));

%% Load Results

pth = pwd;
load(pth+"\structure\struct8users.mat", 'mdpts', 'n', 'pairs');
load(pth+"\case study\map8users.mat",'map');
load(pth+"\case study\results_l_8users1.mat", 'l');
load(pth+"\case study\results_e_8users1.mat", 'e');

%% Plot

fig_spltnds
%fig_graph(Gex, nex)
fig_map(map, n);
fig_congraph(pth);

%% Optimization Results

[trl_ce, trl_cl, tre_ce, tre_cl] = fig_layout(map, e.tr, l.tr, mdpts, n, pairs, e.c_comp, params);
