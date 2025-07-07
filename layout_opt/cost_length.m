function [c2, cpairs] = cost_length(mdpts, pairs, params,n)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

%%
mapb = params.mapb;
map = mapb(2:end,:);
mapx = [NaN; map(:,1)];
mapy = [NaN; map(:,2)];
c1 = [NaN; zeros(size(mdpts, 1),1)];
il = n.u+1;
iu = find(all(mdpts<=n.u,2),1,'last');
mdptsac = mdpts;
mdptsac(mdptsac<=n.u) = 0;
mdptsac = mdptsac+1;
%%
while il<size(mdpts, 1)
    idx = mdpts(il:iu,:)+1;
    x = (map(il:iu,1)-mapx(idx)).^2;
    y = (map(il:iu,2)-mapy(idx)).^2;
    c1(il+1:iu+1) = sum(sqrt(x+y),2,'omitnan')+sum(c1(mdptsac(il:iu,:)),2,'omitnan');
    il = iu+1;
    iu = find(all(mdpts<=iu,2),1,'last');
end

%%
pairs = pairs+1;
x = (mapb(pairs(:,1),1)-mapb(pairs(:,2),1)).^2;
y = (mapb(pairs(:,1),2)-mapb(pairs(:,2),2)).^2;
c2 = sum(sqrt(x+y),2)+c1(pairs(:,2));
cpairs = sum(sqrt(x+y),2);

c1 = c1(2:end,:);
end