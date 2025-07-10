%CREATE_MAP  Location of network nodes.
%
%   DESCRIPTION:
%   Gets the user locations as x,y coordinates. Uses grabit to locate 
%   points on a map, or randomly generates them. Uses these points to 
%   generate the location of the midpoints. Saves the points as
%   mapXusersI.
%
%   DEPENDENCIES: locate_mdpts
%
%   SEE ALSO: generate_structure

%%
clc, clear, close all

%% Load System Parameters

load('struct8users.mat')

%% Map

% Parma case study
grabit('ParmaMap.jpg');
disp('Press enter once points are selected')
pause;
map = Data001;
map = map(2:end,:)-map(1,:);

% Random case study
% map = randi([-10 10],n.u,2);
% load('parma8users');
% params.mapb = parma8users;

clear Data001

[map] = locate_mdpts(mdpts, map, n.u);   % calcualte midpoint locations

%% Save

baseName = sprintf('map%dusers', n.u);
file_version = 0;
filename = sprintf('%s.mat', baseName);
% Find unique version
while isfile(filename)
    file_version = file_version + 1;
    filename = sprintf('%s%d.mat', baseName, file_version);
end

save(filename, 'map', 'file_version');
