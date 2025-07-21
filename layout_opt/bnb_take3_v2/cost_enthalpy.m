function [c2, tc] = cost_enthalpy(mdpts, usersm, pairs, usersp, params,n)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

%%
tc.Tin = params.Ts-params.x;
tc.mi = params.mI/n.u;

map = params.mapb(2:end,:);
mapx = [NaN; map(:,1)];
mapy = [NaN; map(:,2)];
c1 = [NaN; zeros(size(mdpts, 1),1)];
il = n.u+1;
iu = find(all(mdpts<=n.u,2),1,'last');
mdptsac = mdpts;
mdptsac(mdptsac<=n.u) = 0;
mdptsac = mdptsac+1;

D = zeros(size(mdpts));
D(mdpts>0) = params.Ds;
D(mdpts>n.u) = params.DL;

nu = sum(usersm,2);
m = zeros(size(mdpts));
m(mdpts>0) = tc.mi;
m(mdpts>n.u) = nu(mdpts(mdpts>n.u),1)*tc.mi;
tc.mcp_mdpts = m*params.cp;
%%
tc.L_mdpts = zeros(size(mdpts));

while il<size(mdpts, 1)
    idx = mdpts(il:iu,:)+1;
    x = (map(il:iu,1)-mapx(idx)).^2;
    y = (map(il:iu,2)-mapy(idx)).^2;
    tc.L_mdpts(il:iu,:) = sqrt(x+y);
    tc.hAs_mdpts(il:iu,:) = pi*params.h*tc.L_mdpts(il:iu,:).*D(il:iu,:);
    To = tc.mcp_mdpts(il:iu,:)./(tc.mcp_mdpts(il:iu,:)+tc.hAs_mdpts(il:iu,:))*tc.Tin+tc.hAs_mdpts(il:iu,:)./(tc.mcp_mdpts(il:iu,:)+tc.hAs_mdpts(il:iu,:))*params.Ta;
    E = tc.mcp_mdpts(il:iu,:).*(tc.Tin-To);
    c1(il+1:iu+1) = sum(E,2,'omitnan')+sum(c1(mdptsac(il:iu,:)),2,'omitnan');
    il = iu+1;
    iu = find(all(mdpts<=iu,2),1,'last');
end

%%
D = params.Ds*ones(size(pairs,1),1);
D(pairs(:,2)>n.u) = params.DL;

nu = sum(usersp,2);
m = nu*tc.mi;
mcp = m*params.cp;

pairs = pairs+1;
x = (params.mapb(pairs(:,1),1)-params.mapb(pairs(:,2),1)).^2;
y = (params.mapb(pairs(:,1),2)-params.mapb(pairs(:,2),2)).^2;
tc.L_pairs = sqrt(x+y);
hAs = pi*params.h*tc.L_pairs.*D;
To = mcp./(mcp+hAs)*tc.Tin+hAs./(mcp+hAs)*params.Ta;
E = mcp.*(tc.Tin-To);
c2 = sum(E,2)+c1(pairs(:,2));

%tc.c_mpts = c1(2:end,:);
end