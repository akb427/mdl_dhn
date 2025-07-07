clc, clear, close all

LS = struct(load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\ThM_params.mat"));
[pipes, ~, vsplit] = pipe_params(0);
seg = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','R1'};
states = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','ThM1','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','ThM2','R1'};

%% Load Calibration Data

d = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\11_15_22_CalibrateThM\CalibrateThM.csv');
d = convertUnits(d,LS.p);

%% Process Table Data

d.V_ThM1 = 100*(d.Time>=3680);
d.V_ThM2 = 100*(d.Time<3680);

d_list{1} = d(d.Time<5865 & d.Time>3877,:);
d_list{1}.Time = d_list{1}.Time-3877;
d_list{1}.V_ThM1 = 100*ones(height(d_list{1}),1);
d_list{1}.V_ThM2 = zeros(height(d_list{1}),1);

d_list{2} = d(d.Time<3545 & d.Time>440,:);
d_list{2}.Time = d_list{2}.Time-440;
d_list{2}.V_ThM1 = zeros(height(d_list{2}),1);
d_list{2}.V_ThM2 = 100*ones(height(d_list{2}),1);
%% Plotting
figure('Name','Time Periods')
hold on
plot(d.Time, d.T_HxIn1, d.Time, d.T_HxOut1, d.Time, d.T_ThM1, 'Linewidth',2)
plot(d.Time, d.T_HxIn2, d.Time, d.T_HxOut2, d.Time, d.T_ThM2, 'Linewidth',2)
legend('HxIn1', 'HxOut1','ThM1','HxIn2', 'HxOut2','ThM2')
xline(3877);
xline(5865);
xline(3545);
xline(440);
box on; grid on; hold on;
%%
% d_f = cell(2,1);
% for i = 1:2
%     d_f{i} = filtdata(d_list{i});
%     d_f{i} = d_f{i}(20:end-20,:);
% end

LS.V_pipes = pipes.V;
a1 = interp1(vsplit.inc, vsplit.a1, 100);
a2 = interp1(vsplit.inc, vsplit.a2, 100);
LS.inc = vsplit.inc;
LS.a1 = vsplit.a1;
LS.a2 = vsplit.a2;


%% Thermal Mass Minimization-with alpha
opts = optimoptions('fmincon','MaxFunctionEvaluations',60000);

f1 = @(x)sim_ThMsingle(x,d_list{1},LS,1,0);
f2 = @(x)sim_ThMsingle(x,d_list{2},LS,2,0);
[opt1, emin1(1)] = fmincon(f1,[pipes.hAs(1,[1:7 14]) LS.hAs_ThM1 a1],[],[],[],[],[zeros(10,1)],[1000*ones(9,1);1],[],opts);
[opt2, emin2(1)] = fmincon(f2,[pipes.hAs(1,[1 8:14]) LS.hAs_ThM2 a2],[],[],[],[],[zeros(10,1)],[1000*ones(9,1);1],[],opts);

sim_ThMsingle(opt1,d_list{1},LS,1,1);
sim_ThMsingle(opt2,d_list{2},LS,2,1);

hAs_fin = [(opt1(1)+opt2(1))/2 opt1(2:7) opt2(2:7) (opt1(8)+opt2(8))/2 opt1(9) opt2(9)];
save('hAs_cal','hAs_fin');


%% Thermal Mass Minimization-hAs and Volume minimization
% lb = [zeros(9,1); pipes.V_lwr'];
% ub = [100*ones(9,1); pipes.V_upr'];
% 
% f1 = @(x)opt_ThMsingle_V(x,d_list{1},LS,1,idx1);
% [hAs1both, emin1(3)] = fmincon(f1,[hAs1sng LS.V_pipes],-1*eye(23),zeros(23,1),[],[],lb,ub,[],opts);
% 
% f2 = @(x)opt_ThMsingle_V(x,d_list{2},LS,2,idx2);
% [hAs2both, emin2(3)] = fmincon(f2,[hAs2sng LS.V_pipes],-1*eye(23),zeros(23,1),[],[],lb,ub,[],opts);
% 
% LSnew = LS;
% LSnew.V_pipes = hAs1both(10:end);
% x1both = sim_ThMsingle(hAs1both(1:9),d_list{1},LSnew,1,idx1);
% 
% LSnew.V_pipes = hAs2both(10:end);
% x2both = sim_ThMsingle(hAs2both(1:9),d_list{2},LSnew,2,idx2);

%%

%hAs_fin = [(hAs_new1(1)+hAs_new2(1))/2 hAs_new1(2:7) hAs_new2(2:7) (hAs_new1(8)+hAs_new2(8))/2 hAs_new1(9) hAs_new2(9)];
%xf = simresults(hAs_fin,d_list{1},LS,1);
%save('hAs_min','hAs_fin')
