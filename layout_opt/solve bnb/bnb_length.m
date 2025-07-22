function [tree_best, c_best] = bnb_length(pairs, users_in_node2, c_list, n)
%BNB_LENGTH  Finds the length minimizing solution via bnb.
%
%   [tree_best, c_best] = BNB_LENGTH(pairs, users_in_node2, c_list, n)
%
%   DESCRIPTION:
%   Branch and bound search of all potential network layouts using
%   predescribed midpoints, with the goal of minimizing overall component
%   length. Recursively add node pairs to tree until either the tree is
%   complete or the cost bound is exceeded. 
%
%   INPUTS:
%       pairs   - Matrix of all midpoint pairs that don't overlap users.
%       users_in_node2   - Users in the midpoint in the second column of pair
%       c_list  - Vector of total distance cost of pairs
%       n       - Structure of problem sizing
%
%   OUTPUTS:
%       tree_best   - Length minimizing tree by connecting pairs
%       c_best      - Length cost of best tree
%
%   SEE ALSO: cost_length.

%% Bound with midpoint of all users

% preallocate storage
n_preallocate = 100;
trees_all = zeros(n.u,2,n_preallocate);
cost_trees = NaN(1,n_preallocate);

% bound by pairs that have all users in second node
plant2full = find(all(users_in_node2,2));
[c_bound,idx_best] = min(c_list(plant2full));
% store cost and tree
cost_trees(1) = c_bound;
trees_all(:,:,1) = [pairs(plant2full(idx_best),:); zeros(n.u-1,2)];
idx_tree_new = 2;

% remove worse performing full pairs from lists
plant2full(idx_best) = [];
pairs(plant2full,:) = [];
users_in_node2(plant2full,:) = [];
c_list(plant2full,:) = [];

% eliminate already unfeasible points
idx_feasible = c_list<=c_bound;
pairs = pairs(idx_feasible,:);
users_in_node2 = users_in_node2(idx_feasible,:);
c_list = c_list(idx_feasible,:);

%% Call recursion

% index of last plant-connected node
splt = find(pairs(:,1)==0,1,'last');

% for all possible starting trees
for idx_pair_plant = 1:splt
    % preallocate tree
    tree_i = zeros(n.u,2);
    tree_i(1,:) = pairs(idx_pair_plant,:);
    add_node(tree_i, users_in_node2(idx_pair_plant,:), c_list(idx_pair_plant),1,idx_pair_plant);
end

%% Output Results

[c_best, idx_best] = min(cost_trees);
tree_best = trees_all(:,:,idx_best);

%% Recursive Function
    function add_node(tree, users_in_tree, cost, row_in_tree, newest_pairs_in_tree)
    % check search termination conditions
    if all(users_in_tree)&&cost<c_bound    % if a new bound has been found
        % update bound and add tree to running storage
        c_bound = cost;
        cost_trees(1,idx_tree_new) = cost; 
        trees_all(:,:,idx_tree_new) = tree;
        idx_tree_new = idx_tree_new+1;
        % if more trees have been explored than preallocated
        if idx_tree_new > n_preallocate
            warning('Not enough space preallocated in tree saver. Consider adding more preallocated space. Does not affect code operation')
        end
    elseif cost<c_bound            % if the search should continue
        % parallel (connected to the same start node) but only from above in pairs list
        [pairs2add,~] = find(pairs(min(newest_pairs_in_tree),1)==pairs(1:min(newest_pairs_in_tree)-1,1));
        % remove those with user overlap
        pairs2add = pairs2add(~any(users_in_tree & users_in_node2(pairs2add,:),2))';
        for idx_pair = pairs2add
            % add node to tree
            tree_new = tree;
            tree_new(row_in_tree+1,:) = pairs(idx_pair,:);
            users_in_tree_new = users_in_node2(idx_pair,:)|users_in_tree;
            cost_new = cost+c_list(idx_pair);
            % keep building tree
            add_node(tree_new, users_in_tree_new, cost_new, row_in_tree+1, [newest_pairs_in_tree;idx_pair]);
        end
        % children of newly added node in tree with no overlap
        pairs2add = find(any(pairs(newest_pairs_in_tree,2)'== pairs(:,1),2));
        pairs2add = pairs2add(~any(users_in_tree & users_in_node2(pairs2add,:),2))';
        for idx_pair = pairs2add
            % add node to tree
            tree_new = tree;
            tree_new(row_in_tree+1,:) = pairs(idx_pair,:);
            users_in_tree_new = users_in_node2(idx_pair,:)|users_in_tree;
            cost_new = cost+c_list(idx_pair);
            add_node(tree_new, users_in_tree_new, cost_new,row_in_tree+1,idx_pair);
        end
    end
    end
end

