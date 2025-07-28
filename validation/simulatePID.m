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

addpath(fullfile(pth, 'figures'));

%% System parameters;

LS = struct(load(pth_data+"ThM_params.mat"));
[pipes, v] = get_pipe_params(pth_data,0);
LS.V_pipes = pipes.V;

%% Data for Both Thermal Masses

% First data set
data1.dhn = readtable(pth_data+"pid1_Processed.csv");
data1.pelt1 = readtable(pth_data+"pid1_Peltier1");
data1.pelt2 = readtable(pth_data+"pid1_Peltier2");

% Second data set
data2.dhn = readtable(pth_data+"pid2_Processed.csv");
data2.pelt1 = readtable(pth_data+"pid2_Peltier1");
data2.pelt2 = readtable(pth_data+"pid2_Peltier2");

%% Process & Combine Collected Data

% Combine the data into one set
time_rm = [0 31794; 33 31402];
data = combine_data(data1,data2,time_rm);

% convert units and filter
data.dhn = convertUnits(data.dhn, LS.p);
data.dhn_filt = clean_data(data.dhn);

% split 50/50 into calibration and validation
n = floor(height(data.dhn)/2);
data_cal = data.dhn(1:n,:);
data_val = data.dhn_filt(n+1:end,:);
data_val.Time = data_val.Time-data_val.Time(1);
L1 = 1-mean(data_cal.M_Supply2./data_cal.M_Heater);

%% Optimize parameters
cal_file = pth_data+"phAS_caldata.mat";
if isfile(cal_file)
    load(cal_file,"optall")
else
    opts = optimoptions('fmincon','MaxFunctionEvaluations',60000);
    f = @(x)sim_pid(x,data_cal,LS,0);
    [optall2, emin1(1)] = fmincon(f,pipes.hAs,[],[],[],[],zeros(18,1),100*ones(18,1),[],opts);
    [err, y_cal, ~, ~, m_cal, an_cal] = sim_pid(optall2,data_cal,LS,0);
    optall2(1:2) = optall(1:2);
end
[~, y, ~, ~, m, an] = sim_pid(optall,data_val,LS,1,L1);
%% Plot Results

% figPID_can(dval,y,m)
figPID_art(data_val,y,m)
% figExp(d,n);
