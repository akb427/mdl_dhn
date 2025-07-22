function [tree_best, c_best] = bnb_enthalpy(pairs, users_in_node2, c_list, n, mdpts, params, tc, tree_ig1)
%BNB_ENTHALPY  One-line summary of what the function does.
%
%   [tree_best, c_best] = BNB_ENTHALPY(pairs, users_in_node2, c_list, n, mdpts, params, tc, tree_ig1) 
%
%   DESCRIPTION:
%   Branch and bound search of all potential network layouts using
%   predescribed midpoints, with the goal of minimizing overall component
%   losses. Recursively add node pairs to tree until either the tree is
%   complete or the cost bound is exceeded. 
%
%   INPUTS:
%       pairs   - Matrix of all midpoint pairs that don't overlap users.
%       users_in_node2  - Users in the midpoint in the second column of pair.
%       c_list  - Additional inputs as needed.
%       n       - Structure of problem sizing.
%       mdpts   - Matrix of midpoints described by row.
%       params  - Structure of system parameters.
%       tc      - Structure of element parameters.
%       tree_ig1    - Matrix of initial guess for best tree.
%
%   OUTPUTS:
%       tree_best   - Loss minimizing tree by connecting pairs.
%       c_best      - Loss cost of best tree.
%
%   DEPENDENCIES: expand_tree, fincalc_enthalpy.
%
%   SEE ALSO: cost_enthalpy.


%% Bound by either initial guess or midpoint of all users

% preallocate storage
n_preallocate = 50;
trees_all = zeros(n.u,2,n_preallocate);
cost_trees = NaN(1,n_preallocate);

% find cost of initial guess
[tree_ig1_expand,n] = expand_tree(tree_ig1,mdpts,n,0);
[cost_ig1, ~] = fincalc_enthalpy(tree_ig1_expand,n,params,tc,mdpts,pairs);

% find cost of pair that has all users in second node
plant2full =find(all(users_in_node2,2));
[~,idx_best] = min(c_list(plant2full));
[tree_ig2_expand,n] = expand_tree(pairs(plant2full(idx_best),:),mdpts,n,0);
[cost_ig2, ~] = fincalc_enthalpy(tree_ig2_expand,n,params,tc,mdpts,pairs);

% choose better to bound
if cost_ig1<cost_ig2
    trees_all(:,:,1) = tree_ig1;
    c_bound = cost_ig1;
else
    trees_all(:,:,1) = [pairs(plant2full(idx_best),:); zeros(n.u-1,2)];
    c_bound = cost_ig2;
end

cost_trees(1) = c_bound;
idx_tree_new = 2;

%% Call recursion

% index of last plant-connected node
splt = find(pairs(:,1)==0,1,'last');

% for all possible starting trees
for idx_pair_plant = 1:splt
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
    if all(users_in_tree) && cost<c_bound
        % recalculate true cost rather than lower bound cost
        [tree_expand,n] = expand_tree(tree,mdpts,n,0);
        [c_true, ~] = fincalc_enthalpy(tree_expand,n,params,tc,mdpts,pairs);
        % if it is still better
        if c_true<c_bound
            % update bound and add tree to running storage
            c_bound = c_true;
            cost_trees(1,idx_tree_new) = c_true; 
            trees_all(:,:,idx_tree_new) = tree;
            idx_tree_new = idx_tree_new+1;
            % if more trees have been explored than preallocated
            if idx_tree_new>n_preallocate
                warning('Not enough space preallocated in tree saver')
            end
        end
    elseif cost<c_bound         % if the search should continue
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
            add_node(tree_new, users_in_tree_new, cost_new, row_in_tree+1, [newest_pairs_in_tree;idx_pair]);
        end
        % children of newly added node in tree with no overlap
        pairs2add = find(any(pairs(newest_pairs_in_tree,2)'==pairs(:,1),2));
        pairs2add = pairs2add(~any(users_in_tree & users_in_node2(pairs2add,:),2))';
        for idx_pair = pairs2add
            tree_new = tree;
            tree_new(row_in_tree+1,:) = pairs(idx_pair,:);
            users_in_tree_new = users_in_node2(idx_pair,:)|users_in_tree;
            cost_new = cost+c_list(idx_pair);
            add_node(tree_new, users_in_tree_new, cost_new, row_in_tree+1, idx_pair);
        end
    end
    end
end

