function [pipes, v, vsplit] = get_pipe_params(pth,flag)
%GET_PIPE_PARAMS  Generate pipe parameters.
%
%   [pipes, v, vsplit] = GET_PIPE_PARAMS(flag)
%
%   DESCRIPTION:
%   Creates initial guesses for the hAs values based on the cooling of the
%   network under no flow conditions using data from "CalibrateThM". Also
%   creates two sets of relations for the valve position 'inc' and mass
%   flow rate 'a' from the data "Pressure", "PressureBr1", and
%   "PressureBr2". One for when the network is running both branches 'v'
%   and one for when only an individual branch is recieving flow 'vsplit'.
%
%   INPUTS:
%       pth     - String of path to data folder.
%       flag    - Binary flag to indicate plotting.
%
%   OUTPUTS:
%       pipes   - Stucture of physical pipe characteristics.
%       v       - Structure of flow ratios when both branches are connected
%       vsplit  - Structure of flow ratios when one branche is connected
%
%   DEPENDENCIES: convert_units

%% Pipe Geometery

% segment names
pipes.seg = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','R1'};

% Measuments from lab scale system by material [PEX; Vinyl; Copper]
L = [443 98 11.5 0 12.128 14.25 91 99 12.25 0 11.875 14.625 90 400;...
    0 0 35 0 38 0 0 0 34 0 34 0 0 0;...
    0 0 0 20 0 0 0 0 0 20 0 0 0 0]/39.37;
OD = [0.625;0.25; 0.2]/39.37;
ID = [0.485;0.170; 0.17]/39.37;

% Additional parameters
V = pi/4*(ID.^2).*L;
As = pi*OD.*L;

% Totals for each segment (combined materials)
pipes.L = sum(L);
pipes.V = sum(V);
pipes.As = sum(As);

%% Volume upper and lower limits

% Bound estimates of volume, considered for calibration
deltaL = [12 6 3 0 3 3 6 6 3 0 3 3 6 12; 0 0 3 0 3 0 0  0 3 0 3 0 0 0; 0 0 0 3 0 0 0 0 0 3 0 0 0 0];
L_upr = L+(deltaL/39.37);
L_lwr = L-(deltaL/39.37);
V_upr = pi/4*(ID.^2).*L_upr;
V_lwr = pi/4*(ID.^2).*L_lwr;
pipes.V_upr = sum(V_upr);
pipes.V_lwr = sum(V_lwr);

%% Pipe Calibration Data

%  Load data
LS = struct(load(pth+"ThM_params.mat"));
d = readtable(pth+"CalibrateThM.csv");
dP = readtable(pth+"Pressure1_Processed.csv");
dP1 = readtable(pth+"PressureBr1_Processed.csv");
dP2 = readtable(pth+"PressureBr2_Processed.csv");

% Convert units
t = d.Time;
d = convertUnits(d, LS.p);
dP = convertUnits(dP,LS.p);
dP1 = convertUnits(dP1, LS.p);
dP2 = convertUnits(dP2,LS.p);

%% Estimate Heat Transfer Coefficients From Cooling Rate
idx_exp = t>=6405;
fitfun = fittype(@(a,b,c,x) a*exp(-b*x)+c);

% Single Temperature
temps = {'PumpIn','HeaterOut','ByIn1','HxIn1','HxOut1','ByOut1','Supply2','ByIn2','HxIn2','HxOut2','ByOut2','Return2'};
coeff1 = cell(1,12);
gof1 = cell(1,12);
% Get fit curve for each temperature
for idx_temp = 1:numel(temps)
    str = strcat('T_',temps{idx_temp});
    [coeff1{idx_temp}, gof1{idx_temp}] = fit(d.Time(idx_exp), d.(str)(idx_exp), fitfun, 'StartPoint',[100,0,30]);
end

% Average temp between start and end
temps2 = {'HeaterOut','Supply2';'Supply2','ByIn1';'ByIn1','HxIn1';'HxIn1','HxOut1';'HxOut1','ByOut1';'ByIn1','ByOut1';'ByOut1','Return2';...
    'Supply2','ByIn2';'ByIn2','HxIn2';'HxIn2','HxOut2';'HxOut2','ByOut2';'ByIn2','ByOut2';'ByOut2','Return2';'Return2','PumpIn'};
coeff2 = cell(1,14);
gof2 = cell(1,14);

% Get fit curve for each temperature
for idx_temp = 1:size(temps2,1)
    str1 = strcat('T_',temps2{idx_temp,1});
    str2 = strcat('T_',temps2{idx_temp,2});
    [coeff2{idx_temp}, gof2{idx_temp}] = fit(d.Time(idx_exp), (d.(str2)(idx_exp)+d.(str1)(idx_exp))/2, fitfun, 'StartPoint',[100,0,30]);
end

% Convert to hAs from hAs/pcpV
b2 = cellfun(@(x)x.b,coeff2);
pipes.hAs = b2*LS.p*LS.cp.*pipes.V;

% Fix copper hAs values
pipes.hAs(1,[4 10]) = [LS.hAs_cp1, LS.hAs_cp2];
pipes.h = pipes.hAs.*pipes.As;

%% Pressure Loss coefficients

% Valve position increments
inc = 0:5:100;
n = numel(inc);
% Calculate unmeasured flow rates
dP.M_Supply1 = dP.M_Heater-dP.M_Supply2;
dP.M_ThM1 = dP.M_Supply1-dP.M_By1;
dP.M_ThM2 = dP.M_Supply2-dP.M_By2;
% Calculate flow rate ratios
dP.a1 = dP.M_ThM1./dP.M_Supply1;
dP.a2 = dP.M_ThM2./dP.M_Supply2;
dP.l1 = dP.M_Supply1./dP.M_Heater;
dP.l2 = dP.M_Supply2./dP.M_Heater;
% Preallocate grid
dP_a1_grid = zeros(n,n);
dP_a2_grid = zeros(n,n);
dP_l1_grid = zeros(n,n);
dP_l2_grid = zeros(n,n);

% Extract relavent data points
for idx_incV1 = 1:n         % rows are constant V1
    for idx_incV2 = 1:n     % columns are constant V2
        % Indicies in data with current valve positions
        idx_exp = dP.V_ThM1 == inc(idx_incV1) & dP.V_ThM2 == inc(idx_incV2);
        % Remove transience
        rm = find(idx_exp,5);
        idx_exp(rm) = 0;
        % Average values
        dP_a1_grid(idx_incV1,idx_incV2) = mean(dP.a1(idx_exp));
        dP_a2_grid(idx_incV1,idx_incV2) = mean(dP.a2(idx_exp));
        dP_l1_grid(idx_incV1,idx_incV2) = mean(dP.l1(idx_exp));
        dP_l2_grid(idx_incV1,idx_incV2) = mean(dP.l2(idx_exp));
    end
end

% Find valve ratios irregardless of other's behavior
v.a1 = mean(dP_a1_grid,2)';
v.a2 = mean(dP_a2_grid,1);
v.inc = inc;

%% Pressure ratios for only branch 1

% Calculate unmeasured flow rates
dP1.M_Supply1 = dP1.M_Heater;
dP1.M_ThM1 = dP1.M_Supply1-dP1.M_By1;
dP1.a1 = dP1.M_ThM1./dP1.M_Supply1;
% Preallocate storage
a1_br = zeros(n,1);

% Extract relavent data points
for idx_incV1 = 1:n         % rows are constant V1
    % Indicies in data with current valve positions
    idx_exp = dP1.V_ThM1 == inc(idx_incV1);
    % Remove transience
    rm = find(idx_exp,5);
    idx_exp(rm) = 0;
    % Average values
    a1_br(idx_incV1,1) = mean(dP1.a1(idx_exp));
end

%% Pressure Branch 2

% Calculate unmeasured flow rates
dP2.M_ThM2 = dP2.M_Supply2-dP2.M_By2;
dP2.a2 = dP2.M_ThM2./dP2.M_Supply2;
% Preallocate storage
a2_br = zeros(n,1);

% Extract relavent data points
for idx_incV2 = 1:n         % rows are constant V1
    % Indicies in data with current valve positions
    idx_exp = dP2.V_ThM2 == inc(idx_incV2);
    % Remove transience
    rm = find(idx_exp,5);
    idx_exp(rm) = 0;
    % Average values
    a2_br(idx_incV2,1) = mean(dP2.a2(idx_exp));
end

%% Store values in structure
vsplit.inc = inc;
vsplit.a1 = a1_br;
vsplit.a2 = a2_br;

%% Plot Curves for hAs Calculations
if flag
    figure('Name','Single T')
    hold on
    for idx_temp = 1:numel(temps)
        str = strcat('T_',temps{idx_temp});
        plot(d.Time(idx_exp), d.(str)(idx_exp))
    end
    legend(temps)
    hold off
    figure('Name','Average T')
    hold on
    for idx_temp = 1:size(temps2,1)
        str1 = strcat('T_',temps2{idx_temp,1});
        str2 = strcat('T_',temps2{idx_temp,2});
        plot(d.Time(idx_exp), (d.(str2)(idx_exp)+d.(str1)(idx_exp))/2)
    end
    legend(pipes.seg)
    hold off
end

%% Plot Pressure Loss Coefficients

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
end

%% Plot Split Ratios

% Plot true values
if flag
    figure('Name','Alpha')
    hold on
    plot(dP.Time, dP.a1)
    plot(dP.Time, dP.a2)
    legend('a1','a2')
    yyaxis right
    plot(dP.Time,dP.V_ThM1)
    plot(dP.Time,dP.V_ThM2)
    hold off
end

% Plot non-averaged data
if flag
    figure
    surf(inc,inc,dP_a1_grid)
    xlabel('V2')
    ylabel('V1')
    zlabel('alpha1')
    figure
    surf(inc,inc,dP_a2_grid)
    xlabel('V2')
    ylabel('V1')
    zlabel('alpha2')
    surf(inc,inc,dP_l1_grid)
    xlabel('V2')
    ylabel('V1')
    zlabel('L1')
    surf(inc,inc,dP_l2_grid)
    xlabel('V2')
    ylabel('V1')
    zlabel('L2')
end

% Plot averaged values for both branches connnected
if flag
    figure('Name','alpha curve')
    hold on
    plot(inc,v.a1)
    plot(inc,v.a2)
    legend('a1','a2')
    xlabel('Valve Position')
    ylabel('alpha')
    box on; grid on; hold off
end

%% Plot Branches Flow Split
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

end