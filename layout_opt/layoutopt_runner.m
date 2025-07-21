% Layout optimization runner
% Audrey Blizard
% Last Update: 5/24/2023

clc, clear, close all
tic
%% Gather System Parameters

params.Ts = 80;
params.x = 3;
params.Ta = -5;
params.h = 1.5;
params.DL = .4;
params.Ds = 0.15;
params.mI = 20;
params.p = 971;
params.cp = 4164;

n.u = 6;

%% Map
params.mapb = importdata('parma8users.mat');
map = params.mapb(2:end,:)-params.mapb(1,:);

%% Generate Layouts
[mdpts, usersm] = generate_mdpts(n.u);      % recursively generate all potential midpoints
[map] = locate_mdpts(mdpts, map, n.u);      % calcualte midpoint locations
[pairs, usersp] = pair_pts(usersm);         % generate valid parent child pairs
params.mapb = [0,0; map];

%% Length Minimized Layout
[c] = cost_length(mdpts, pairs, params, n);         % calculate the length cost of all midpoints
[trl, cl] = bnb_length(pairs, usersp, c, n);

%% Enthalpy Drop Minimized Layout
dropact = params.x;
while dropact>=params.x
    params.x = dropact;
    [c,tc] = cost_enthalpy(mdpts, usersm, pairs, usersp, params,n);         % calculate the length cost of all midpoints
    [tre, ce] = bnb_enthalpy(pairs,usersp,c,n,mdpts,params,tc);
    [tre,n] = expand_tree(tre, mdpts, n,0);
    [dE, dropact] = fincalc_enthalpy(tre,n,params,tc,mdpts,pairs);
end
%% Save
time = toc;
save('results8users','params', 'tre','ce','trl','cl','time')