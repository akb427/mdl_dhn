clc; clear; close all

LS = struct(load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\ThM_params.mat"));
[pipes, v] = pipe_params(0);
LS.V_pipes = pipes.V;
% LS.inc = v.inc;
% LS.a1 = v.a1;
% LS.a2 = v.a2;
% LS.a1(1) = 0;
% LS.a2(1) = 0;
%% Data for Both Thermal Masses

d = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_Warmup5\Processed.csv');
d_p1 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_Warmup5\Peltier1.csv');
d_p2 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_Warmup5\Peltier2.csv');

%% Process & Combine Collected Data
% d(d.Time>2000,:) = [];
% d_p1(d_p1.Time>2000,:) = [];
% d_p2(d_p2.Time>2000,:) = [];
d(d.Time<1050,:) = [];
d_p1(d_p1.Time<1050,:) = [];
d_p2(d_p2.Time<1050,:) = [];
d_p1.Time = d_p1.Time-d.Time(1);
d_p2.Time = d_p2.Time-d.Time(1);
d.Time = d.Time-d.Time(1);


d = convertUnits(d,LS.p);
d.Q1 = interp1(d_p1.Time, d_p1.Power*0.79, d.Time);
d.Q2 = interp1(d_p2.Time, d_p2.Power*0.79, d.Time);
d.Q1(1) = 0;
d.Q2(1) = 0;
n = size(d);
d = filtdata(d);

%% Optimize parameters
load('cal_warmup5_w.mat')
opts = optimoptions('fmincon','MaxFunctionEvaluations',60000);
f = @(x)sim_pid(x,d,LS,0);
[optall2, emin1(1)] = fmincon(f,optall2,[],[],[],[],zeros(18,1),100*ones(18,1),[],opts);
[err, y_cal, ~, ~, m_cal, an_cal] = sim_pid(optall2,d,LS,0);
%[~, y, ~, ~, m, an] = sim_pid(optall2,dval,LS,1,L1);
%% Plot Results
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

%figPID_can(dval,y,m)
figPID_art(d,y_cal,m_cal)
%figExp(d,n);

set(groot,'defaultAxesTickLabelInterpreter','tex');  
set(groot,'defaulttextinterpreter','tex');
set(groot,'defaultLegendInterpreter','tex');