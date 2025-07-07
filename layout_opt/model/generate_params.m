function [G,n,params] = generate_params(G, n)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


%% G

n.s = numnodes(G)-n.u-1;
n.k = n.u+n.s;
G.Nodes.Name = string(0:n.k)';
v_leaf = find(outdegree(G)==0)-1;
n.leaf = numel(v_leaf);
n.p = 5*n.u+n.leaf;

%% Params

params.p = 971;
params.cp = 4179;
params.h = 1.5;
params.mI = 25;

% pipes = [L D zetaB zetaF mdot Lbypass Dbypass mdotbypass]
params.pipes = zeros(n.k, 8);
params.pipes(:,1) = randi([30 50], n.k,1);
params.pipes(:,2) = .15*ones(n.k,1);
params.pipes(v_leaf,3) = rand(n.leaf,1);
params.pipes(:,4) = rand(n.k,1);
params.pipes(v_leaf,6) = .15*ones(n.leaf,1);
params.pipes(v_leaf,7) = randi([5 10], n.leaf,1);

% users = [mu Q Ls1 Ls2 Ls3 Ds1 Ds2 Ds3]
params.users(:,1) = 2*rand(n.u,1);
params.users(:,2) = randi([1000 2000], n.u,1);
params.users(:,[3 4 5]) = randi([1 5], n.u,3);
params.users(:,[6 7 8]) = .15*ones(n.u,3);

params.pipes(v_leaf,8) = params.pipes(v_leaf,5)-params.users(v_leaf, 1);


end