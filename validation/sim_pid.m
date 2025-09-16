function [err, y, x, alpha, mdot, sol] = sim_pid(inpt,d,LS,flag,L1)
%SIM_PID Calibrate and simulate DHN model with PID mass flow rate control
%
%   [err, y, x, alpha, mdot, sol] = sim_pid(inpt,d,LS,flag,L1)
%   
%   DESCRIPTION: Performs a discete time simulation of the temperature
%   dynamics in the network and thermal masses, dependend on the network
%   flow rate and supply temperature. Has two modes, the calibration mode,
%   where the mass flow rate split between branches is taken from data, 
%   used to calibrate the model, and the simulation mode where the mass 
%   flow rate split between branches is constant. 
%
%   INPUTS: 
%       inpt    - Model parameters in the form [gainP1 gainP2 hAs]
%       d       - Data to be matched
%       LS      - parameters of the lab scale system including volumes of 
%                 the ThMs and pipes
%       flag    - simulate=1, optimize=0
%       L1      - masss flow split between branches, only for simulate
%
%   OUTPUTS:
%       err     - Total rmse temperature modeling error.
%       y       - Matrix of temperatures over time.
%       x       - Matrix of states over time.
%       alpha   - Matrix of valve positions over time.
%       mdot    - Matrix of mass flow over time.
%       sol     - Structure of calculated solution metrics.
%
%   DEPENDENCIES: makeAboth

%% Problem Setup

n_up = 14;          % # of users segments
n_s = 1;            % # of split nodes
n_step = size(d,1); % # of time steps
T = 1;              % Period

% Parse Inputs
gainP = inpt(1:2);
hAs = inpt(3:end); 

% Preallocate variable storage
x = zeros(n_step,2*n_s+n_up);
y = zeros(n_step,13);
alpha = zeros(n_step,2);
mdot = zeros(n_step,14);

%% Model parameters

% Initial conditions
x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) ...
    d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ThM1(1) d.T_ByIn2(1) ...
    d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1)...
    d.T_ThM2(1) d.T_PumpIn(1)];

% Coefficients not dependent on mass flow
c2 = hAs(1,1:14)./(LS.p*LS.cp*LS.V_pipes);
bldg = [[hAs(4) hAs(15) 1]/(LS.p*LS.cp*LS.V1);[hAs(10) hAs(16) 1]/(LS.p*LS.cp*LS.V2)];


%% Generate Constant Matrices

% Uncontrollable input matrix
e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'; bldg(1,2)];
e12 = [c2(1,[8 9])';0;c2(1,[11 12 13])'; bldg(2,2)];
e21 = [zeros(6,1); -bldg(1,3)];
e22 = [zeros(6,1); -bldg(2,3)];
E = [c2(1) 0 0; e11 e21 zeros(7,1); e12 zeros(7,1) e22; c2(14) 0 0];

% Output matrix
C = zeros(13,16);
C(1,1) = 1; C(2,2) = 1; C(3,3) = 1; C(4,4) = 1;
C(6,9) = 1; C(7,10) = 1; C(8,11) = 1;
C(11,16) = 1;
C(12,8) = 1;
C(13,15) = 1;

% Calculate Mass Flow Rate
dsim.M_Heater = d.M_Heater;
if flag % Simulate
    % Constant branch split
    dsim.M_Supply1 = L1*dsim.M_Heater;
    dsim.M_Supply2 = (1-L1)*dsim.M_Heater;
else % Calibrate
    % Actual split data
    dsim.M_Supply2 = d.M_Supply2;
    dsim.M_Supply1 = (dsim.M_Heater-dsim.M_Supply2);
end

% Calculate split
Lp = dsim.M_Supply1./dsim.M_Heater;

%% Simulate discrete time model

for idx_step = 1:n_step
    % PID control of mdot to users
    if idx_step>1
        alpha(idx_step,1) = gainP(1)*(d.T_ThM1(idx_step-1)-y(idx_step-1,12));
        alpha(idx_step,2) = gainP(2)*(d.T_ThM2(idx_step-1)-y(idx_step-1,13));
        alpha(idx_step,alpha(idx_step,:)<0) = 0;
        alpha(idx_step,alpha(idx_step,:)>1) = 1;
    end

    % Vector of mass flow
    mdot(idx_step,:) = [dsim.M_Heater(idx_step), dsim.M_Supply1(idx_step), ...
        repmat(alpha(idx_step,1).*dsim.M_Supply1(idx_step), [1,3]), ...
        (1-alpha(idx_step,1)).*dsim.M_Supply1(idx_step), dsim.M_Supply1(idx_step),...
        dsim.M_Supply2(idx_step), repmat(alpha(idx_step,2).*dsim.M_Supply2(idx_step), [1,3]), ...
        (1-alpha(idx_step,2)).*dsim.M_Supply2(idx_step), dsim.M_Supply2(idx_step), ...
        dsim.M_Heater(idx_step)];
    mdot(idx_step,(mdot<0)) = 0;

    % Mass flow dependent coefficients
    c1 = mdot(idx_step,:)./(LS.p*LS.V_pipes);
    c3 = -(c1+c2);

    % Time varying matrices
    A = makeAboth(c1,c2,c3,bldg,alpha(idx_step,:),Lp(idx_step));
    B = [c1(1);zeros(n_s+n_up,1)];
    Btot = [B E];
    C(5,5) = alpha(idx_step,1); C(5,6) = 1-alpha(idx_step,1);
    C(9,12) = alpha(idx_step,2); C(9,13) = 1-alpha(idx_step,2);
    C(10,7) = Lp(idx_step,1); C(10,14) = 1-Lp(idx_step,1);
    u = [d.T_HeaterOut(idx_step); d.T_Ambient(idx_step);d.Q1(idx_step);d.Q2(idx_step)];
    
    % Bilinear transform
    Afrt = inv(eye(2*n_s+n_up)-A*T/2);
    Ad = Afrt*(eye(2*n_s+n_up)+A*T/2);
    Bd = Afrt*Btot*sqrt(T);
    Cd = sqrt(T)*C*Afrt;

    % State calculation
    x(idx_step+1,:) = Ad*x(idx_step,:)'+Bd*u; 
    y(idx_step,:) = Cd*x(idx_step,:)'+(zeros(13,4)+C*Afrt*Btot*T/2)*u;
end

%% Error Calculation

% Data
y_act = [d.T_Supply2 d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2 d.T_PumpIn d.T_ThM1 d.T_ThM2];

% Error Calculation
e = rmse(y,y_act);
w = [1 1 1 1 1 1 1 1 1 1 1 1 1];
err = sum(w.*e);
sol.e_y = e;

% Energy and enthalpy
sol.E_sim = d.M_Heater.*LS.cp.*(d.T_HeaterOut-y(:,10));
sol.E_act = d.M_Heater.*LS.cp.*(d.T_HeaterOut-y_act(:,10));
sol.e_enthalpy = rmse(sol.E_sim, sol.E_act);
sol.pct_enthalpy = mean((sol.E_sim-sol.E_act)./sol.E_act);

% Mass flow errors
mdot_B1 = (d.M_Heater-d.M_Supply2)-d.M_By1;
mdot_B2 = d.M_Supply2-d.M_By2;
sol.e_m1 = rmse(mdot(:,3),mdot_B1)/(max(mdot_B1)-min(mdot_B1));
sol.e_m2 = rmse(mdot(:,9),mdot_B2)/(max(mdot_B2)-min(mdot_B2));

% Key temperature errors
sol.e_thm1 = rmse(x(1:end-1,8),d.T_ThM1)/(max(d.T_ThM1)-min(d.T_ThM1));
sol.e_thm2 = rmse(x(1:end-1,15),d.T_ThM2)/(max(d.T_ThM2)-min(d.T_ThM2));
sol.e_11 = e(11)/(max(y_act(:,11))-min(y_act(:,11)));
sol.e_5 = e(5)/(max(y_act(:,5))-min(y_act(:,5)));
sol.e_9 = e(9)/(max(y_act(:,9))-min(y_act(:,9)));

end