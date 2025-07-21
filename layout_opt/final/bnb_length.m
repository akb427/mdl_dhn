function [tr_best, c_best] = bnb_length(pairs, users,c, n)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here


%% Bound
tr = zeros(n.u,2,100);
ctr = NaN(1,100);


idx =find(all(users,2));
[cb,idx_best] = min(c(idx));
ctr(1) = cb;
tr(:,:,1) = [pairs(idx(idx_best),:); zeros(n.u-1,2)];
idxtn = 2;
idx(idx_best) = [];
pairs(idx,:) = [];
users(idx,:) = [];
c(idx,:) = [];

% Eliminate already unfeasible points
idx = c<=cb;
pairs = pairs(idx,:);
users = users(idx,:);
c = c(idx,:);

%% Call recursion
splt = find(pairs(:,1)==0,1,'last');

% for all possible starting trees
for i = 1:splt
    trs = zeros(n.u,2);
    trs(1,:) = pairs(i,:);
    add_node(trs, users(i,:), c(i),1,i);
end

[c_best, idx_best] = min(ctr);
tr_best = tr(:,:,idx_best);
%% Recursive Function
    function add_node(tr1, u1, c1, p1, idx1)
    % check stop
    if all(u1)&&c1<cb
        cb = c1;
        ctr(1,idxtn) = c1; 
        tr(:,:,idxtn) = tr1;
        idxtn = idxtn+1;
        if idxtn>100
            warning('Not enough space preallocated in tree saver')
        end
    elseif c1<cb
        % parallel but only from above
        [idxa,~] = find(pairs(min(idx1),1)==pairs(1:min(idx1)-1,1));
        idxa = idxa(~any(u1 & users(idxa,:),2))';
        for ii = idxa
            tr2 = tr1;
            tr2(p1+1,:) = pairs(ii,:);
            u2 = users(ii,:)|u1;
            c2 = c1+c(ii);
            add_node(tr2, u2, c2,p1+1,[idx1;ii]);
        end
        % children of newly added node in tree w
        idxb = find(any(pairs(idx1,2)'==pairs(:,1),2));
        idxb = idxb(~any(u1 & users(idxb,:),2))';
        for ii = idxb
            tr2 = tr1;
            tr2(p1+1,:) = pairs(ii,:);
            u2 = users(ii,:)|u1;
            c2 = c1+c(ii);
            add_node(tr2, u2, c2,p1+1,ii);
        end
    end
    end
end

