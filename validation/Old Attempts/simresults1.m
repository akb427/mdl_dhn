function x = simresults(hAs_pipes,d,d_p1,d_p2,LS)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Model Constants
L2 = mean(d.M_Supply2./d.M_Heater,'all');
n = size(d,1);

L = 14;
K = 1;

c2 = hAs_pipes./(LS.p*LS.cp*LS.V_pipes);
b = [hAs_pipes(4)/(LS.p*LS.cp*LS.V1) LS.hAs_ThM1/(LS.p*LS.cp*LS.V1) 1/(LS.p*LS.cp*LS.V1);...
    hAs_pipes(10)/(LS.p*LS.cp*LS.V2) LS.hAs_ThM2/(LS.p*LS.cp*LS.V2) 1/(LS.p*LS.cp*LS.V2)];

e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'; b(1,2)];
e12 = [c2(1,[8 9])';0;c2(1,[11 12 13])'; b(2,2)];
e21 = [zeros(6,1); b(1,3)];
e22 = [zeros(6,1); b(2,3)];
E = [c2(1) 0 0; e11 e21 zeros(7,1); e12 zeros(7,1) e22; c2(14) 0 0];

x = zeros(n,2*K+L);
a = [interp1(LS.inc, LS.a1, d.V_ThM1), interp1(LS.inc, LS.a2, d.V_ThM2)];
x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ThM1(1) d.T_ByIn2(1) d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1) d.T_ThM2(1) d.T_PumpIn(1)];

P1 = 0.79*interp1(d_p1.Time, d_p1.Power,d.Time);
P2 = 0.79*interp1(d_p2.Time, d_p2.Power,d.Time);

seg = {'F1','L1S1','L1S2','L1S3','L1S4','L1S5','L1S6','L2S1','L2S2','L2S3','L2S4','L2S5','L2S6','R1'};
%% Simulate

m = zeros(n,14);
m(:,1) = d.M_Heater;
m(:,14) = d.M_Heater;
m(:,2) = d.M_Heater*(1-L2);
m(:,7) = d.M_Heater*(1-L2);
m(:,8)= d.M_Heater*L2;
m(:,13)= d.M_Heater*L2;
m(:,6) = (1-a(:,1)).*m(:,2);
m(:,3) = a(:,1).*m(:,2);
m(:,4) = a(:,1).*m(:,2);
m(:,5) = a(:,1).*m(:,2);
m(:,12) = (1-a(:,2)).*m(:,8);
m(:,9) = a(:,2).*m(:,8);
m(:,10) = a(:,2).*m(:,8);
m(:,11) = a(:,2).*m(:,8);

c1 = m./(LS.p*LS.V_pipes);
c3 = -(c1+c2);

for i = 1:n
    A = makeA(c1(i,:),c2,c3(i,:),b,a(i,:),L2,1);
    B = [c1(i,1);zeros(K+L,1)];
    u = [d.T_HeaterOut(i); d.T_Ambient(i); P1(i); P2(i)];
    
    Ad = (A+eye(2*K+L));
    Bd = [B E];
    x(i+1,:) = Ad*x(i,:)'+Bd*u;
end

%%
d_sim = array2table([(0:n)',x], 'VariableNames', ['Time', seg(1:7), 'ThM1',seg{8:13}, 'ThM2', seg{14}]);

T_pipe = [x(:,1:7) x(:,9:14) x(:,16)];
figure('Name', 'Temp')
tiledlayout(1,2,'TileSpacing','compact')
nexttile
hold on
plot(d_sim.Time(1:end-1), d.T_HeaterOut, '--k','linewidth',2)
plot(d_sim.Time, T_pipe(:,1:7), '--','Linewidth',2)
plot(d_sim.Time, T_pipe(:,8:end), 'linewidth',2)
plot(d_sim.Time(1:end-1), d.T_Ambient, 'k','linewidth',2)
plot(d_sim.Time, d_sim.ThM1,':', d_sim.Time, d_sim.ThM2, ':','linewidth',2)
legend(['Heater',seg,'Ambient','ThM1','ThM2'])
ylim([15 40])
box on; grid on; hold off

nexttile
T_pipes = [d.T_PumpIn d.T_Heater d.T_HeaterOut d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_Supply2 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2];

hold on
plot(d.Time, T_pipes(:,1:7), '--','Linewidth',2)
plot(d.Time, T_pipes(:,8:end), 'linewidth',2)
plot(d.Time, d.T_Ambient, 'k','linewidth',2)
plot(d.Time, d.T_ThM1,':', d.Time, d.T_ThM2, ':','linewidth',2)
ylim([15 40])
legend('Pump In', 'Heater', 'Heater Out', 'By In 1', 'Hx In 1','Hx Out1' ,'By Out 1', 'Supply 2', 'By In 2', 'Hx In 2', 'Hx Out 2', 'By Out 2', 'Return','Ambient','ThM1','ThM2')
box on; grid on; hold off

%% Error Metric

E_act = mean(LS.cp*d.M_Heater.*(d.T_HeaterOut-d.T_PumpIn));
E_sim = mean(LS.cp*d.M_Heater.*(d.T_HeaterOut-x(2:end,end)));

end