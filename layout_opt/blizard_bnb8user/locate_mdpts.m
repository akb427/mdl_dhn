function [map] = locate_mdpts(mdpts,map, N)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Setup

mapx = [NaN; map(:,1); zeros(size(mdpts,1)-N,1)];
mapy = [NaN; map(:,2); zeros(size(mdpts,1)-N,1)];
il = N+1;
iu = find(all(mdpts<=N,2),1,'last');
%%
while il<size(mdpts, 1)
    idx = mdpts(il:iu,:)+1;
    ptsx = mapx(idx);
    ptsx = mean(ptsx,2, 'omitnan');
    ptsy = mapy(idx);
    ptsy = mean(ptsy,2, 'omitnan');
    mapx(il+1:iu+1) = ptsx;
    mapy(il+1:iu+1) = ptsy;
    il = iu+1;
    iu = find(all(mdpts<=iu,2),1,'last');
end
map = [mapx(2:end) mapy(2:end)];
end