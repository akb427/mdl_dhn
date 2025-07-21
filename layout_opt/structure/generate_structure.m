function generate_structure(nu, sv_name)
%GENERATE_STRUCTURE  Generates all potential network components.
%
%   DESCRIPTION:
%   Generates all the potential network components, based on the number of
%   users (n.u). Creates a file "struct#users". Only needs to be run once
%   per # of users. Gives midpoints and the pairs of midpoints that work
%   together.
%
%   INPUTS:
%       nu      - Number of users in the system
%       sv_name - Save location
%
%   DEPENDENCIES: generate_mdpts, pair_pts.

%% Set Number of users

n.u = nu;

%% Generate Layouts
[mdpts, users_in_mdpt] = generate_mdpts(n.u);    % recursively generate all potential midpoints
[pairs, users_in_node2] = pair_pts(users_in_mdpt);   % generate valid parent child pairs

%% Save

save(sv_name, 'n','mdpts','users_in_mdpt','pairs','users_in_node2')

end