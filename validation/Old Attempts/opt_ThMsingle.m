function err = opt_ThMsingle(hAs,d,LS,ThMn,idx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Model Constants
%L2 = mean(d.M_Supply2./d.M_Heater,'all');
n = size(d,1);

L = 7;
K = 1;

c2 = hAs(1,1:8)./(LS.p*LS.cp*LS.V_pipes(idx));
b = [hAs(4) hAs(9)]/(LS.p*LS.cp*LS.(strcat('V',num2str(ThMn))));

e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'; b(1,2)];
E = [c2(1);e11; c2(8)];

x = zeros(n,2*K+L);

a = [interp1(LS.inc, LS.(strcat('a',num2str(ThMn))), d.(strcat('V_ThM',num2str(ThMn))))];
if ThMn == 1
    x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ThM1(1) d.T_PumpIn(1)];
elseif ThMn == 2
    x(1,:) = [d.T_Supply2(1) d.T_ByIn2(1) d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1) d.T_ThM2(1) d.T_PumpIn(1)];
end

%% Simulate

m = zeros(n,8);
m(:,1) = d.M_Heater;
m(:,2) = d.M_Heater;
m(:,3) = a(:,1).*d.M_Heater;
m(:,4) = a(:,1).*d.M_Heater;
m(:,5) = a(:,1).*d.M_Heater;
m(:,6) = (1-a(:,1)).*d.M_Heater;
m(:,7) = d.M_Heater;
m(:,8) = d.M_Heater;

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

%% Error Calculation
xr = x(1:end-1,:);

e(1) = rmse(xr(:,1),d.T_Supply2);
e(2) = rmse(xr(:,2),d.(strcat('T_ByIn',num2str(ThMn))));
e(3) = 100*rmse(xr(:,3),d.(strcat('T_HxIn',num2str(ThMn))));
e(4) = rmse(xr(:,4),d.(strcat('T_HxOut',num2str(ThMn))));
e(5) = rmse(a.*xr(:,5)+(1-a).*xr(:,6),d.(strcat('T_ByOut',num2str(ThMn))));
e(6) = rmse(xr(:,7),d.T_Return2);
e(7) = rmse(xr(:,9),d.T_PumpIn);
e(8) = rmse(xr(:,8),d.(strcat('T_ThM',num2str(ThMn))));

err = sum(e);
% if any(xr>d.T_HeaterOut+2,'all')
%     err = err+10000000;
% end
if isnan(err)
    err = 10000000;
end

%% Functions
    function es = rmse(d_est,d_act)
       es = sqrt(sum((d_act-d_est).^2)/length(d_est));
    end

end