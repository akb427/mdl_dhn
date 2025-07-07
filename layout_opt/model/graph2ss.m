function [A,B,E] = graph2ss(G,params,n)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Coefficients

V.u = 1:n.u;
V.s = n.u+1:n.u+n.s;
V.leaf = find(outdegree(G)==0)-1;
V.unl = setdiff(V.u,V.leaf);

c.F = zeros(n.k,3);
c.S1 = zeros(n.u,3);
c.S2 = zeros(n.u,3);
c.S3 = zeros(n.u,3);
c.B = zeros(n.k,3);

c.F(:,1) = params.pipes(:,5)./(params.p*pi/4*params.pipes(:,2).^2.*params.pipes(:,1));
c.F(:,2) = (params.h*pi*params.pipes(:,1).*params.pipes(:,2))./(params.p*params.cp*pi/4*params.pipes(:,2).^2.*params.pipes(:,1));
c.F(:,3) = -(c.F(:,1)+c.F(:,2));

c.R = c.F;

c.S1(:,1) = params.users(:,1)./(params.p*pi/4*params.users(:,6).^2.*params.users(:,3));
c.S1(:,2) = (params.h*pi*params.users(:,4).*params.users(:,7))./(params.p*params.cp*pi/4*params.users(:,7).^2.*params.users(:,4));
c.S1(:,3) = -(c.S1(:,1)+c.S1(:,2));

c.S2(:,1) = params.users(:,1)./(params.p*pi/4*params.users(:,7).^2.*params.users(:,4));
c.S2(:,2) = 1./(params.p*params.cp*pi/4*params.users(:,7).^2.*params.users(:,4));

c.S3(:,1) = params.users(:,1)./(params.p*pi/4*params.users(:,8).^2.*params.users(:,5));
c.S3(:,2) = (params.h*pi*params.users(:,4).*params.users(:,7))./(params.p*params.cp*pi/4*params.users(:,7).^2.*params.users(:,4));
c.S3(:,3) = -(c.S3(:,1)+c.S3(:,2));

c.B(V.leaf,1) = params.pipes(V.leaf,8)./(params.p*pi/4*params.pipes(V.leaf,7).^2.*params.pipes(V.leaf,6));
c.B(V.leaf,2) = (params.h*pi*params.pipes(V.leaf,6).*params.pipes(V.leaf,7))./(params.p*params.cp*pi/4*params.pipes(V.leaf,7).^2.*params.pipes(V.leaf,6));
c.B(:,3) = -(c.B(:,1)+c.B(:,2));

%% A matrix components

Au = cell(n.u,1);

for i = 1:n.u
    Au{i} = [c.F(i,3) 0 0 0 0; c.S1(i,1) c.S1(i,3) 0 0 0; 0 c.S2(i,1) -c.S2(i,1) 0 0; 0 0 c.S3(i,1) c.S3(i,3) 0; 0 0 0 params.users(i,1)/params.pipes(i,5)*c.R(i,1) c.R(i,3)];
    if ismember(i,V.leaf)
        Au{i}(5,6) = params.pipes(i,8)/params.pipes(i,5)*c.R(i,1) ;
        Au{i}(6,1) = c.B(i,1);
        Au{i}(6,6) = c.B(i,3);
    end
end

%% A
A = cell(3);
A{1,3} = {zeros(n.s)};
A{3,1} = {zeros(n.s)};
A{1,1} = {zeros(n.s)};
A{1,2} = cell(n.s,n.u);
A{1,2}(:,V.unl) = {zeros(1,5)};
A{1,2}(:,V.leaf) = {zeros(1,6)};
A{2,1} = cell(n.u,n.s);
A{2,1}(V.unl,:) = {zeros(5,1)};
A{2,1}(V.leaf,:) = {zeros(6,1)};
A{2,2} = cell(n.u,n.u);
A{2,2}(V.unl,V.unl) = {zeros(5,5)};
A{2,2}(V.leaf,V.leaf) = {zeros(6,6)};
A{2,2}(V.unl,V.leaf) = {zeros(5,6)};
A{2,2}(V.leaf,V.unl) = {zeros(6,5)};
A{2,3} = A{2,1};
A{3,2} = A{1,2};

A{3,3} = {zeros(n.s)};

%%
A{2,2}(sub2ind([n.u,n.u],V.u,V.u)) = Au(V.u,1);
A{1,1}{1}(sub2ind([n.s, n.s],1:n.s,1:n.s)) = c.F(n.u+1:n.u+n.s,3);
A{3,3}{1}(sub2ind([n.s, n.s],1:n.s,1:n.s)) = c.R(n.u+1:n.u+n.s,3);

for i = 1:n.u
    for j = str2double(successors(G,string(i)))'
        if ismember(j,V.unl)
            A{2,2}{i,j} = [zeros(4,5); zeros(1,4) params.pipes(j,5)/params.pipes(i,5)*c.R(i,1)];       %aR22
        elseif ismember(j,V.leaf)
            A{2,2}{i,j} = [zeros(4,6); zeros(1,4) params.pipes(j,5)/params.pipes(i,5)*c.R(i,1) 0];       %bR22
        elseif ismember(j,V.s)
            A{2,3}{i,j-n.u} = [params.pipes(j,5)/params.pipes(i,5)*c.R(i,1); zeros(4,1)];                      %a23
        end
    end
    for j = str2double(predecessors(G,string(i)))'
        if ismember(j,V.u)
            if ~ismember(i,V.leaf)
                A{2,2}{i,j} = [c.F(i,1) zeros(1,4); zeros(4,5)]; %aF22
            else
                A{2,2}{i,j} = [c.F(i,1) zeros(1,4); zeros(5,5)]; %bF22
            end
        elseif ismember(j,V.s)
            if ~ismember(i,V.leaf)
                A{2,1}{i,j-n.u} = [c.F(i,1); zeros(4,1)]; %a21
            else
                A{2,1}{i,j-n.u} = [c.F(i,1); zeros(5,1)]; %b21
            end
        end
        
    end
end
for i = n.u+1:n.u+n.s
    for j = str2double(successors(G,string(i)))'
        if ismember(j,V.unl)
            A{3,2}{i-n.u,j} = [zeros(1,4) params.pipes(j,5)/params.pipes(i,5)*c.R(i,1)];       %a32
        elseif ismember(j, V.leaf)
            A{3,2}{i-n.u,j} = [zeros(1,4) params.pipes(j,5)/params.pipes(i,5)*c.R(i,1) 0];     %b32
        elseif ismember(j, V.s)
            A{3,3}{1}(i-n.u, j-n.u) = params.pipes(j,5)/params.pipes(i,5)*c.R(i,1);
        end
    end
    for j = str2double(predecessors(G,string(i)))'
        if ismember(j,V.u)
            A{1,2}{i-n.u,j} = [c.F(i,1) zeros(1,4)];       %a12
        elseif ismember(j, V.s)
            A{1,1}{1}(i-n.u,j-n.u) = c.F(i,1);
        end
    end
end

A = cell2mat(cellfun(@cell2mat, A, 'UniformOutput', false));

%% B
B = cell(2*n.s+n.u,1);
B([1:n.s n.s+n.u+1:end],:) = {0};
B(V.unl+n.s,:) = {zeros(5,1)};
B(V.leaf+n.s,:) = {zeros(6,1)};
for i = str2double(successors(G,"0"))'
    if ismember(i,V.s)
        B{i-n.u,1} = c.F(i,1);
    elseif ismember(i,V.unl)
        B{i+n.s,1} = [c.F(i,1); zeros(4,1)];
    elseif ismember(i,V.leaf)
        B{i+n.s,1} = [c.F(i,1); zeros(5,1)];
    end
end
B = cell2mat(B);

%% E
E = cell(2*n.s+n.u,1+n.u);
E([1:n.s n.s+n.u+1:end],:) = {0};
E(V.unl+n.s,:) = {zeros(5,1)};
E(V.leaf+n.s,:) = {zeros(6,1)};
for i = 1:n.u+n.s
    if ismember(i,V.s)
        E{i-n.u,1} = c.F(i,2);
        E{i+n.s,1} = c.R(i,2);
    elseif ismember(i,V.unl)
        E{i+n.s,1} = [c.F(i,2); c.S1(i,2); 0; c.S3(i,2); c.R(i,2)]; %e1
        E{i+n.s,i+1} = [0;0;c.S2(i,2);0;0];                         %e2
    elseif ismember(i,V.leaf)
        E{i+n.s,1} = [c.F(i,2); c.S1(i,2); 0; c.S3(i,2); c.R(i,2); c.B(i,2)]; %e3
        E{i+n.s,i+1} = [0;0;c.S2(i,2);0;0;0]; %e4
    end
end
E = cell2mat(E);
end