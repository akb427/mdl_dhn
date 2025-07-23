function [dE,dTmax] = fincalc_enthalpy(tree, n, params, tc, mdpts, pairs)
%FINCALC_ENTHALPY  Calculate enthalpy loss in full tree.
%
%   [dE,dTmax] = FINCALC_ENTHALPY(tree, n, params, tc, mdpts, pairs)
%
%   DESCRIPTION:
%   Calculates the true enthalpy loss in an expanded tree with all users
%   connected. Gets all the relavent variables for the calculation in the
%   expanded tree matrix and then calculates the temperature drop in each
%   pipe. Also outputs the maximum temperature drop to confirm the
%   assumption on the lower bound is acceptable. 
%
%   INPUTS:
%       tree    - Matrix of complete, expanded tree to be evaluated 
%       n       - Structure of problem sizing
%       params  - Structure of system parameters.
%       tc      - Structure of element parameters.
%       mdpts   - Matrix of midpoint components.
%       pairs   - Matrix of all midpoint pairs that don't overlap users.
%
%   OUTPUTS:
%       dE      - Total network losses
%       dTmax   - Maximum temperature drop in an edge
%   
%   SEE ALSO: expand_tree

%% Network parameters

% preallocate tree [v_start v_end u_ds mdotcp D L hAs Tin T]
tree =[tree, zeros(n.u+n.s,8)];

% number of downstream users
idx_term = ~any(tree(:,2)==tree(:,1)',2);
tree(:,3) = idx_term;
calc_users(unique(tree(idx_term,1)'))

% Assign mdotcp and diameters
tree(:,4) = params.cp*tree(:,3)*tc.mi;
many_users = tree(:,3)>1;
tree(many_users,5) = params.DL;
tree(~many_users,5) = params.Ds;

tic
% assign lengths
for row = 1:n.u+n.s
    v_start = tree(row,1);
    if v_start~=0 % if it is not the plant
        node_match = mdpts(v_start,:)==tree(row,2);
        if any(node_match) % if this connection is from the midpoint design, length comes from precalc
            tree(row,6) = tc.L_mdpts(v_start,node_match);
        else % length is only of connection
            idx_in_pair = all(pairs==tree(row,1:2),2);
            tree(row,6) = tc.L_pairs(idx_in_pair);
        end
    else % if it is the plant, length is only of connection
        idx_in_pair = all(pairs==tree(row,1:2),2);
        tree(row,6) = tc.L_pairs(idx_in_pair);
    end
end
% calculate heat transfer coefficient
tree(:,7)= params.h*pi*tree(:,5).*tree(:,6);

% Assign inlet temp to plant edges
idx_root = tree(:,1)==0;
tree(idx_root,8) = params.Ts;

%% Calculate temperatures and losses

calc_dT(idx_root)

% Losses = hAs(Tin-T)
tree(:,10) = tree(:,4).*(tree(:,8)-tree(:,9));
% Total losses
dE = sum(tree(:,10));
% maximum temperature drop for lower bound calculation
dTmax = max(params.Ts-tree(:,9));

%% Functions

    function calc_users(v)
    % calculate the number of downstream users through recursive counting of nodes, roots up.
    tbe = NaN(1,n.u);
    idx_in_tbe = 1;
    for vi = v    
        start_rows = tree(:,1)==vi;
        if all(tree(start_rows,3)>=1) % if we know how many users downstream
            end_rows = tree(:,2)==vi;
            % # users = users eventually downstream + directly connected
            tree(end_rows,3) = sum(tree(start_rows,3))+(tree(end_rows,2)<=n.u);
            % add nodes to which it is connected to tbe
            start_node = tree(end_rows&tree(:,1)>0,1);
            if ~isempty(start_node)
                tbe(idx_in_tbe) = start_node;
                idx_in_tbe = idx_in_tbe+1;
            end
        else    % if it still needs to be explored
            tbe(idx_in_tbe) = vi;
            idx_in_tbe = idx_in_tbe+1;
        end
    end
    % if futher nodes need to be evaluated
    if ~all(isnan(tbe))
        tbe = tbe(~isnan(tbe));
        calc_users(unique(tbe));
    end
    end

    function calc_dT(row_idx)
    % recursively calculate the outlet/bulk temperature in all the pipes
    % based on the inlet temperatures.
        % outlet temperatures [mc_p/(mc_p+hAs)*T_in]+[hA_s/(mc_p+hAs)*T_a]
        term1 = tree(row_idx,4)./(tree(row_idx,4)+tree(row_idx,7)).*tree(row_idx,8);
        term2 = tree(row_idx,7)./(tree(row_idx,4)+tree(row_idx,7))*params.Ta;
        tree(row_idx,9) = term1+term2;
        % for all the rows with added outlet temp
        for row_num = find(row_idx)'
            % rows with outlet as inlet
            row_idx_new = tree(:,1)==tree(row_num,2);
            if any(row_idx_new)
                % solve new outlet temp
                tree(row_idx_new,8) = tree(row_num,9);
                calc_dT(row_idx_new)
            end
        end
    end
    
end

