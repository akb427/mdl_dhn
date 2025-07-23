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

%% Setup
clc, clear, close all
pth = pwd;
addpath(fullfile(pth, 'structure'));

%% Get midpoint stucture
n.u = 4;

struct_file = sprintf('%sstruct%dusers.mat', fullfile(pth, 'structure\'),n.u);
if isfile(struct_file)
    load(struct_file)
else
    generate_structure(n.u, struct_file)
    load(struct_file)
end

%% Map of users and midpoints

% Parma case study from map
% grabit('ParmaMap.jpg');
% disp('Press enter once points are selected')
% pause;
% map = Data001;
% map = map(2:end,:)-map(1,:);
% clear Data001

% Load previous parma user locations
% load('parma8users');
% params.mapb = parma8users;

% Random case study
map = randi([-10 10],n.u,2);

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
