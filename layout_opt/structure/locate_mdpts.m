function [map] = locate_mdpts(mdpts,map, nu)
%FUNCTION_NAME  One-line summary of what the function does.
%
%   [map] = locate_mdpts(mdpts,map, nu)
%
%   DESCRIPTION:
%   Get the x and y coordinates of all the midpoints. Locate the points
%   averaged between all points that make up midpoint. Adds a dummy row to
%   the map to account for the midpoints containing zero elements to
%   maintain space efficiency of the mdpts variable, which is removed
%   before outputing map.
%
%   INPUTS:
%       mdpts   - Matrix of midpoint components.
%       map     - X and Y coordinates of the users.
%       nu      - Number of users in the system.
%
%   OUTPUTS:
%       map     - X and Y coordinates of the users and midpoints.
%
%   SEE ALSO: generate_structure, create_map.

%% Setup

% initialize storage with NaN for 0 points.
map_x = [NaN; map(:,1); zeros(size(mdpts,1)-nu,1)];
map_y = [NaN; map(:,2); zeros(size(mdpts,1)-nu,1)];

% all midpoints of users
idx_lower = nu+1;
idx_upper = find(all(mdpts<=nu,2),1,'last');

%% Locate midpoints in chunks

% while there are still midpoints to locate
while idx_lower<size(mdpts, 1)
    % maps points to correct rows in map with NaN included
    idx_in_map = mdpts(idx_lower:idx_upper,:)+1;
    % average Location
    pts_x = map_x(idx_in_map);
    pts_x = mean(pts_x,2, 'omitnan');   % ignore zeros in mdpts
    pts_y = map_y(idx_in_map);
    pts_y = mean(pts_y,2, 'omitnan');   % ignore zeros in mdpts
    % add to map list
    map_x(idx_lower+1:idx_upper+1) = pts_x;
    map_y(idx_lower+1:idx_upper+1) = pts_y;
    % increment midpoint set
    idx_lower = idx_upper+1;
    % midpoints where all components have been located
    idx_upper = find(all(mdpts<=idx_upper,2),1,'last');
end

%% Remove auxilliary NaN row
map = [map_x(2:end) map_y(2:end)];

end