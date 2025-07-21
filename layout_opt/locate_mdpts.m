function [map] = locate_mdpts(mdpts,map, nu)
%FUNCTION_NAME  One-line summary of what the function does.
%
%   [map] = locate_mdpts(mdpts,map, nu)
%
%   DESCRIPTION:
%   Briefly explain the purpose of the function, what it computes, or how it
%   fits into the overall workflow. Mention any important assumptions or side
%   effects (e.g., plotting, modifying global variables, saving files).
%
%   INPUTS:
%       in1  - Description of input 1 (type, format, units if applicable)
%       in2  - Description of input 2
%       ...  - Additional inputs as needed
%
%   OUTPUTS:
%       out1 - Description of output 1 (what it represents)
%       out2 - Description of output 2
%       ...  - Additional outputs as needed
%
%   EXAMPLE USAGE:
%       [best_part, results] = my_partition_solver(G, params);
%
%   DEPENDENCIES:
%       List other custom functions this function calls, if any.
%
%   SEE ALSO:
%       RelatedFunction1, RelatedFunction2

%% Setup

% Initialize storage
map_x = [NaN; map(:,1); zeros(size(mdpts,1)-nu,1)];
map_y = [NaN; map(:,2); zeros(size(mdpts,1)-nu,1)];

% all midpoints of users
idx_lower = nu+1;
idx_upper = find(all(mdpts<=nu,2),1,'last');

%%
while idx_lower<size(mdpts, 1)
    idx_in_map = mdpts(idx_lower:idx_upper,:)+1;
    % Average Location
    pts_x = map_x(idx_in_map);
    pts_x = mean(pts_x,2, 'omitnan');
    pts_y = map_y(idx_in_map);
    pts_y = mean(pts_y,2, 'omitnan');
    % Add to map list
    map_x(idx_lower+1:idx_upper+1) = pts_x;
    map_y(idx_lower+1:idx_upper+1) = pts_y;
    % Increment midpoint set
    idx_lower = idx_upper+1;
    % where all midpoints have been located
    idx_upper = find(all(mdpts<=idx_upper,2),1,'last');
end
map = [map_x(2:end) map_y(2:end)];
end