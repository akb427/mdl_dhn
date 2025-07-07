
clc, clear, close all
%% Graph
G = digraph([1 7 7 2 6 6],[7 2 5 6 3 4]);
% G = digraph([1 1 2 3 12 12 5 7 8 9 13 13],[2 7 3 12 4 5 6 8 9 13 10 11],[],string(0:n.u+n.s));
% n.u = 10;
%G = [1 1 1 6 7 17 17 9 16 16 12 13 2 15 15 3; 2 17 6 7 8 9 12 16 10 11 13 14 15 3 5 4]';
n.u = 4;
%G = digraph(G(:,1),G(:,2));

G = digraph([0 1 14 14 3 4 0 6 7 8 0 10 10 12]+1,[1 14 2 3 4 5 6 7 8 9 10 11 12 13]+1);
n.u = 13;


% G = digraph([0 3 3]+1,[3 1 2]+1);
% n.u = 3;

[G,n,params] = generate_params(G, n);
G.Nodes.Name = string(0:n.s+n.u)';

%% Calculate mdot

% Inital guess for alpha
eo = cellfun(@(x) outedges(G,x), num2cell(unique([1; find(outdegree(G)>1)])),'UniformOutput',false);
as = cellfun(@numel, eo);
eo = cell2mat(eo);
a = repelem(1./as,as);
n.br = numel(a);

edg = zeros(n.k,9);
edg(:,3) = ones(n.k,1);
edg(:,1:2) = cellfun(@str2double, table2array(G.Edges));
idx = edg(:,1)>0 & edg(:,1)<=n.u;
edg(idx,4) = params.users(edg(idx,1),1);
edg(:,9) = params.pipes(edg(:,2),3);

%clear eo as idx
%% Minimization problem
[a1, ~] = fmincon(@(x)calculate_alpha(x,G,params,edg,n,1), a, [eye(n.br); -1*eye(n.br)], [ones(n.br,1); zeros(n.br,1)]);
[err1, ~] = calculate_alpha(a1,G,params,edg,n,0);

%% Casadi

[a2] = calculate_alpha_csdi(G,params,n);
[err2, ~] = calculate_alpha(a2,G,params,edg,n,0);
%% Model
[A, B, E] = graph2ss(G,params, n);