function [err, y, x] = sim_ThMboth(inpt,d,LS,flag)
%SIM_THMSINGLE_A Optimize and simulate a single loop of the network, 
%changing the hAs and a values 
%   inpt: input to be optimized of the form 
%   [hAs_pipes, hAs_ThM, V_pipes, a], where a and V_pipes are optional
%   d: data to be matched
%   LS: parameters of the lab scale system including volumes of ThM and
%   pipes
%   ThMn: Number of the thermal mass loop being calibrated
%   flag=1: simulate, flag=0 optimize


seg = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','R1'};
states = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','ThM1','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','ThM2','R1'};
%% Model Constants
L = 14;
K = 1;
n = size(d,1);

if length(inpt) == 16
    hAs = inpt;
    a = [interp1(LS.inc, LS.a1, d.V_ThM1) interp1(LS.inc, LS.a2, d.V_ThM2)];
elseif length(inpt) == 18
    hAs = inpt(1:16);
    %a = [inpt(17)*ones(n,1) inpt(18)*ones(n,1)];
else
    hAs = inpt(1:16);
    %a = [inpt(end-1)*ones(n,1) inpt(end)*ones(n,1)];
    LS.V_pipes = inpt(10:end-2);
end

x = zeros(n,2*K+L);
y = zeros(n,13);


x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) ...
    d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ThM1(1) d.T_ByIn2(1) ...
    d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1)...
    d.T_ThM2(1) d.T_PumpIn(1)];

c2 = hAs(1,1:14)./(LS.p*LS.cp*LS.V_pipes);
bldg = [[hAs(4) hAs(15) 1]/(LS.p*LS.cp*LS.V1);[hAs(10) hAs(16) 1]/(LS.p*LS.cp*LS.V2)];
e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'; bldg(1,2)];
e12 = [c2(1,[8 9])';0;c2(1,[11 12 13])'; bldg(2,2)];
e21 = [zeros(6,1); -bldg(1,3)];
e22 = [zeros(6,1); -bldg(2,3)];
E = [c2(1) 0 0; e11 e21 zeros(7,1); e12 zeros(7,1) e22; c2(14) 0 0];

%% Simulate
d.M_Supply1 = (d.M_Heater-d.M_Supply2);
Lp = d.M_Supply1./d.M_Heater;
d.M_ThM1 = (d.M_Supply1-d.M_By1);
d.M_ThM2 = (d.M_Supply2-d.M_By2);
%a = [d.M_ThM1./d.M_Supply1 d.M_ThM2./d.M_Supply2];
%a(a<0) = 0;
%m = [d.M_Heater, d.M_Supply1 repmat(d.M_ThM1, [1,3]) d.M_By1 d.M_Supply1 d.M_Supply2 repmat(d.M_ThM2, [1,3]) d.M_By2 d.M_Supply2 d.M_Heater];
m = [d.M_Heater, d.M_Supply1 repmat(a(:,1).*d.M_Supply1, [1,3]) (1-a(:,1)).*d.M_Supply1 d.M_Supply1 d.M_Supply2 repmat(a(:,2).*d.M_Supply2, [1,3]) (1-a(:,2)).*d.M_Supply2 d.M_Supply2 d.M_Heater];
m(m<0) = 0;
c1 = m./(LS.p*LS.V_pipes);
c3 = -(c1+c2);

T = 1;
C = zeros(13,16);
C(1,1) = 1; C(2,2) = 1; C(3,3) = 1; C(4,4) = 1;
C(6,9) = 1; C(7,10) = 1; C(8,11) = 1;
C(11,16) = 1;
C(12,8) = 1;
C(13,15) = 1;

for i = 1:n
    A = makeAboth(c1(i,:),c2,c3(i,:),bldg,a(i,:),Lp(i));
    B = [c1(i,1);zeros(K+L,1)];
    Btot = [B E];
    C(5,5) = a(i,1); C(5,6) = 1-a(i,1);
    C(9,12) = a(i,2); C(9,13) = 1-a(i,2);
    C(10,7) = Lp(i,1); C(10,14) = 1-Lp(i,1);
    u = [d.T_HeaterOut(i); d.T_Ambient(i);d.Q1(i);d.Q2(i)];
    Afrt = inv(eye(2*K+L)-A*T/2);
    Ad = Afrt*(eye(2*K+L)+A*T/2);
    Bd = Afrt*Btot*sqrt(T);
    Cd = sqrt(T)*C*Afrt;
    x(i+1,:) = Ad*x(i,:)'+Bd*u;
    y(i,:) = Cd*x(i,:)'+(zeros(13,4)+C*Afrt*Btot*T/2)*u;
end

%% Error Calculation

y_act = [d.T_Supply2 d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2 d.T_PumpIn d.T_ThM1 d.T_ThM2];

e = sqrt(sum((y-y_act).^2)./n);
w = [1 1 1 1 1 1 1 1 1 1 1 1 1];
err = sum(w.*e);

%% Plotting

if flag
    figure('Name', 'Compare Data')
    tiledlayout(1,2,'TileSpacing','compact')
    
    nexttile
    hold on
    plot(d.Time, y(:,1:7), 'Linewidth',2)
    plot(d.Time, y(:,8:11), '--', 'Linewidth',2)
    plot(d.Time, y(:,12:13),':','linewidth',2)
    plot(d.Time, d.T_HeaterOut,'--k' ,'Linewidth',2);
    plot(d.Time, d.T_Ambient, 'k','linewidth',2)
    ylim([18 40])
    title('Simulation')
    box on; grid on; hold off

    nexttile
    hold on
    plot(d.Time, y_act(:,1:7), 'Linewidth',2)
    plot(d.Time, y_act(:,8:11), '--', 'Linewidth',2)
    plot(d.Time, y_act(:,12:13),':','linewidth',2)
    plot(d.Time, d.T_HeaterOut,'--k' ,'Linewidth',2);
    plot(d.Time, d.T_Ambient, 'k','linewidth',2)
    ylim([18 40])
    box on; grid on; hold off
    legend('F1','ByIn1','HxIn1','HxOut1','ByOut1','ByIn2','HxIn2','HxOut2','ByOut2','LoopsOut','R1','Heater','Ambient','ThM1','ThM2')
    title('Actual')
    box on; grid on; hold off
end

end