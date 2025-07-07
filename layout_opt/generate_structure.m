
%%
clc, clear, close all

%% Set Number of users

n.u = 4;

%% Generate Layouts
[mdpts, usersm] = generate_mdpts(n.u);    % recursively generate all potential midpoints
[pairs, usersp] = pair_pts(usersm);   % generate valid parent child pairs

%% Save

filename = ['struct', num2str(n.u), 'users'];
save(filename, 'n','mdpts','usersm','pairs','usersp')

%%