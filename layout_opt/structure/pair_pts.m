function [pairs, users2] = pair_pts(users)
%pair_pts  Finds valid pairings of midpoints.
%
%   [pairs, users2] = PAIR_PTS(users)
%
%   DESCRIPTION:
%   Finds all valid pairings of midpoints that do not overlap the users.
%   Outputs these pairs based off their rows in users.
%
%   INPUTS:
%       users   - Binary matrix of users in midpoints
%
%   OUTPUTS:
%       pairs   - Matrix of all midpoint pairs that don't overlap users.
%       users2  - Users in the midpoint in the second column of pair.
%
%   SEE ALSO: generate_structure

%% Find valid pairs

% Row of midpoints without all users
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