function [dE,dTmax] = fincalc_enthalpy(G, n, params, tc, mdpts, pairs)
%FINCALC_ENTHALPY Summary of this function goes here
%   Detailed explanation goes here

%% Calculations
G =[G, zeros(n.u+n.s,8)];
idx = ~any(G(:,2)==G(:,1)',2);
G(:,3) = idx;
calc_users(unique(G(idx,1)'))

G(:,4) = params.cp*G(:,3)*tc.mi;
idx = G(:,3)>1;
G(idx,5) = params.DL;
G(~idx,5) = params.Ds;
tic
for i = 1:n.u+n.s
    ni = G(i,1);
    if ni~=0
        idx = mdpts(ni,:)==G(i,2);
        if any(idx)
            G(i,6) = tc.L_mdpts(ni,idx);
        else
            G(i,6) = tc.L_pairs(all(pairs==G(i,1:2),2));
        end
    else
        G(i,6) = tc.L_pairs(all(pairs==G(i,1:2),2));
    end
end
G(:,7)= params.h*pi*G(:,5).*G(:,6);

idx = G(:,1)==0;
G(idx,8) = params.Ts;
calc_dT(idx)

G(:,10) = G(:,4).*(G(:,8)-G(:,9));
dE = sum(G(:,10));
dTmax = max(params.Ts-G(:,9));


%% Functions

    function calc_users(nd)
    hold = NaN(1,n.u);
    idx2 = 1;
    for ii = nd    
        idx1 = G(:,1)==ii;
        if all(G(idx1,3)>=1)
            idx3 = G(:,2)==ii;
            G(idx3,3) = sum(G(idx1,3))+(G(idx3,2)<=n.u);
            idx3 = G(idx3&G(:,1)>0,1);
            if ~isempty(idx3)
                hold(idx2) = idx3;
                idx2 = idx2+1;
            end
        else
            hold(idx2) = ii;
            idx2 = idx2+1;
        end
    end
    if ~all(isnan(hold))
        hold = hold(~isnan(hold));
        calc_users(unique(hold));
    end
    end

    function calc_dT(idx1)
        G(idx1,9) = G(idx1,4)./(G(idx1,4)+G(idx1,7)).*G(idx1,8)+G(idx1,7)./(G(idx1,4)+G(idx1,7))*params.Ta;
        for ii = find(idx1)'
            idx2 = G(:,1)==G(ii,2);
            if any(idx2)
                G(idx2,8) = G(ii,9);
                calc_dT(idx2)
            end
        end
    end
    
end

