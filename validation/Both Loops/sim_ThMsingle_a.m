function [err, y, x] = sim_ThMsingle_a(inpt,d,LS,ThMn,flag)
%SIM_THMSINGLE_A Optimize and simulate a single loop of the network, 
%changing the hAs and a values 
%   inpt: input to be optimized of the form [hAs_pipes, hAs_ThM a]
%   d: data to be matched
%   LS: parameters of the lab scale system including volumes of ThM and
%   pipes
%   ThMn: Number of the thermal mass loop being calibrated
%   flag=1: simulate, flag=0 optimize

%% Model Constants

a = inpt(end);
hAs = inpt(1:end-1);

L = 7;
K = 1;
n = size(d,1);

x = zeros(n,2*K+L);
y = zeros(n,8);

if ThMn == 1
    idx = [1:7,14];
    x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ThM1(1) d.T_PumpIn(1)];
elseif ThMn == 2
    idx = [1 8:13, 14];
    x(1,:) = [d.T_Supply2(1) d.T_ByIn2(1) d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1) d.T_ThM2(1) d.T_PumpIn(1)];
end

c2 = hAs(1,1:8)./(LS.p*LS.cp*LS.V_pipes(idx));
bldg = [hAs(4) hAs(9)]/(LS.p*LS.cp*LS.(strcat('V',num2str(ThMn))));
e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'; bldg(1,2)];
E = [c2(1);e11; c2(8)];

%% Simulate

m = zeros(n,8);
m(:,1) = d.M_Heater;
m(:,2) = d.M_Heater;
m(:,3) = a*d.M_Heater;
m(:,4) = a*d.M_Heater;
m(:,5) = a*d.M_Heater;
m(:,6) = (1-a)*d.M_Heater;
m(:,7) = d.M_Heater;
m(:,8) = d.M_Heater;

c1 = m./(LS.p*LS.V_pipes(idx));
c3 = -(c1+c2);

T = 1;
C = eye(9);
C(6,:) = [];
C(5,5) = a;
C(5,6) = 1-a;

for i = 1:n
    A = makeAsingle(c1(i,:),c2,c3(i,:),bldg,a);
    B = [c1(i,1);zeros(K+L,1)];
    Btot = [B E];
    u = [d.T_HeaterOut(i); d.T_Ambient(i)];
    Afrt = inv(eye(2*K+L)-A*T/2);
    Ad = Afrt*(eye(2*K+L)+A*T/2);
    Bd = Afrt*Btot*sqrt(T);
    Cd = sqrt(T)*C*Afrt;
    x(i+1,:) = Ad*x(i,:)'+Bd*u;
    y(i,:) = Cd*x(i,:)'+(zeros(8,2)+C*Afrt*Btot*T/2)*u;
end

%% Error Calculation

y_act = [d.T_Supply2, d.(strcat('T_ByIn',num2str(ThMn))),...
    d.(strcat('T_HxIn',num2str(ThMn))), d.(strcat('T_HxOut',num2str(ThMn))),...
    d.(strcat('T_ByOut',num2str(ThMn))), d.T_Return2, d.(strcat('T_ThM',num2str(ThMn))), d.T_PumpIn];
e(1) = rmse(y(:,1),y_act(:,1));
e(2) = rmse(y(:,2),y_act(:,2));
e(3) = rmse(y(:,3),y_act(:,3));
e(4) = rmse(y(:,4),y_act(:,4));
e(5) = rmse(y(:,5),y_act(:,5));
e(6) = rmse(y(:,6),y_act(:,6));
e(7) = rmse(y(:,7),y_act(:,7));
e(8) = rmse(y(:,8),y_act(:,8));

err = sum(e);

%% Plotting

if flag
    figure('Name', 'Compare Data')
    tiledlayout(1,2,'TileSpacing','compact')
    
    nexttile
    hold on
    plot(d.Time, y(:,[1:6,8]), 'Linewidth',2);
    plot(d.Time, d.T_HeaterOut,'--' ,'Linewidth',2);
    plot(d.Time, d.T_Ambient, 'k','linewidth',2)
    plot(d.Time, y(:,7),':','linewidth',2)
    ylim([23 40])
    title('Simulation')
    box on; grid on; hold off

    if ThMn == 1
        T_pipes = [d.T_Supply2 d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_Return2 d.T_PumpIn];
    elseif ThMn == 2
        T_pipes = [d.T_Supply2 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2 d.T_PumpIn];
    end
    nexttile
    hold on
    plot(d.Time, T_pipes, 'Linewidth',2)
    plot(d.Time, d.T_HeaterOut,'--' ,'Linewidth',2);
    plot(d.Time, d.T_Ambient, 'k','linewidth',2)
    plot(d.Time, d.(strcat('T_ThM',num2str(ThMn))),':','linewidth',2)
    ylim([23 40])
    legend('F1','Bypass In', 'Hx In','Hx Out','Bypass Out','Loop Out','R1','Heater','Ambient',strcat('ThM',num2str(ThMn)))
    title('Actual')
    box on; grid on; hold off
end

%% Functions
    function es = rmse(d_est,d_act)
    es = sqrt(sum((d_act-d_est).^2)/length(d_est));
    end

end