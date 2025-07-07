%% Load Data
clc, clear%, close all

LS = struct(load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\ThM_params.mat"));
load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\pipe_params.mat")

d1 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_16_22_PIDFollow4\Processed.csv');
d2 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_PIDFollow5\Processed.csv');

d1_p1 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_16_22_PIDFollow4\Peltier1.csv');
d1_p2 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_16_22_PIDFollow4\Peltier2.csv');
d2_p1 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_PIDFollow5\Peltier1.csv');
d2_p2 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_PIDFollow5\Peltier2.csv');

seg = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','R1'};
%% Process & Combine Collected Data
d1(d1.Time>31794,:) = [];
d1_p1(d1_p1.Time>31794,:) = [];
d1_p2(d1_p2.Time>31794,:) = [];

d2(d2.Time>31402,:) = [];
d2_p1(d2_p1.Time>31402,:) = [];
d2_p2(d2_p2.Time>31402,:) = [];
d2(d2.Time<33,:) = [];
d2_p1(d2_p1.Time<33,:) = [];
d2_p2(d2_p2.Time<33,:) = [];

d2.Time = d2.Time+31795-33;
d2_p1.Time = d2_p1.Time+31795-33;
d2_p2.Time = d2_p2.Time+31795-33;

d = [d1; d2];
d_p1 = [d1_p1; d2_p1];
d_p2 = [d1_p2; d2_p2];

clear d1 d2 d1_p1 d1_p2 d2_p1 d2_p2
%% Process Table Data

d.M_Heater = d.M_Heater*3.7854/1000*LS.p/60;
d.M_Supply2 = d.M_Supply2*3.7854/1000*LS.p/60;
d.M_By1 = d.M_By1*3.7854/1000*LS.p/60;
d.M_By2 = d.M_By2*3.7854/1000*LS.p/60;

d{:,[6,7,8,15,16,17,26,27,28,29]} = d{:,[6,7,8,15,16,17,26,27,28,29]}*6.895;

l2 = mean(d.M_Supply2./d.M_Heater,'all');

d.Q1 = pipes.hAs(4)*((d.T_HxIn1+d.T_HxOut1)/2-d.T_ThM1);
d.Q2 = pipes.hAs(10)*((d.T_HxIn2+d.T_HxOut2)/2-d.T_ThM2);
%% Time Ranges, Alpha values
idx2 = cell(0);
idx3 = [];
v_unique = unique([d.V_ThM1, d.V_ThM2], 'rows','stable');
a = [interp1(v.inc, v.a1, v_unique(:,1)), interp1(v.inc, v.a2, v_unique(:,2))];

for i = 1:length(v_unique)
    idx = find(d.V_ThM1==v_unique(i,1) & d.V_ThM2==v_unique(i,2));
    if numel(idx)>1
        k = mat2cell(idx',1,diff([0 find([diff(idx)' inf]>1)]));
        idx2 = [idx2 k];
        idx3 = [idx3, i*ones(1,numel(k))];
    else
        idx2 = [idx2 idx];
        idx3 = [idx3 i];
    end
end

[~,ord] = sort(cellfun(@(v)v(1),idx2));
idx2 = idx2(ord);
idx3 = idx3(ord);
brkdwn.t = cellfun(@(v)d.Time(v)',idx2,'UniformOutput',false);
brkdwn.Th = cellfun(@(v)d.T_HeaterOut(v)',idx2,'UniformOutput',false);
brkdwn.Ta = cellfun(@(v)d.T_HeaterOut(v)',idx2,'UniformOutput',false);
brkdwn.Q1 = cellfun(@(v)d.Q1(v)',idx2,'UniformOutput',false);
brkdwn.Q2 = cellfun(@(v)d.Q2(v)',idx2,'UniformOutput',false);
brkdwn.a = a(idx3,:);


clear ord k v_unique idx2 idx3
%% Create A matrices
m = cell(1,14);
m([1 14]) = {mean(d.M_Heater)};
m([2 7]) = {m{1}*(1-l2)};
m([8 13])= {m{1}*l2};
m(6) = {m{2}*(1-brkdwn.a(:,1))};
m([3 4 5]) = {m{2}*brkdwn.a(:,1)};
m(12) = {m{8}*(1-brkdwn.a(:,2))};
m([9 10 11]) = {m{8}*brkdwn.a(:,2)};

%%
c1 = cell(1,14);
c2 = pipes.hAs./(LS.p*LS.cp*pipes.V);
c3 = cell(1,14);
for i = 1:14
    c1{i} = m{i}/(LS.p*pipes.V(i));
    c3{i} = -(c1{i}+c2(i));
end
%%
L = 12;
K = 1;
a11 = c3{1};
a21 = [c1{2}; zeros(5,1); c1{8}; zeros(5,1)];
a33 = c3{14};
a32 = [zeros(1,5) (1-l2)*c1{14}, zeros(1,5) l2*c1{14}];

A1o = zeros(6);
A2o = zeros(6);
A1o(1,1) = c3{1+1};
A1o(6,6) = c3{6+1};
A2o(1,1) = c3{1+7};
A2o(6,6) = c3{6+7};

n = size(brkdwn.a,1);
A = cell(1,n);
for i = 1:n
    A1 = A1o;
    A2 = A2o;
    for j = 2:5
        A1(j,j) = c3{j+1}(i);
        A2(j,j) = c3{j+7}(i);
    end
    A1(2,1) = c1{2+1}(i);
    A1(3,2) = c1{3+1}(i);
    A1(4,3) = c1{4+1}(i);
    A1(5,1) = c1{5+1}(i);
    A1(6,4) = brkdwn.a(i,1)*c1{6+1};
    A1(6,5) = (1-brkdwn.a(i,1))*c1{6+1};
    A2(2,1) = c1{2+7}(i);
    A2(3,2) = c1{3+7}(i);
    A2(4,3) = c1{4+7}(i);
    A2(5,1) = c1{5+7}(i);
    A2(6,4) = brkdwn.a(i,2)*c1{6+7};
    A2(6,5) = (1-brkdwn.a(i,2))*c1{6+7};
    a22 = [A1 zeros(6);zeros(6) A2];
    A{i} = [a11 zeros(K,L) zeros(K,K); a21 a22 zeros(L,K); zeros(K,K) a32 a33];
end
clear a11 21 a33 a32 A1o A2o A1 A2 a22
%% B, C matrices
C = eye(14);
e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'];
e12 = [c2(1,[8 9])';0;c2(1,[11 12 13])'];

e21 = [0; 0; -1/(LS.p*LS.cp*pipes.V(4)); 0; 0; 0];
e22 = [0; 0; -1/(LS.p*LS.cp*pipes.V(10)); 0; 0; 0];
B = [c1{1};zeros(K+L,1)];
E = [c2(1) 0 0; e11 e21 zeros(6,1); e12 zeros(6,1) e22; c2(14) 0 0];
%% SS Model
x0 = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ByIn2(1) d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1) d.T_PumpIn(1)];
y = [];
for i = 5
    u = [brkdwn.Th{i}; brkdwn.Ta{i}; brkdwn.Q1{i}; brkdwn.Q2{i}];
    model = ss(A{i},[B E],C,0);
    yi = lsim(model,u',brkdwn.t{i},x0);
    x0 = yi(end,:);
    y = [y; yi];
end

%% Plot results
figure
plot(brkdwn.t{5},y)
