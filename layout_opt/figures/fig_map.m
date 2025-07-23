function  fig_map(map,n)
%FIG_MAP  Plot the points in map.
%
%   FIG_MAP(map,n)
%
%   DESCRIPTION:
%   Creates a graph element from the points in map, assuming the plant is
%   at (0,0). Plots the points in the graph with no edges, at their
%   geographic locations.
%
%   INPUTS:
%       map - Matrix of X and Y coordinates of points
%       n   - Structure of system sizes

%% Setup graph
map = [0 0; map];

mkr = {'diamond','square'};
idx = [1,repelem(2,n.u)];
G = digraph((0:n.u-1)+1,(1:n.u)+1,[],string(0:n.u));
clr = [[0.6350 0.0780 0.1840];[0.4660 0.6740 0.1880]];

%% Plot Map

figure('Name','Map')
set(gcf,'Position',[801,1325,523,229])
hold on

% add dummy points for legend
for node_type =1:2
    plot(nan, nan,'Marker',mkr(node_type),'MarkerFaceColor', clr(node_type,:),'MarkerEdgeColor', clr(node_type,:),'LineStyle','none')
end
L = legend('Plant\quad', 'User','AutoUpdate','off','FontSize',11,'Location','northeast','interpreter','latex');
L.ItemTokenSize(1) = 7;

% plot graph
plot(G, 'marker', mkr(idx),'XData',map(1:n.u+1,1),'YData',map(1:n.u+1,2), 'NodeColor', clr(idx,:), 'EdgeColor','none','interpreter','latex','NodeFontSize',12,'Linewidth',1,'MarkerSize',7)

% update plot settings
xlim([-800 50])
ylim([-150 250])
xlabel('(m)')
ylabel('(m)')
ax = gca;
box on; grid on; grid minor
ax.GridLineWidth = .85;
ax.MinorGridLineWidth = 0.5;
hold off

end