function [c_list, tc] = cost_enthalpy(mdpts, users_in_mdpt, pairs, users_in_node2, params,n)
%COST_Enthalpy  Finds the losses in all midpoint pairs.
%
%   [c2, cpairs] = COST_ENTHALPY(mdpts, pairs, params,n)
%
%   DESCRIPTION:
%   Finds the length needed to connect midpoints together. Then finds the
%   length needed to connect pairs of midpoints together, including
%   connecting the midpoints to the plant. Performs calculation in blocks
%   to take advantage of matrix operations
%
%   INPUTS:
%       mdpts   - Matrix of midpoint components.
%       users_in_mdpt   - Binary matrix of users in each midpoint.
%       pairs   - Matrix of all midpoint pairs that don't overlap users.
%       users_in_node2  - Users in the midpoint in the second column of pair.
%       params  - Structure of system parameters.
%       n       - Structure of system sizings.
%
%   OUTPUTS:
%       c2      - Vector of total loss cost of pairs.
%       tc      - Structure of element parameters to be used in
%                 bnb_enthalpy.
%
%   SEE ALSO: bnb_enthalpy

%% Clean up map

map = params.mapb(2:end,:);
% add NaN for 0 "midpoints"
map_x = [NaN; map(:,1)];
map_y = [NaN; map(:,2)];

%% Problem Setup

% preallocate storage
c1 = [NaN; zeros(size(mdpts, 1),1)];
tc.L_mdpts = zeros(size(mdpts));
D = zeros(size(mdpts));
m = zeros(size(mdpts));

% lower bound parameters
tc.Tin = params.Ts-params.x;
tc.mi = params.mI/n.u;

% size diameter by number of user served
% only 1 user downstream gets small diameter
D(mdpts>0) = params.Ds;
% more than 1 user downstream gets big diameter
D(mdpts>n.u) = params.DL;

% mass flow proportional to downstream users
num_users_downstream = sum(users_in_mdpt,2);
m(mdpts>0) = tc.mi;
m(mdpts>n.u) = num_users_downstream(mdpts(mdpts>n.u),1)*tc.mi;
tc.mcp_mdpts = m*params.cp;

%% Initialize solving

% midpoints of only users
idx_lower = n.u+1;
idx_upper = find(all(mdpts<=n.u,2),1,'last');

% midpoints of points
mdptsac = mdpts;
mdptsac(mdptsac<=n.u) = 0;
mdptsac = mdptsac+1;

%% Calculate costs

while idx_lower<size(mdpts, 1)
    % index of component points in the map
    idx_in_map = mdpts(idx_lower:idx_upper,:)+1;
    % distance from midpoint to its components
    x = (map(idx_lower:idx_upper,1)-map_x(idx_in_map)).^2;
    y = (map(idx_lower:idx_upper,2)-map_y(idx_in_map)).^2;
    % store distances
    tc.L_mdpts(idx_lower:idx_upper,:) = sqrt(x+y);
    % calculate heat transfer coefficient
    tc.hAs_mdpts(idx_lower:idx_upper,:) = pi*params.h*tc.L_mdpts(idx_lower:idx_upper,:).*D(idx_lower:idx_upper,:);
    % outlet temperatures [mc_p/(mc_p+hAs)*T_in]+[hA_s/(mc_p+hAs)*T_a]
    term1 = tc.mcp_mdpts(idx_lower:idx_upper,:)./(tc.mcp_mdpts(idx_lower:idx_upper,:)+tc.hAs_mdpts(idx_lower:idx_upper,:))*tc.Tin;
    term2 = tc.hAs_mdpts(idx_lower:idx_upper,:)./(tc.mcp_mdpts(idx_lower:idx_upper,:)+tc.hAs_mdpts(idx_lower:idx_upper,:))*params.Ta;
    To = term1+term2;
    % enthalpy loss
    E = tc.mcp_mdpts(idx_lower:idx_upper,:).*(tc.Tin-To);
    % cost is cost to connect plus the cost of the new midpoint
    c1(idx_lower+1:idx_upper+1) = sum(E,2,'omitnan')+sum(c1(mdptsac(idx_lower:idx_upper,:)),2,'omitnan');
    % increment midpoint set
    idx_lower = idx_upper+1;
    % midpoints where all components have cost calculated
    idx_upper = find(all(mdpts<=idx_upper,2),1,'last');
end

%% Apply to pairs

% size diameter of pair connectors by number of user served
D = params.Ds*ones(size(pairs,1),1);
D(pairs(:,2)>n.u) = params.DL;

% mass flow in connector proportional to downstream user
num_users_downstream = sum(users_in_node2,2);
m = num_users_downstream*tc.mi;
mcp = m*params.cp;

% increment to include plant
pairs = pairs+1;
% distance between pair sets
x = (params.mapb(pairs(:,1),1)-params.mapb(pairs(:,2),1)).^2;
y = (params.mapb(pairs(:,1),2)-params.mapb(pairs(:,2),2)).^2;
tc.L_pairs = sqrt(x+y);
% heat transfer coefficient
hAs = pi*params.h*tc.L_pairs.*D;
% steady state outlet temperature
To = mcp./(mcp+hAs)*tc.Tin+hAs./(mcp+hAs)*params.Ta;
% enthalpy loss
E = mcp.*(tc.Tin-To);
% cost is enthalpy loss between pairs plus second element cost
c_list = sum(E,2)+c1(pairs(:,2));

end