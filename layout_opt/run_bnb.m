clc, clear, close all

%% Set System Parameters

load('struct8users.mat');
load('map8users.mat');

params.Ts = 80;
params.x = 5;
params.Ta = -5;
params.h = 1.5;
params.DL = .4;
params.Ds = 0.15;
params.mI = 20;
params.p = 971;
params.cp = 4164;
params.mapb = [0,0; map];


%% Length Minimized Layout

% [l.c_add, l.c_pairs] = cost_length(mdpts, pairs, params, n);         % calculate the length cost of all midpoints
% [l.tr, l.c_best] = bnb_length(pairs, usersp, l.c_add, n);
% 
% if i==0
%     filename = ['results_l_', num2str(n.u), 'users.mat'];
% else
%     filename = ['results_l_', num2str(n.u), 'users',num2str(i),'.mat'];
% end
% 
% save(filename,'params', 'l')

%% Enthalpy Drop Minimized Layout
[e.c_lim,e.c_comp] = cost_enthalpy(mdpts, usersm, pairs, usersp, params,n);         % calculate the length cost of all midpoints
[e.tr, e.c_best] = bnb_enthalpy(pairs,usersp,e.c_lim,n,mdpts,params,e.c_comp,l.tr);
[tre,ne] = expand_tree(e.tr, mdpts, n,0);
[~, dropact] = fincalc_enthalpy(tre,ne,params,e.c_comp,mdpts,pairs);

while dropact>=params.x
    params.x = dropact+1;
    [e.c_add,e.c_comp] = cost_enthalpy(mdpts, usersm, pairs, usersp, params,n);         % calculate the length cost of all midpoints
    [tre, e.c_best] = bnb_enthalpy(pairs,usersp,e.c_lim,n,mdpts,params,e.c_comp,tre);
    [e.tr,ne] = expand_tree(tre, mdpts, n,0);
    [~, dropact] = fincalc_enthalpy(e.tr,ne,params,e.c_comp,mdpts,pairs);
end

%%
if i==0
    filename = ['results_e', num2str(n.u), 'users.mat'];
else
    filename = ['results_e', num2str(n.u), 'users',num2str(i),'.mat'];
end

save(filename,'params','e')
