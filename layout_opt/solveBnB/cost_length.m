function [c2, cpairs] = cost_length(mdpts, pairs, params,n)
%COST_LENGTH  Finds the length in all midpoint pairs.
%
%   [c2, cpairs] = COST_LENGTH(mdpts, pairs, params,n)
%
%   DESCRIPTION:
%   Finds the length needed to connect midpoints together. Then finds the
%   length needed to connect pairs of midpoints together, including
%   connecting the midpoints to the plant. Performs calculation in blocks
%   to take advantage of matrix operations
%
%   INPUTS:
%       mdpts   - Matrix of midpoint components.
%       pairs   - Matrix of all midpoint pairs that don't overlap users.
%       params  - Structure of system parameters.
%       n       - Structure of system sizings.
%
%   OUTPUTS:
%       c2      - Vector of total distance cost of pairs
%       cpairs  - Vector of distances between pairs
%
%   SEE ALSO: bnb_length

%% Clean up map
mapb = params.mapb;         % map with plant
map = mapb(2:end,:);        % remove plant
% add NaN for 0 "midpoints"
map_x = [NaN; map(:,1)];
map_y = [NaN; map(:,2)];
% preallocate storage
c1 = [NaN; zeros(size(mdpts, 1),1)];

%% Initialize solving
% all midpoints of users
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
    % cost is distance to connect plus the cost of the new midpoint
    c1(idx_lower+1:idx_upper+1) = sum(sqrt(x+y),2,'omitnan')+sum(c1(mdptsac(idx_lower:idx_upper,:)),2,'omitnan');
    % increment midpoint set
    idx_lower = idx_upper+1;
    % midpoints where all components have cost calculated
    idx_upper = find(all(mdpts<=idx_upper,2),1,'last');
end

%% Apply to pairs

% increment to include plant
pairs = pairs+1;
% distance between pair sets
x = (mapb(pairs(:,1),1)-mapb(pairs(:,2),1)).^2;
y = (mapb(pairs(:,1),2)-mapb(pairs(:,2),2)).^2;
% cost is distance between pairs plus second element cost
c2 = sum(sqrt(x+y),2)+c1(pairs(:,2));
% only distance between pairs
cpairs = sum(sqrt(x+y),2);

end