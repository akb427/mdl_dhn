function y = sim_line(hAs,d,LS,idx,idxV)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Model Constants

n = size(d,1);

if length(idx) == 3
    x = zeros(n,1);
    x(1) = d.(idx(2))(1);
    c2 = hAs./(LS.p*LS.cp*LS.V_pipes(idxV));
    if any(idx(2) == [3 19 25]) % F1 R1 or S6 if only one temp goes into it
        m = d.M_Heater;
    elseif idx(2) == 10 % L1S1
        m = d.M_Heater-d.M_Supply2;
    elseif idx(2) == 20 % L2S1
        m = d.M_Supply2;
    elseif any(idx(2) == [11 13]) %L1S2 L1S3
        a = [interp1(LS.inc, LS.a1, d.V_ThM1)];
        m = a.*(d.M_Heater-d.M_Supply2);
    elseif any(idx(2) == [21 23]) %L2S2 L2S3
        a = [interp1(LS.inc, LS.a2, d.V_ThM2)];
        m = a.*d.M_Supply2;
    end
    c1 = m./(LS.p*LS.V_pipes(idxV));
    c3 = -(c1+c2);
    u = [d.(idx(1))';d.(idx(3))'];
    A = c3;
    B = [c1 c2*ones(n,1)];
    C = ones(n,1);
    yact = d.(idx(2));
elseif length(idx) == 4
    x = zeros(n,2);
    if idx(3) ==  14 % ByOut1
        a = [interp1(LS.inc, LS.a1, d.V_ThM1)];
        m = [a.*(d.M_Heater-d.M_Supply2) (1-a).*(d.M_Heater-d.M_Supply2)];
    elseif idx(3) == 24 % ByOut2
        a = [interp1(LS.inc, LS.a2, d.V_ThM2)];
        m = [a.*d.M_Supply2 (1-a).*d.M_Supply2];
    elseif idx(3) == 25 % S6 if two inlet temps 
        m = [(d.M_Heater-d.M_Supply2) d.M_Supply2];
    end
    c1 = m./(LS.p*LS.V_pipes(idxV));
    c2 = hAs./(LS.p*LS.cp*LS.V_pipes(idx(1,2)));
    C = [a (1-a)];
    yact = d.(idx(3));
end

y = zeros(n,1);
T = 1;
k = size(A,2);
for i = 1:n
    Afrt = inv((eye(k)-A(i,:)*T/2));
    Ad = Afrt*(eye(k)+A(i,:)*T/2);
    Bd = Afrt*B(i,:)*sqrt(T);
    Cd = sqrt(T)*C(i,:)*Afrt;
    x(i+1,:) = Ad*x(i,:)'+Bd*u(:,i);
    y(i,:) = Cd*x(i,:)';
end

%% Error Calculation

figure
hold on
plot(d.Time, u(1:end-1,:))
plot(d.Time, y)
plot(d.Time, u(end,:))
plot(d.Time, yact)
legend('In','Model','Tamb','Act')
hold off

%% Functions
    function es = rmse(d_est,d_act)
       es = sqrt(sum((d_act-d_est).^2)/length(d_est));
    end

end