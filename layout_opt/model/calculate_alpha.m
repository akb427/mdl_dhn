function [c,mdot] = calculate_alpha(a,G,params,edg,n,flag)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% edg = [n_in n_out alpha dmdot mdot br e_in dP zetaB]
% br = [n.u_br n_in dP]
%% Graph to Structure
odG = outdegree(G);                     % store outdegree for later
n_splt = (find(odG>1)-1)';              % split nodes have outdegree >1
if odG(1)<=1
    n_splt = [0, n_splt];
end
n.splt = numel(n_splt);
leaf = find(odG==0)-1;                  % leaf nodes have outdegree=0
edg(any(edg(:,1)==n_splt,2),3) = a;     % distribute alpha into first edge of branches

%% Calculate Mass Flow Rate
idx = 0;                                % initialize index for branch number
for i = find(edg(:,1)==0)'              % for all branches leaving the root
    edg(i,5) = edg(i,3)*params.mI;      % calculate mass flow in first edge
    idx = idx+1;                        % increment branch number
    [edg,idx] = calc_mdot(i,idx,edg);   % recursively calculate mdot in branch
end

%% Pressure losses
edg(:,8) = params.pipes(edg(:,2),4).*edg(:,5).^2;       % feeding line: dP = zetaF*mdot^2
br = [zeros(n.br,1) NaN(n.br,1) zeros(n.br, 1)];        % initalize matrix for branches
idx = (repelem(edg(:,2),1,n.br).*(edg(:,6)==1:n.br));   %
br(:,1) = sum(idx<=n.u & idx>0)';


br = calc_dP(leaf', edg, br);

%% Calculate Constraints

cm = sum(repelem(edg(:,3),1,n.splt).*(edg(:,1)==n_splt))-1;

idx = br(:,2)==n_splt;
cp = zeros(1,sum(idx,'all')-n.splt);
for i = 1:n.splt
    x = br(idx(:,i),3);
    x = x(1)-x(2:end);
    cp(1,sum(idx(:,1:i-1),'all')-i+2:sum(idx(:,1:i),'all')-i) = x;
end

c = [800*cm, 1*cp];
mdot= edg(:,[2 5]);
if flag
    c = sum(abs(c));
else
    [~, idx] = sort(mdot(:,1));
    mdot = mdot(idx,2);
end

%% Nested Functions
    function [edg, idxbr] = calc_mdot(i,idxbr,edg)          % function to calculate mdot
    if edg(i,1)~=0                                          % if current edge is not fed by root
        edg(i,5) = edg(i,3)*(edg(edg(i,7),5)-edg(i,4));     % mdot = a*(mdot_in-dmdot)
    end
    edg(i,6) = idxbr;                                       % save branch number
    idx2 = edg(:,1)==edg(i,2);                              % edges fed by current edge
    edg(idx2,7) = i;                                        % save e_in
    for jj = find(idx2)'                                    % for all edges fed by current edge
        if any(edg(i,2)==n_splt)                            % if the current outnode is a split node
            idxbr = idxbr+1;                                % increment branch number
        end
        [edg, idxbr] = calc_mdot(jj,idxbr, edg);            % call mdot function for new edge
    end
    end

    function br = calc_dP(lf, edg, br)                      % code to calculate pressure losses in branches
    lf_new = nan(1,n.leaf);                                 % preallocate new set of "leaf" nodes
    idx_leaf = 1;                                           % index for leaf storage
    for ii = lf                                             % for the current set of leaves
        e = edg(:,2)==ii;                                   % edge of current leaf
        n_in = edg(e,1);                                    % innode of this edge
        nidx = br(edg(e,6),1);                              % exponent for calculating pressure
        if odG(ii+1)==sum(br(:,2)==ii)                      % if all connected branches have been calculated
            idx2 = lf_new==ii;                              % find the starting node of branch in new set of leaves
            lf_new = lf_new(~idx2);                         % remove leaf starting this branch from the new set
            if any(leaf==ii)                                % if it is a parallel branch
                dP = 2^nidx*edg(e,9)*(edg(e,5)-params.users(ii,1))^2;   % dP_by = 2^n_br*zetaB*(mdot-mdot_u)^2
                nidx = nidx-1;                              % decrement exponent
                dP = dP+2^nidx*edg(e,8);                    % dP = dP+2^n_br*zetaF*mdot^2
            elseif ii>n.u                                   % if it is a series branch with a split node
                dP = 2^nidx*edg(e,8)+2^nidx*sum(br(br(:,2)==ii,3));     % dP = 2^n_br*mdot^2+2^n_br*sum(dP_ds)
            else                                            % if it is a series branche with a user
                dP = 2^nidx*sum(br(br(:,2)==ii,3));         % dP = 2^n_br*mdot^2+2^n_br*sum(dP_ds)
                nidx = nidx-1;                              % decrement exponent
                dP = dP+2^nidx*edg(e,8);                    % dP = dP+2^n_br*zetaF*mdot^2
            end
            while ~any(n_in==n_splt) && n_in~=0             % while the branch is still continued
                nidx = nidx-1;                              % decrement exponent
                e = (edg(:,2)==n_in);                       % get new edge
                dP = dP+2^nidx*edg(e,8);                    % add feeding pressure loss
                n_in = edg(e,1);                            % get new innode
            end
            br(edg(e,6),2) = n_in;                          % save branch starting node
            br(edg(e,6),3) = dP;                            % save pressure loss in branch
            if n_in~=0                                      % if the root has not been reached
                lf_new(idx_leaf) = n_in;                    % add branch innode to list of "leaves" to be calculated
                idx_leaf = idx_leaf+1;                      % increment leaf storage index
            end
        else                                                % if all branches connected to the branch haven't been calculated
            lf_new(idx_leaf) = ii;                          % add it to be calculated later
            idx_leaf = idx_leaf+1;                          % increment leaf storage index
        end
    end
    if ~all(isnan(lf_new))                                  % if there are still branches to be calculated
        br = calc_dP(unique(rmmissing(lf_new)), edg, br);   % calculate pressure recursively
    end
    end

end


