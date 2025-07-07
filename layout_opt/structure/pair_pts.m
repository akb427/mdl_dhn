function [pairs, users2] = pair_pts(users)
%pair_pts  One-line summary of what the function does.
%
%   [pairs, users2] = PAIR_PTS(users)
%
%   DESCRIPTION:
%   Briefly explain the purpose of the function, what it computes, or how it
%   fits into the overall workflow. Mention any important assumptions or side
%   effects (e.g., plotting, modifying global variables, saving files).
%
%   INPUTS:
%       users  - Binary matrix of users in midpoints
%
%   OUTPUTS:
%       out1 - Description of output 1 (what it represents)
%       out2 - Description of output 2
%       ...  - Additional outputs as needed
%
%   SEE ALSO: generate_mdpts

%% Find valid pairs

% Row of incomplete midpoints
num_mdpt = size(users,1);
idx_mdpt = 1:num_mdpt;
idx_mdpt = idx_mdpt(~all(users,2));

% Single midpoint "pairs"
pairs = [repelem(0,num_mdpt,1) (1:num_mdpt)'];
idx_pairs = num_mdpt+1;

for mdpt_i = idx_mdpt
    % Add valid pairing nodes to list
    [chld,~] = find(~any(users(mdpt_i,:)&users,2));
    idx_pairs_new = idx_pairs+numel(chld)-1;
    pairs(idx_pairs:idx_pairs_new,:) = [repelem(mdpt_i,numel(chld),1) chld];
    % skip to new row
    idx_pairs = idx_pairs_new+1;
end

% Users in second node
users2 = users(pairs(:,2),:);

end