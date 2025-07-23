function [e, l] = fig_layout(map, e, l, mdpts, n, pairs, params)
%FIG_LAYOUT  One-line summary of what the function does.
%
%   [e, l] = FIG_LAYOUT(map, e, l, mdpts, n, pairs, params)
%
%   DESCRIPTION:
%   
%
%   INPUTS:
%       map     - Matrix of X and Y coordinates of the users and midpoints.
%       e       - Structure of enthalpy minimizing results.
%       l       - Structure of length minimizing results.
%       mdpts   - Matrix of midpoints described by row.
%       n       - Structure of problem sizing.
%       pairs   - Matrix of all midpoint pairs that don't overlap users.
%       params  - Structure of system parameters.
%
%   OUTPUTS:
%       e       - Structure of enthalpy minimizing results.
%       l       - Structure of length minimizing results.
%
%   DEPENDENCIES: expand_tree

%% Prepare data

% expand tree
[l.tr_exp,~] = expand_tree(l.tr,mdpts,n,0);
[e.tr_exp,~] = expand_tree(e.tr,mdpts,n,0);

% add plant
map = [0 0; map];

% nodes in length solution
l.node_list = unique(l.tr_exp);
l.map = map(l.node_list+1,:);
n.sl = sum(l.node_list>n.u);

% calculate enthalpy cost for length solution
n.s =n.sl;
[l.cost_enthalpy, ~] = fincalc_enthalpy(l.tr_exp,n,params,e.c_comp,mdpts,pairs);

% nodes in enthalpy solution
e.node_list = unique(e.tr_exp);
e.map = map(e.node_list+1,:);
n.se = sum(e.node_list>n.u);

% calculate enthalpy cost in enthalpy solution
n.s = n.se;
[e.cost_enthalpy, ~] = fincalc_enthalpy(e.tr_exp,n,params,e.c_comp,mdpts,pairs);

%% Calculate length costs

x = (map(e.tr_exp(:,1)+1,1)-map(e.tr_exp(:,2)+1,1)).^2;
y = (map(e.tr_exp(:,1)+1,2)-map(e.tr_exp(:,2)+1,2)).^2;
e.cost_length = sum(sqrt(x+y),'all');

x = (map(l.tr_exp(:,1)+1,1)-map(l.tr_exp(:,2)+1,1)).^2;
y = (map(l.tr_exp(:,1)+1,2)-map(l.tr_exp(:,2)+1,2)).^2;
l.cost_length = sum(sqrt(x+y),'all');

%% Create graphs

% renumber split nodes
split_nodes = unique(sort(l.node_list(l.node_list>n.u)));
l.tr_exp_renum = l.tr_exp;
for node_type = 1:numel(split_nodes)
    l.tr_exp_renum(l.tr_exp==split_nodes(node_type)) = node_type+n.u;
end
% create graph
l.G = digraph(l.tr_exp_renum(:,1)+1,l.tr_exp_renum(:,2)+1,[],string(unique(l.tr_exp)));

% reunumber split nodes
split_nodes = unique(sort(e.node_list(e.node_list>n.u)));
e.tr_exp_renum = e.tr_exp;
for node_type = 1:numel(split_nodes)
    e.tr_exp_renum(e.tr_exp==split_nodes(node_type)) = node_type+n.u;
end
% create graph
Ge = digraph(e.tr_exp_renum(:,1)+1,e.tr_exp_renum(:,2)+1,[],string(unique(e.tr_exp)));

%% Plot parameters

mkr = {'diamond','o','square'};
clr = [[0.6350 0.0780 0.1840];[0 0.4470 0.7410];[0.4660 0.6740 0.1880]];

%% Plot length minimized

% create figure
figure('Name','Length')
set(gcf,'Position',[801,1325,523,229])
hold on

% node types
idx_nodes = [1,repelem(3,n.u),repelem(2,n.sl)];

% dummy plot for legend
for node_type =1:3
    plot(nan, nan,'Marker',mkr(node_type),'MarkerFaceColor', clr(node_type,:),'MarkerEdgeColor', clr(node_type,:),'LineStyle','none')
end
L = legend('Plant\quad', 'Node\quad', 'User','AutoUpdate','off','FontSize',11,'Location','northeast','interpreter','latex');
L.ItemTokenSize(1) = 7;

% plot results
plot(l.G, 'marker', mkr(idx_nodes),'XData',l.map(:,1),'YData',l.map(:,2), 'NodeColor', clr(idx_nodes,:), 'EdgeColor','k','interpreter','latex','NodeFontSize',12,'Linewidth',1,'MarkerSize',7,'ArrowPosition',.7)

% plot settings
xlim([-800 50])
ylim([-150 250])
xlabel('(m)')
ylabel('(m)')
ax = gca;
ax.GridLineWidth = .85;
ax.MinorGridLineWidth = 0.5;
box on; grid on; grid minor; hold off

%% Plot enthalpy minimized

% create figure
figure('Name','Enthalpy')
set(gcf,'Position',[801,1325,523,229])
hold on

% plot results
idx_nodes = [1,repelem(3,n.u),repelem(2,n.se)];
plot(Ge, 'marker', mkr(idx_nodes),'XData',e.map(:,1),'YData',e.map(:,2), 'NodeColor', clr(idx_nodes,:), 'EdgeColor','k','interpreter','latex','NodeFontSize',12,'Linewidth',1,'MarkerSize',7,'ArrowPosition',.7)

% plot settings
xlim([-800 50])
ylim([-150 250])
xlabel('(m)')
ylabel('(m)')
ax = gca;
ax.GridLineWidth = .85;
ax.MinorGridLineWidth = 0.5;
box on; grid on; grid minor; hold off

end