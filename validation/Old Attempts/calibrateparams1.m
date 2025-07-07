clc, clear, close all

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
%% Calibration Data

d = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\11_15_22_CalibrateThM\CalibrateThM.csv');

%% Process Table Data

d.M_Heater = d.M_Heater*3.7854/1000*LS.p/60;
d.M_Supply2 = d.M_Supply2*3.7854/1000*LS.p/60;
d.M_By1 = d.M_By1*3.7854/1000*LS.p/60;
d.M_By2 = d.M_By2*3.7854/1000*LS.p/60;

d{:,[6,7,8,15,16,17,26,27,28,29]} = d{:,[6,7,8,15,16,17,26,27,28,29]}*6.895;

[d, d_p1, d_p2] = filtdata(d, d_p1,d_p2);

LS.V_pipes = pipes.V;
LS.a1 = v.a1;
LS.a2 = v.a2;
LS.inc = v.inc;
 
clear v

%% Minimzation
f = @(hAs)simresults_opt(hAs,d,d_p1,d_p2,LS);
hAs_new = fmincon(f,pipes.hAs,-1*eye(14),zeros(14,1));

xf = simresults(hAs_new,d,d_p1,d_p2,LS);
