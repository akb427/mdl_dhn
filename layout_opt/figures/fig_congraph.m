function fig_congraph(pth)
%FIG_CONGRAPH  Illustrative plot of how nodes can be connected.
%
%   FIG_CONGRAPH(pth)
%
%   DESCRIPTION:
%   Plots the possible connections of the nodes of a four user graph. Uses
%   icon shape to indicate number of users in the midpoint and the color to
%   indicate members in the prize set for illustrative purposes. 
%
%   INPUTS:
%       pth  - String of folder path
%
%   DEPENDENCIES: generate_structure.
%
%   SEE ALSO: pair_pts.

%% Generate Layout
nu = 4;

% either load or create and then load structure
struct_file = sprintf('%sstruct%dusers.mat', fullfile(pth, 'structure\'), nu);
if isfile(struct_file)
    load(struct_file, 'users_in_mdpt','pairs')
else
    generate_structure(nu, struct_file)
    load(struct_file, 'users_in_mdpt','pairs')
end

%% Generate connection graph

% sort by number of users
[~,idx] = sort(sum(users_in_mdpt,2));
users_in_mdpt = users_in_mdpt(idx,:);

n_users = sum(users_in_mdpt,2);

% Create Solution Graph
G = graph(pairs(:,1)+1,pairs(:,2)+1);
G = simplify(G);

%% Make sytle vectors

% Create list of potential prize sets
prize_set = [];
for idx_user = 1:nu
    elem = nchoosek(1:nu,idx_user);
    for j = 1:size(elem,1)
        idx = zeros(1,nu);
        idx(elem(j,:)) = 1;
        prize_set = [prize_set;idx];
    end
end

% Number of prize sets
n_set = size(prize_set,1);

% Node style information
sty = ["o","^","diamond","square"];
clr = lines(7);
clr2 = zeros(n_set,3);

% Preallocate storage for node styles
nd_sty = strings(numnodes(G)-1,1);
nd_col = zeros(numnodes(G)-1,3);
lgd = strings(n_set,1);

for idx_user = 1:nu
    % Set node style based on number of users
    nd_sty(n_users==idx_user)= sty(idx_user);
    % Set the colors for nodes with same number of suers
    clr2(sum(prize_set,2)==idx_user,:) = clr(1:sum(sum(prize_set,2)==idx_user),:);
end
for idx_set = 1:n_set
    for j = 1:3
        nd_col(ismember(users_in_mdpt, prize_set(idx_set,:),'rows'),j) = clr2(idx_set,j);
    end
    lgd_ent = num2str(find(prize_set(idx_set,:)),'%i,');
    lgd_ent(end) = '';
    lgd(idx_set) = lgd_ent;
end

%% Set up plot

figure('Name','Prize Graph')

ax(nu) = axes();
hold(ax(nu));
for idx_set = 1:nu-1
    ax(idx_set) = axes('visible','off');
    hold(ax(idx_set));
end

%% Legend Positioning

pos = [0.747619045746049,0.795634924564603,0.176190476190476,0.129761904761905; ...
0.747619045746049,0.497222222222223,0.176190476190476,0.280555555555556;...
0.747619045746049,0.271031746031746,0.176190476190476,0.20515873015873;...
0.747619045746049,0.109523809431708,0.176190476190476,0.092063492063492];

x = (pos(1,2)-pos(4,2)-pos(4,4)-pos(2,4)-pos(3,4))/3;
pos(2,2) = pos(1,2)-x-pos(2,4);
pos(3,2) = pos(2,2)-x-pos(3,4);

%% Plot Legends

leg_title=["User","2 User Midpoint","3 User Midpoint","4 User Midpoint"];

for idx_user = 1:nu
    idx_elems = find(sum(prize_set,2)==idx_user);
    for j = idx_elems'
        plot(ax(idx_user), nan,nan, 'Marker',sty(idx_user),'MarkerFaceColor', clr2(j,:),'MarkerEdgeColor', clr2(j,:),'LineStyle','none')
    end
    if idx_user == nu
        lg(idx_user) = legend(ax(idx_user),lgd(idx_elems),'Location','SouthEastOutside','AutoUpdate','off');
    elseif idx_user == 1
        lg(idx_user) = legend(ax(idx_user),lgd(idx_elems),'Position',pos(idx_user,:),'AutoUpdate','off','NumColumns',2);
    else
        lg(idx_user) = legend(ax(idx_user),lgd(idx_elems),'Position',pos(idx_user,:),'AutoUpdate','off');

    end
    lg(idx_user).ItemTokenSize(1) = 7;
    title(lg(idx_user),leg_title(idx_user));
end

%% Plot Graph

nd_sty = ["pentagram";nd_sty];
nd_col = [0 0 0; nd_col];
lgd = ["Plant";lgd];

nd_lbl = strings(numnodes(G),1);
nd_lbl(1) = "Plant";

p = plot(ax(nu),G,'Layout','layered','AssignLayers','alap');
p.Marker = nd_sty;
p.NodeLabel = nd_lbl;
p.NodeLabel = [];
text(ax(nu),55.5,7.1,'Plant')
p.NodeFontSize = 11;
p.EdgeColor = 'k';
p.MarkerSize = 8;
p.NodeColor = nd_col;
p.EdgeAlpha = 1;
set(ax(nu),'xtick',[],'ytick',[])
box(ax(nu))
hold off

end