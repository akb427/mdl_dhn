function fig_congraph
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Generate Midpoints
nu = 4;
cd 'C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Project Codes\Layout Optimization'
[~, usersm] = generate_mdpts(nu);    % recursively generate all potential midpoints
[~,idx] = sort(sum(usersm,2));
usersm = usersm(idx,:);
[pairs, ~] = pair_pts(usersm);   % generate valid parent child pairs
cd 'C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Project Codes\Layout Optimization\figures'
n_users = sum(usersm,2);

% Create Solution Graph
G = graph(pairs(:,1)+1,pairs(:,2)+1);
G = simplify(G);
%% Make sytle vectors

% Create list of potential prize sets
prize_set = [];
for i = 1:nu
    elem = nchoosek(1:nu,i);
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

for i = 1:nu
    % Set node style based on number of users
    nd_sty(n_users==i)= sty(i);
    % Set the colors for nodes with same number of suers
    clr2(sum(prize_set,2)==i,:) = clr(1:sum(sum(prize_set,2)==i),:);
end
for i = 1:n_set
    for j = 1:3
        nd_col(ismember(usersm, prize_set(i,:),'rows'),j) = clr2(i,j);
    end
    lgd_ent = num2str(find(prize_set(i,:)),'%i,');
    lgd_ent(end) = '';
    lgd(i) = lgd_ent;
end


%% Set up plot

figure('Name','Prize Graph')

ax(nu) = axes();
hold(ax(nu));
for i = 1:nu-1
    ax(i) = axes('visible','off');
    hold(ax(i));
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

for i = 1:nu
    idx_elems = find(sum(prize_set,2)==i);
    for j = idx_elems'
        plot(ax(i), nan,nan, 'Marker',sty(i),'MarkerFaceColor', clr2(j,:),'MarkerEdgeColor', clr2(j,:),'LineStyle','none')
    end
    if i == nu
        lg(i) = legend(ax(i),lgd(idx_elems),'Location','SouthEastOutside','AutoUpdate','off');
    elseif i == 1
        lg(i) = legend(ax(i),lgd(idx_elems),'Position',pos(i,:),'AutoUpdate','off','NumColumns',2);
    else
        lg(i) = legend(ax(i),lgd(idx_elems),'Position',pos(i,:),'AutoUpdate','off');

    end
    lg(i).ItemTokenSize(1) = 7;
    title(lg(i),leg_title(i));
end

%%
nd_sty = ["pentagram";nd_sty];
nd_col = [0 0 0; nd_col];
lgd = ["Plant";lgd];

nd_lbl = strings(numnodes(G),1);
nd_lbl(1) = "Plant";

%p = plot(G,'Layout','force','UseGravity',true);
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