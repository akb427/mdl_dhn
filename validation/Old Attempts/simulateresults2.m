%% Load Data
%clc, clear%, close all

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

[d, d_p1, d_p2] = filtdata(d, d_p1,d_p2);

L2 = mean(d.M_Supply2./d.M_Heater,'all');

n = size(d,1);

d.Q1 = pipes.hAs(4)*((d.T_HxIn1+d.T_HxOut1)/2-d.T_ThM1);
d.Q1 = zeros(n,1);
d.Q2 = pipes.hAs(10)*((d.T_HxIn2+d.T_HxOut2)/2-d.T_ThM2);


%% Model Constants
%L = 12;
L = 14;
K = 1;

c2 = pipes.hAs./(LS.p*LS.cp*pipes.V);
b = [pipes.hAs(4)/(LS.p*LS.cp*LS.V1) LS.hAs_ThM1/(LS.p*LS.cp*LS.V1) 1/(LS.p*LS.cp*LS.V1);...
    pipes.hAs(10)/(LS.p*LS.cp*LS.V2) LS.hAs_ThM2/(LS.p*LS.cp*LS.V2) 1/(LS.p*LS.cp*LS.V2)];
% e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'];
% e12 = [c2(1,[8 9])';0;c2(1,[11 12 13])'];
% e21 = [0; 0; -1/(LS.p*LS.cp*pipes.V(4)); 0; 0; 0];
% e22 = [0; 0; -1/(LS.p*LS.cp*pipes.V(10)); 0; 0; 0];
%E = [c2(1) 0 0; e11 e21 zeros(6,1); e12 zeros(6,1) e22; c2(14) 0 0];

e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'; b(1,2)];
e12 = [c2(1,[8 9])';0;c2(1,[11 12 13])'; b(2,2)];
e21 = [zeros(6,1); b(1,3)];
e22 = [zeros(6,1); b(2,3)];
E = [c2(1) 0 0; e11 e21 zeros(7,1); e12 zeros(7,1) e22; c2(14) 0 0];

x = zeros(n,2*K+L);
%x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ByIn2(1) d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1) d.T_PumpIn(1)];
x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ThM1(1) d.T_ByIn2(1) d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1) d.T_ThM2(1) d.T_PumpIn(1)];

P1 = 0.79*interp1(d_p1.Time, d_p1.Power,d.Time);
P2 = 0.79*interp1(d_p2.Time, d_p2.Power,d.Time);

%% Simulate

for i = 1:n
a = [interp1(v.inc, v.a1, d.V_ThM1(i)), interp1(v.inc, v.a2, d.V_ThM2(i))];    
m = zeros(1,14);
m([1 14]) = d.M_Heater(i);
m([2 7]) = d.M_Heater(i)*(1-L2);
m([8 13])= d.M_Heater(i)*L2;
m(6) = (1-a(:,1))*m(2);
m([3 4 5]) = a(:,1)*m(2);
m(12) = (1-a(:,2))*m(8);
m([9 10 11]) = a(:,2)*m(8);

c1 = m./(LS.p*pipes.V);
c3 = -(c1+c2);

A = makeA(c1,c2,c3,b,a,L2,1);
B = [c1(1);zeros(K+L,1)];
%u = [d.T_HeaterOut(i); d.T_Ambient(i); d.Q1(i); d.Q2(i)];
u = [d.T_HeaterOut(i); d.T_Ambient(i); P1(i); P2(i)];

B_full = [B E];
Ad = (A+eye(2*K+L));
Bd = B_full;
%Bd = (Ad-eye(14))\A*B_full;
x(i+1,:) = Ad*x(i,:)'+Bd*u;
end

%%
d_sim = array2table([(0:n)',x], 'VariableNames', ['Time', seg(1:7), 'ThM1',seg{8:13}, 'ThM2', seg{14}]);

%%

T_pipe = [x(:,1:7) x(:,9:14) x(:,16)];
figure('Name', 'Temp')
tiledlayout(1,2,'TileSpacing','compact')
nexttile
hold on
plot(d_sim.Time(1:end-1), d.T_HeaterOut, '--k','linewidth',2)
plot(d_sim.Time, T_pipe(:,1:7), '--','Linewidth',2)
plot(d_sim.Time, T_pipe(:,8:end), 'linewidth',2)
plot(d_sim.Time(1:end-1), d.T_Ambient, 'k','linewidth',2)
plot(d_sim.Time, d_sim.ThM1,':', d_sim.Time, d_sim.ThM2, ':','linewidth',2)
legend(['Heater',seg,'Ambient','ThM1','ThM2'])
ylim([15 40])
box on; grid on; hold off

nexttile
T_pipes = [d.T_PumpIn d.T_Heater d.T_HeaterOut d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_Supply2 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2];

hold on
plot(d.Time, T_pipes(:,1:7), '--','Linewidth',2)
plot(d.Time, T_pipes(:,8:end), 'linewidth',2)
plot(d.Time, d.T_Ambient, 'k','linewidth',2)
plot(d.Time, d.T_ThM1,':', d.Time, d.T_ThM2, ':','linewidth',2)
ylim([15 40])
legend('Pump In', 'Heater', 'Heater Out', 'By In 1', 'Hx In 1','Hx Out1' ,'By Out 1', 'Supply 2', 'By In 2', 'Hx In 2', 'Hx Out 2', 'By Out 2', 'Return','Ambient','ThM1','ThM2')
box on; grid on; hold off

%% Error Metric

E_act = mean(LS.cp*d.M_Heater.*(d.T_HeaterOut-d.T_PumpIn));
E_sim = mean(LS.cp*d.M_Heater.*(d.T_HeaterOut-x(2:end,end)));