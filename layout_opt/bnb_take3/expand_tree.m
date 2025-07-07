function [G_new,n] = expand_tree(G,mdpts,n, flag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   flag - allows you to renumber split nodes to n_u+1:n_u+n_s

%% Expand Tree
idx = all(G==0,2);
G(idx,:) = [];

G_new = zeros(n.u+ceil(n.u/2)+1,2);
idx = size(G,1);
G_new(1:idx,:) = G;
idx = idx+1;
for i = G(G(:,2)>n.u,2)'
    append_node(i);
end
idx2 = all(G_new==0,2);
G_new(idx2,:) = [];
spltnds = unique(G_new(G_new>n.u));
n.s = numel(spltnds);
if flag
    for i = n.u+1:n.u+numel(spltnds)
    G_new(G_new==spltnds(i-n.u))=i;
    end
end

%% Functions
function append_node(nd)
    for ii = nd
        nd_new = mdpts(nd,:);
        for jj = nd_new
            if jj>n.u
                G_new(idx,:) = [ii jj];
                idx = idx+1;
                append_node(jj);
            elseif jj>0
                G_new(idx,:) = [ii jj];
                idx = idx+1;
            end
        end

    end
end

end
