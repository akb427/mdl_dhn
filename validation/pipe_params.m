function [pipes, v, vsplit] = pipe_params(flag)
% Creates initial guesses for the hAs values based on the cooling of the
% network under no flow conditions using data from "11_15_22_CalibrateThM".
% Also creates two sets of relations for the valve position 'inc' and % 
% mass flow rate 'a' from the data "02_20_23_Pressure", 
% "02_20_23_PressureBr1", and "02_20_23_PressureBr2". One for when the 
% network is running both branches 'v' and one for when only an individual 
% branch is recieving flow 'vsplit'. Saves this data in "pipe_params"

pipes.seg = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','R1'};
%% Pipe Data                                                                % Row 1: PEX, Row 2: Vinyl Tubing, Row 3: Copper Pipe
L = [443 98 11.5 0 12.128 14.25 91 99 12.25 0 11.875 14.625 90 400;...
    0 0 35 0 38 0 0 0 34 0 34 0 0 0;...
    0 0 0 20 0 0 0 0 0 20 0 0 0 0]/39.37;
OD = [0.625;0.25; 0.2]/39.37;
ID = [0.485;0.170; 0.17]/39.37;
V = pi/4*(ID.^2).*L;
As = pi*OD.*L;

pipes.L = sum(L);
pipes.V = sum(V);
pipes.As = sum(As);

%% Volume upper and lower limits
deltaL = [12 6 3 0 3 3 6 6 3 0 3 3 6 12; 0 0 3 0 3 0 0  0 3 0 3 0 0 0; 0 0 0 3 0 0 0 0 0 3 0 0 0 0];
L_upr = L+(deltaL/39.37);
L_lwr = L-(deltaL/39.37);
V_upr = pi/4*(ID.^2).*L_upr;
V_lwr = pi/4*(ID.^2).*L_lwr;
pipes.V_upr = sum(V_upr);
pipes.V_lwr = sum(V_lwr);

%% Pipe Calibration Data
LS = struct(load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\ThM_params.mat"));

d = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\11_15_22_CalibrateThM\CalibrateThM.csv');
t = d.Time;
d = convertUnits(d, LS.p);

dP = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\02_20_23_Pressure1\Processed.csv');
dP = convertUnits(dP,LS.p);

dP1 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\02_20_23_PressureBr1\Processed.csv');
dP1 = convertUnits(dP1, LS.p);

dP2 = readtable('C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\02_20_23_PressureBr2\Processed.csv');
dP2 = convertUnits(dP2,LS.p);

%% Heat Transfer Coefficients
idx = t>=6405;
fitfun = fittype(@(a,b,c,x) a*exp(-b*x)+c);

% Single Temperature
temps = {'PumpIn','HeaterOut','ByIn1','HxIn1','HxOut1','ByOut1','Supply2','ByIn2','HxIn2','HxOut2','ByOut2','Return2'};
coeff1 = cell(1,12);
gof1 = cell(1,12);
for i = 1:numel(temps)
    str = strcat('T_',temps{i});
    [coeff1{i}, gof1{i}] = fit(d.Time(idx), d.(str)(idx), fitfun, 'StartPoint',[100,0,30]);
end

% Average Temp between start and end
temps2 = {'HeaterOut','Supply2';'Supply2','ByIn1';'ByIn1','HxIn1';'HxIn1','HxOut1';'HxOut1','ByOut1';'ByIn1','ByOut1';'ByOut1','Return2';...
    'Supply2','ByIn2';'ByIn2','HxIn2';'HxIn2','HxOut2';'HxOut2','ByOut2';'ByIn2','ByOut2';'ByOut2','Return2';'Return2','PumpIn'};
coeff2 = cell(1,14);
gof2 = cell(1,14);
if flag

end
for i = 1:size(temps2,1)
    str1 = strcat('T_',temps2{i,1});
    str2 = strcat('T_',temps2{i,2});
    
    [coeff2{i}, gof2{i}] = fit(d.Time(idx), (d.(str2)(idx)+d.(str1)(idx))/2, fitfun, 'StartPoint',[100,0,30]);
end
% Convert to hAs from hAs/pcpV
b2 = cellfun(@(x)x.b,coeff2);
pipes.hAs = b2*LS.p*LS.cp.*pipes.V;

%Fix copper hAs values
pipes.hAs(1,[4 10]) = [LS.hAs_cp1, LS.hAs_cp2];
pipes.h = pipes.hAs.*pipes.As;

%% Plot Curves for hAs Calculations
if flag
    figure('Name','Single T')
    hold on
    for i = 1:numel(temps)
        str = strcat('T_',temps{i});
        plot(d.Time(idx), d.(str)(idx))
    end
    legend(temps)
    hold off
    figure('Name','Average T')
    hold on
    for i = 1:size(temps2,1)
        str1 = strcat('T_',temps2{i,1});
        str2 = strcat('T_',temps2{i,2});
        plot(d.Time(idx), (d.(str2)(idx)+d.(str1)(idx))/2)
    end
    legend(pipes.seg)
    hold off
end

%% Pressure Loss coefficients
inc = 0:5:100;
n = numel(inc);
dP.M_Supply1 = dP.M_Heater-dP.M_Supply2;
dP.M_ThM1 = dP.M_Supply1-dP.M_By1;
dP.M_ThM2 = dP.M_Supply2-dP.M_By2;
a1 = dP.M_ThM1./dP.M_Supply1;
a2 = dP.M_ThM2./dP.M_Supply2;
l1 = dP.M_Supply1./dP.M_Heater;
l2 = dP.M_Supply2./dP.M_Heater;

if flag
    figure('Name','Mdot')
    hold on
    plot(dP.Time,dP.M_Heater)
    plot(dP.Time,dP.M_Supply1)
    plot(dP.Time,dP.M_Supply2)
    plot(dP.Time,dP.M_ThM1)
    plot(dP.Time,dP.M_By1)
    plot(dP.Time,dP.M_ThM2)
    plot(dP.Time,dP.M_By2)
    legend('Heater','L1','L2','ThM1','By1','ThM2','By2','AutoUpdate','off')
    yyaxis right
    plot(dP.Time,dP.V_ThM1)
    plot(dP.Time,dP.V_ThM2)
    hold off
    
    figure('Name','Alpha')
    hold on
    plot(dP.Time, a1)
    plot(dP.Time, a2)
    legend('a1','a2')
    yyaxis right
    plot(dP.Time,dP.V_ThM1)
    plot(dP.Time,dP.V_ThM2)
    hold off
end
a1_grid = zeros(n,n);
a2_grid = zeros(n,n);
for i = 1:n         % rows are constant V1
    for j = 1:n     % columns are constant V2
        idx = dP.V_ThM1 == inc(i) & dP.V_ThM2 == inc(j);
        rm = find(idx,5);
        idx(rm) = 0;
        a1_grid(i,j) = mean(a1(idx));
        a2_grid(i,j) = mean(a2(idx));
        l1_grid(i,j) = mean(l1(idx));
        l2_grid(i,j) = mean(l2(idx));
    end
end

l2_mean = mean(l2_grid,'all');    
v.a1 = mean(a1_grid,2)';
v.a2 = mean(a2_grid,1);
v.inc = inc;

if flag
    figure
    surf(inc,inc,a1_grid)
    xlabel('V2')
    ylabel('V1')
    zlabel('alpha1')
    figure
    surf(inc,inc,a2_grid)
    xlabel('V2')
    ylabel('V1')
    zlabel('alpha2')
    surf(inc,inc,l1_grid)
    xlabel('V2')
    ylabel('V1')
    zlabel('L1')
    surf(inc,inc,l2_grid)
    xlabel('V2')
    ylabel('V1')
    zlabel('L2')
    
    figure('Name','alpha curve')
    hold on
    plot(inc,v.a1)
    plot(inc,v.a2)
    legend('a1','a2')
    xlabel('Valve Position')
    ylabel('alpha')
    box on; grid on; hold off
end

%% Pressure Branch 1

dP1.M_Supply1 = dP1.M_Heater;
dP1.M_ThM1 = dP1.M_Supply1-dP1.M_By1;
a1 = dP1.M_ThM1./dP1.M_Supply1;

a1_br = zeros(n,1);
for i = 1:n         % rows are constant V1
    idx = dP1.V_ThM1 == inc(i);
    rm = find(idx,5);
    idx(rm) = 0;
    a1_br(i,1) = mean(a1(idx));
end

%% Pressure Branch 2

dP2.M_ThM2 = dP2.M_Supply2-dP2.M_By2;
a2 = dP2.M_ThM2./dP2.M_Supply2;

a2_br = zeros(n,1);
for i = 1:n         % rows are constant V1
    idx = dP2.V_ThM2 == inc(i);
    rm = find(idx,5);
    idx(rm) = 0;
    a2_br(i,1) = mean(a2(idx));
end
%% Plot branches
if flag
    figure('Name','Branches')
    hold on
    plot(inc, a1_br)
    plot(inc, a2_br)
    legend('a1','a2')
    xlabel('Valve Position')
    ylabel('alpha')
    box on; grid on; hold off
end

vsplit.inc = inc;
vsplit.a1 = a1_br;
vsplit.a2 = a2_br;
%% Save Data
%save('pipe_params','pipes','v','vsplit')
end