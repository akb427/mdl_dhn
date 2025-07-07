clc; clear; close all

load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\Data Processing 3\hAs_cal.mat")
LS = struct(load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\ThM_params.mat"));
[pipes, v] = pipe_params(0);
LS.V_pipes = pipes.V;
LS.inc = v.inc;
LS.a1 = v.a1;
LS.a2 = v.a2;
LS.a1(1) = 0;
LS.a2(1) = 0;
%% Data for Both Thermal Masses
d1 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_16_22_PIDFollow4\Processed.csv');
d2 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_PIDFollow5\Processed.csv');

d1_p1 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_16_22_PIDFollow4\Peltier1.csv');
d1_p2 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_16_22_PIDFollow4\Peltier2.csv');
d2_p1 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_PIDFollow5\Peltier1.csv');
d2_p2 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\12_20_22_PIDFollow5\Peltier2.csv');

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
d = convertUnits(d,LS.p);
d_p1 = [d1_p1; d2_p1];
d_p2 = [d1_p2; d2_p2];
d.Q1 = interp1(d_p1.Time, d_p1.Power*0.79, d.Time);
d.Q2 = interp1(d_p2.Time, d_p2.Power*0.79, d.Time);
%df = filtdata(d);
% figure
% hold on
% plot(df.Time, df.M_Heater)
% plot(df.Time, d.M_Heater)
% figure
% hold on
% plot(df.Time, df.T_ByOut1)
% plot(d.Time, d.T_ByOut1)
%% Optimize parameters
opts = optimoptions('fmincon','MaxFunctionEvaluations',60000);
f = @(x)sim_ThMboth(x,d,LS,0);
[opt1, emin1(1)] = fmincon(f,hAs_fin,[],[],[],[],zeros(16,1),100*ones(16,1),[],opts);

%% Simulate Results

sim_ThMboth(optall,d,LS,1);
