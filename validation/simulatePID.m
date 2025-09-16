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
% plot filtered data
% fig_dim(data.dhn_filt)

% split 50/50 into calibration and validation
idx_split = floor(height(data.dhn)/2);
data_cal = data.dhn(1:idx_split,:);
data_val = data.dhn_filt(idx_split+1:end,:);
data_val.Time = data_val.Time-data_val.Time(1);
L1 = 1-mean(data_cal.M_Supply2./data_cal.M_Heater);

%% Optimize parameters
cal_file = pth_data+"phAS_caldata.mat";
if isfile(cal_file)
    load(cal_file,"optall")
else
    opts = optimoptions('fmincon','MaxFunctionEvaluations',60000);
    f = @(x)sim_pid(x,data_cal,LS,0);
    [optall, emin1(1)] = fmincon(f,[1 1 pipes.hAs LS.hAs_cp1 LS.hAs_cp2],[],[],[],[],zeros(18,1),20*ones(18,1),[],opts);
    [err, y_cal, ~, ~, m_cal, an_cal] = sim_pid(optall,data_cal,LS,0);
end
[esim, d_sim, ~, ~, m_sim, an] = sim_pid(optall,data_val,LS,1,L1);


%% Plot settings

params_plot.fn = 10;
params_plot.pos = [320,230,461,320];

n_val = size(data_val,1);
params_plot.simt = (1:n_val)/(60*60);
data_val.Time_hr = data_val.Time/(60*60);

% Combine data
d_act = [data_val.T_Supply2 data_val.T_ByIn1 data_val.T_HxIn1 data_val.T_HxOut1 data_val.T_ByOut1 data_val.T_ByIn2...
    data_val.T_HxIn2 data_val.T_HxOut2 data_val.T_ByOut2 data_val.T_Return2 data_val.T_PumpIn data_val.T_ThM1 data_val.T_ThM2];

%% Plot All Results for Troubleshooting
params_plot.fn = 12;
params_plot.ln_sty = ["-" ":" "--" "-."];
params_plot.clr = lines(7);
params_plot.pos = [320,150,725,400];
params_plot.ylim = [18 40];

%figPID_all(data_val,d_act,d_sim,params_plot)

%% Results Figures
params_plot.num_panel = 1;

% Thermal Mass results
if params_plot.num_panel == 2
    params_plot.pos = [320,230,461,320];
    params_plot.ln = 1;
    params_plot.ylim = [18 29];
    params_plot.fn = 10;
elseif params_plot.num_panel == 1
    params_plot.pos = [733,257,434,312];
    params_plot.ln = 2;
    params_plot.fn = 12;
end
figPID_ThM(data_val,d_act,d_sim,params_plot)

% Pipes
if params_plot.num_panel == 2
    params_plot.ylim = [34 40];
    params_plot.pos = [320,230,461,420];
elseif params_plot.num_panel == 1
    params_plot.pos = [733,316,393,253];
    params_plot.ln = 1.2;
end
h=figPID_pipes(data_val,d_act,d_sim,params_plot);
exportgraphics(h,"Treturn.eps",ContentType="vector")

% Mass flow
params_plot.ylim = [-.002 0.03];
if params_plot.num_panel==1
    params_plot.ln = 1.5;
    params_plot.xlim = [1.5e4, 2.5e4];
end
figPID_mdot(data_val,m_sim,params_plot)

%% Building-wise
params_plot.ln = 1.1;
params_plot.pos = [733,316,393,253];
params_plot.pos_leg = [0.627236937537036,0.544303348676959,0.207153822749971,0.294940721715391];
params_plot.ylim = cell(1,2);
params_plot.ylim{1} = [16 29];
params_plot.ylim{2} = [-.002 0.035];
[h1,h2] = figPID_ThMcombined(data_val,d_act,d_sim,m_sim,params_plot);
exportgraphics(h1,"ThM1_combined.eps",ContentType="vector")
exportgraphics(h2,"ThM2_combined.eps",ContentType="vector")

%% Plot profile used for experiment
params_plot.ln = 1;
params_plot.pos = [320,230,461,320];
params_plot.ylim = [0 .1];
params_plot.xlim = [0 data.dhn.Time(end)/(60*60)];
figExp(data.dhn,idx_split, params_plot);
