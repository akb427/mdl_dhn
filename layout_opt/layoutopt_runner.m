%FUNCTION_NAME  One-line summary of what the function does.
%
%   [out1, out2] = FUNCTION_NAME(in1, in2)
%
%   DESCRIPTION:
%   
%
%   INPUTS:
%       in1  - Description of input 1 (type, format, units if applicable)
%       in2  - Description of input 2
%
%   OUTPUTS:
%       out1 - Description of output 1 (what it represents)
%       out2 - Description of output 2
%
%   DEPENDENCIES:
%
%   SEE ALSO:

%% Initialize run
clc, clear, close all

% add paths
pth = pwd;
addpath(fullfile(pth, 'structure'));
addpath(fullfile(pth, 'solveBnB'));

%% System Parameters

params.Ts = 80;
params.x = 3; % assumed maximum temperature drop
params.Ta = -5;
params.h = 1.5;
params.DL = .4;
params.Ds = 0.15;
params.mI = 20;
params.p = 971;
params.cp = 4164;

n.u = 8;

%% Map

params.mapb = importdata('parma8users.mat');
% plant at (0,0)
map = params.mapb(2:end,:)-params.mapb(1,:);

%% Generate Layouts

% either load or create and then load structure
struct_file = sprintf('%sstruct%dusers.mat', fullfile(pth, 'structure\'),n.u);
if isfile(struct_file)
    load(struct_file, 'n','mdpts','users_in_mdpt','pairs','users_in_node2')
else
    generate_structure(n.u, struct_file)
    load(struct_file, 'n','mdpts','users_in_mdpt','pairs','users_in_node2')
end

% calcualte midpoint locations
[map] = locate_mdpts(mdpts, map, n.u);
params.mapb = [0,0; map];

%% Length Minimized Layout

% calculate the length cost of all midpoints
[l.c_add, l.c_pairs] = cost_length(mdpts, pairs, params, n);
% use results to find optimal length minimizing layout
[l.tr, l.c_best] = bnb_length(pairs, users_in_node2, l.c_add, n);

% Save results
baseName = sprintf('results_l_%dusers', n.u);
file_version = 0;
filename = sprintf('%s.mat', baseName);
% Find unique version
while isfile(filename)
    file_version = file_version + 1;
    filename = sprintf('%s%d.mat', baseName, file_version);
end

save(filename,'params', 'l')

%% Enthalpy Drop Minimized Layout

% Bounding cost relies on assuming a temperature drop. If this temperature
% drop is too high, then the bound is incorrect, so the loop is repeated
% until this assumption holds.

dropact = params.x;
while dropact>=params.x
    params.x = dropact;
    % calculate the enthalpy cost and relavent parameters of all midpoints
    [e.c_lim,e.tc] = cost_enthalpy(mdpts, users_in_mdpt, pairs, users_in_node2, params,n);         % calculate the length cost of all midpoints
    [e.tr, e.c_best] = bnb_enthalpy(pairs,users_in_node2,c,n,mdpts,params,tc);
    [tre,n] = expand_tree(tre, mdpts, n,0);
    [dE, dropact] = fincalc_enthalpy(tre,n,params,tc,mdpts,pairs);
end

% Save results
if file_version==0
    filename = ['results_e', num2str(n.u), 'users.mat'];
else
    filename = ['results_e', num2str(n.u), 'users',num2str(file_version),'.mat'];
end
save(filename,'params','e')
