function err = simresults_optThM(hAs,d,LS,L2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Model Constants
%L2 = mean(d.M_Supply2./d.M_Heater,'all');
n = size(d,1);

L = 14;
K = 1;

c2 = hAs(1,1:14)./(LS.p*LS.cp*LS.V_pipes);
b = [hAs(4)/(LS.p*LS.cp*LS.V1) hAs(15)/(LS.p*LS.cp*LS.V1) 1/(LS.p*LS.cp*LS.V1);...
    hAs(10)/(LS.p*LS.cp*LS.V2) hAs(16)/(LS.p*LS.cp*LS.V2) 1/(LS.p*LS.cp*LS.V2)];

e11 = [c2(1,[2 3])';0;c2(1,[5 6 7])'; b(1,2)];
e12 = [c2(1,[8 9])';0;c2(1,[11 12 13])'; b(2,2)];
%e21 = [zeros(6,1); b(1,3)];
%e22 = [zeros(6,1); b(2,3)];
%E = [c2(1) 0 0; e11 e21 zeros(7,1); e12 zeros(7,1) e22; c2(14) 0 0];
E = [c2(1);e11; e12; c2(14)];

x = zeros(n,2*K+L);
a = [interp1(LS.inc, LS.a1, d.V_ThM1), interp1(LS.inc, LS.a2, d.V_ThM2)];
x(1,:) = [d.T_Supply2(1) d.T_ByIn1(1) d.T_HxIn1(1) d.T_HxOut1(1) d.T_ByOut1(1) d.T_ByOut1(1) d.T_Return2(1) d.T_ThM1(1) d.T_ByIn2(1) d.T_HxIn2(1) d.T_HxOut2(1) d.T_ByOut2(1) d.T_ByOut2(1) d.T_Return2(1) d.T_ThM2(1) d.T_PumpIn(1)];

%P1 = zeros(n,1);
%P2 = zeros(n,1);

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
    %u = [d.T_HeaterOut(i); d.T_Ambient(i); P1(i); P2(i)];
    u = [d.T_HeaterOut(i); d.T_Ambient(i)];
    Ad = (A+eye(2*K+L));
    Bd = [B E];
    x(i+1,:) = Ad*x(i,:)'+Bd*u;
end



%% Error Calculation
xr = x(1:end-1,:);


e(1) = rmse(xr(:,1),d.T_Supply2);
e(2) = rmse(xr(:,2),d.T_ByIn1);
e(3) = rmse(xr(:,3),d.T_HxIn1);
e(4) = rmse(xr(:,4),d.T_HxOut1);
e(5) = rmse(a(:,1).*xr(:,5)+(1-a(:,1)).*xr(:,6),d.T_ByOut1);
e(6) = rmse(xr(:,9),d.T_ByIn2);
e(7) = rmse(xr(:,10),d.T_HxIn2);
e(8) = rmse(xr(:,11),d.T_HxOut2);
e(9) = rmse(a(:,2).*xr(:,12)+(1-a(:,2)).*xr(:,13),d.T_ByOut2);
e(10) = rmse((1-L2)*xr(:,7)+L2.*xr(:,14),d.T_Return2);
e(11) = rmse(xr(:,16),d.T_PumpIn);
e(13) = rmse(xr(:,8),d.T_ThM1);
e(14) = rmse(xr(:,15),d.T_ThM2);

err = sum(e);
if any(xr>d.T_HeaterOut+2,'all')
    err = err+10000000;
end
if isnan(err)
    err = 10000000;
end

%% Functions
    function es = rmse(d_est,d_act)
       es = sqrt(sum((d_est-d_act).^2)/length(d_est));
    end

end