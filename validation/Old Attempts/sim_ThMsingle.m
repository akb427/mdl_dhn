function [x] = sim_ThMsingle(hAs,d,LS,ThMn,idx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Model Constants
%L2 = mean(d.M_Supply2./d.M_Heater,'all');
n = size(d,1);

L = 7;
K = 1;

c2 = hAs(1,1:8)./(LS.p*LS.cp*LS.V_pipes(idx));
b = [hAs(4)/(LS.p*LS.cp*LS.(strcat('V',num2str(ThMn)))) hAs(9)/(LS.p*LS.cp*LS.(strcat('V',num2str(ThMn))))];

e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'; b(1,2)];
E = [c2(1);e11; c2(8)];

x = zeros(n,2*K+L);

a = [interp1(LS.inc, LS.(strcat('a',num2str(1))), d.(strcat('V_ThM',num2str(1))))];
if ThMn == 1
x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ThM1(1) d.T_PumpIn(1)];
elseif ThMn == 2
x(1,:) = [d.T_Supply2(1) d.T_ByIn2(1) d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1) d.T_ThM2(1) d.T_PumpIn(1)];
end

%% Simulate

m = zeros(n,8);
m(:,1) = d.M_Heater;
m(:,2) = d.M_Heater;
m(:,7) = d.M_Heater;
m(:,8) = d.M_Heater;
m(:,6) = (1-a(:,1)).*d.M_Heater;
m(:,3) = a(:,1).*d.M_Heater;
m(:,4) = a(:,1).*d.M_Heater;
m(:,5) = a(:,1).*d.M_Heater;

c1 = m./(LS.p*LS.V_pipes(idx));
c3 = -(c1+c2);

T = 1;
for i = 1:n
    A = makeAsingle(c1(i,:),c2,c3(i,:),b,a(i,:));
    B = [c1(i,1);zeros(K+L,1)];
    Btot = [B E];
    %u = [d.T_HeaterOut(i); d.T_Ambient(i); P1(i); P2(i)];
    u = [d.T_HeaterOut(i); d.T_Ambient(i)];
    %Ad = (A+eye(2*K+L));
    %Bd = [B E];
    Afrt = (eye(2*K+L)-A*T/2);
    Ad = Afrt\(eye(2*K+L)+A*T/2);
    Bd = Afrt\Btot*sqrt(T);
    x(i+1,:) = Ad*x(i,:)'+Bd*u;
end

%% Plotting
xr = x(1:end-1,:);

figure('Name', 'Temp')
tiledlayout(1,2,'TileSpacing','compact')
nexttile

T_pipes_sim = [d.T_HeaterOut xr(:,1:4) a.*xr(:,5)+(1-a).*xr(:,6) xr(:,7) xr(:,9)];
hold on
plot(d.Time, T_pipes_sim(:,1:7),'Linewidth',2)
plot(d.Time, T_pipes_sim(:,8:end),'--' ,'linewidth',2)
plot(d.Time, d.T_Ambient, 'k','linewidth',2)
plot(d.Time, xr(:,8),':','linewidth',2)
ylim([23 40])
legend('Heater','F1','Bypass In', 'Hx In','Hx Out','Bypass Out','Loop Out','R1','Ambient',strcat('ThM',num2str(ThMn)))
box on; grid on; hold off


nexttile
if ThMn == 1
    T_pipes = [d.T_HeaterOut d.T_Supply2 d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_Return2 d.T_PumpIn];
elseif ThMn == 2
    T_pipes = [d.T_HeaterOut d.T_Supply2 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2 d.T_PumpIn];
end

hold on
plot(d.Time, T_pipes(:,1:7), 'Linewidth',2)
plot(d.Time, T_pipes(:,8:end),'--' ,'linewidth',2)
plot(d.Time, d.T_Ambient, 'k','linewidth',2)
plot(d.Time, d.(strcat('T_ThM',num2str(ThMn))),':','linewidth',2)
ylim([23 40])
legend('Heater','F1','Bypass In', 'Hx In','Hx Out','Bypass Out','Loop Out','R1','Ambient',strcat('ThM',num2str(ThMn)))
box on; grid on; hold off
%% Functions
    function es = rmse(d_est,d_act)
       es = sqrt(sum((d_est-d_act).^2)/length(d_est));
    end

end