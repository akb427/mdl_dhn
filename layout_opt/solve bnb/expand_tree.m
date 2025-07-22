function [tree_new,n] = expand_tree(tree, mdpts, n, flag)
%EXPAND_TREE  Include all midpoint components in tree matrix.
%
%   [tree_new,n] = EXPAND_TREE(tree, mdpts, n, flag)
%
%   DESCRIPTION:
%   Takes a tree with the midpoints explicitly listed (by only including 
%   the midpoint rather than all the midpoint elements) and makes these
%   connections explicit by expanding them down to the user level. 
%
%   INPUTS:
%       tree    - Matrix of tree to be expanded
%       mdpts   - Matrix of midpoints described by row.
%       n       - Structure of problem sizing
%       flag - Binary indicator if split nodes are renumbered ton_u+1:n_u+n_s.
%
%   OUTPUTS:
%       tree_new - Matrix of tree expanded to explicitly include all users.
%       n       - Structure of problem sizing
%
%   SEE ALSO: bnb_enthalpy

%% Get initial tree elements

% remove empty rows
row_empty = all(tree==0,2);
tree(row_empty,:) = [];

% add existing rows to new tree
tree_new = zeros(n.u+ceil(n.u/2)+1,2);
row_in_tree = size(tree,1);
tree_new(1:row_in_tree,:) = tree;
row_in_tree = row_in_tree+1;

%% Recursively expand midpoints in column 2

for idx_row = tree(tree(:,2)>n.u,2)'
    append_node(idx_row);
end

%% Process results

row_empty = all(tree_new==0,2);
tree_new(row_empty,:) = [];

% split nodes in tree
spltnds = unique(tree_new(tree_new>n.u));
n.s = numel(spltnds);

% if split nodes should be renumbered
if flag
    for num_node = n.u+1:n.u+numel(spltnds)
        idx_in_list = num_node-n.u;
        tree_new(tree_new==spltnds(idx_in_list))=num_node;
    end
end

%% Functions

% Recursively expand tree list to include all node components
function append_node(nd_list)
    % for all nodes to be added
    for nd = nd_list
        % components of the node
        nd_list_new = mdpts(nd_list,:);
        % for all node components
        for nd_component = nd_list_new
            if nd_component>n.u     % if the node can be expanded further
                % add the node pair
                tree_new(row_in_tree,:) = [nd nd_component];
                row_in_tree = row_in_tree+1;
                % expand further
                append_node(nd_component);
            elseif nd_component>0   % if the node is a user
                % add the node pair
                tree_new(row_in_tree,:) = [nd nd_component];
                row_in_tree = row_in_tree+1;
            end
        end

    end
end

end
