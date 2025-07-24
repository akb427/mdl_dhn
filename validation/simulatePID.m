%FUNCTION_NAME  One-line summary of what the function does.
%
%   [out1, out2] = FUNCTION_NAME(in1, in2)
%
%   DESCRIPTION:
%   
%
%   INPUTS:
%       in1  - Description of input 1 (type, format, units if applicable)
%       in2  - Description of input 2
%
%   OUTPUTS:
%       out1 - Description of output 1 (what it represents)
%       out2 - Description of output 2
%
%   DEPENDENCIES:
%
%   SEE ALSO:

%% Setup workspace

clc; clear; close all
pth = string(pwd);
pth_data = pth+filesep+"data"+filesep;

%% System parameters;

LS = struct(load(pth_data+"ThM_params.mat"));
[pipes, v] = get_pipe_params(pth_data,0);
LS.V_pipes = pipes.V;

%% Data for Both Thermal Masses

% First data set
d1 = readtable(pth_data+"pid1_Processed.csv");
d1_p1 = readtable(pth_data+"pid1_Peltier1");
d1_p2 = readtable(pth_data+"pid1_Peltier2");

% Second data set
d2 = readtable(pth_data+"pid2_Processed.csv");
d2_p1 = readtable(pth_data+"pid2_Peltier1");
d2_p2 = readtable(pth_data+"pid2_Peltier2");

%% Process & Combine Collected Data

% trim time in data set 1
time_rm1 = 31794;
d1(d1.Time>time_rm1,:) = [];
d1_p1(d1_p1.Time>time_rm1,:) = [];
d1_p2(d1_p2.Time>time_rm1,:) = [];

% trim time in data set 2
time_rm2_upper = 31402;
time_rm2_lower = 33;
d2(d2.Time>time_rm2_upper,:) = [];
d2_p1(d2_p1.Time>time_rm2_upper,:) = [];
d2_p2(d2_p2.Time>time_rm2_upper,:) = [];
d2(d2.Time<time_rm2_lower,:) = [];
d2_p1(d2_p1.Time<time_rm2_lower,:) = [];
d2_p2(d2_p2.Time<time_rm2_lower,:) = [];

% time offset for combination
d2.Time = d2.Time+time_rm1+1-time_rm2_lower;
d2_p1.Time = d2_p1.Time+time_rm1+1-time_rm2_lower;
d2_p2.Time = d2_p2.Time+time_rm1+1-time_rm2_lower;

% combine data into 1 vector
d = [d1; d2];
d_p1 = [d1_p1; d2_p1];
d_p2 = [d1_p2; d2_p2];
% interpolate peltier data
d.Q1 = interp1(d_p1.Time, d_p1.Power*0.79, d.Time);
d.Q2 = interp1(d_p2.Time, d_p2.Power*0.79, d.Time);
% convert units and filter
d = convertUnits(d,LS.p);
df = filtdata(d);

% split into calibration and validation
n = floor(height(d)/2);
dcal = d(1:n,:);
dval = df(n+1:end,:);
dval.Time = dval.Time-dval.Time(1);
L1 = 1-mean(dcal.M_Supply2./dcal.M_Heater);

%% Optimize parameters
cal_file = pth_data+filesep+"phAS_caldata.mat";
if isfile(cal_file)

else
load(')
% opts = optimoptions('fmincon','MaxFunctionEvaluations',60000);
% f = @(x)sim_pid(x,dcal,LS,0);
% [optall2, emin1(1)] = fmincon(f,optall,[],[],[],[],zeros(18,1),100*ones(18,1),[],opts);
%[err, y_cal, ~, ~, m_cal, an_cal] = sim_pid(optall2,dcal,LS,0);
%optall2(1:2) = optall(1:2);
[~, y, ~, ~, m, an] = sim_pid(optall,dval,LS,1,L1);
%% Plot Results
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

% figPID_can(dval,y,m)
figPID_art(dval,y,m)
% figExp(d,n);

set(groot,'defaultAxesTickLabelInterpreter','tex');  
set(groot,'defaulttextinterpreter','tex');
set(groot,'defaultLegendInterpreter','tex');