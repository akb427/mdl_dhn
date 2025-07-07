clc, clear, close all

LS = struct(load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\ThM_params.mat"));
load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\Data Processing 3\pipe_params.mat")

seg = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','R1'};
%% Calibration Data

d = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\11_15_22_CalibrateThM\CalibrateThM.csv');
d.V_ThM1 = 100*(d.Time>=3680);
d.V_ThM2 = 100*(d.Time<3680);
%% Process Table Data

d_list{1} = d(d.Time<3545 & d.Time>440,:);
d_list{1}.V_ThM1 = zeros(height(d_list{1}),1);
d_list{1}.V_ThM2 = 100*ones(height(d_list{1}),1);
d_list{2} = d(d.Time<5865 & d.Time>3877,:);
d_list{2}.V_ThM2 = zeros(height(d_list{2}),1);
d_list{2}.V_ThM1 = 100*ones(height(d_list{2}),1);
d_list{1}.Time = d_list{1}.Time-440;
d_list{2}.Time = d_list{2}.Time-3877;
L2 = [1 0];
for i = 1:2
    d_list{i} = filtdata(d_list{i});
end

LS.V_pipes = pipes.V;
LS.a1 = v.a1;
LS.a2 = v.a2;
LS.inc = v.inc;

clear v

%% Minimzation
%simresults_opt(pipes.hAs,d,LS)
% for i =1:2
%     f = @(hAs)simresults_opt(hAs,d_list{i},LS);
%     hAs_new{i} = fmincon(f,pipes.hAs,-1*eye(14),zeros(14,1));
% end
% 
% xf = simresults(hAs_new{1},d_list{1},LS);
%% Thermal Mass Minimization
opts = optimoptions('fmincon','MaxFunctionEvaluations',6000);
for i =1:2
    f = @(hAs)simresults_optThM(hAs,d_list{i},LS,L2(i));
    hAs_new2{i} = fmincon(f,[pipes.hAs LS.hAs_ThM1 LS.hAs_ThM2],-1*eye(16),zeros(16,1),[],[],[],[],[],opts);
end

%%
xf = simresults(hAs_new2{2},d_list{2},LS,1);
xf = simresults(hAs_new2{1},d_list{1},LS,1);
hAs_fin = [(hAs_new2{1}(1)+hAs_new2{2}(1))/2 hAs_new2{2}(2:7) hAs_new2{1}(8:13) (hAs_new2{1}(14)+hAs_new2{2}(14))/2 hAs_new2{2}(15) hAs_new2{1}(16)];
save('hAs_min','hAs_fin')
