clc, clear, close all

%% Load System Parameters

load('struct8users.mat')

%% Map

grabit('ParmaMap.jpg');
disp('Press enter once points are selected')
pause;
map = Data001;
map = map(2:end,:)-map(1,:);

% map = randi([-10 10],n.u,2);
%load('parma8users');
%params.mapb = parma8users;

clear Data001

[map] = locate_mdpts(mdpts, map, n.u);   % calcualte midpoint locations

%% Save

filename = ['map', num2str(n.u), 'users.mat'];
i=0;
while isfile(filename)
    i = i+1;
    filename = ['map', num2str(n.u), 'users',num2str(i),'.mat'];
end

save(filename,'map','i')

