function [pairs, users2] = pair_pts(users)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
np = size(users,1);
idx = 1:np;
idx = idx(~all(users,2));

%pairs = zeros(nchoosek(numel(idx),2)+np,2,'uint32');
pairs(1:np,:) = [repelem(0,np,1) (1:np)'];
il = np+1;

for i = idx
    [chld,~] = find(~any(users(i,:)&users,2));
    iu = il+numel(chld)-1;
    pairs(il:iu,:) = [repelem(i,numel(chld),1) chld];
    il = iu+1;
end
pairs = pairs(1:iu,:);
users2 = users(pairs(:,2),:);

end