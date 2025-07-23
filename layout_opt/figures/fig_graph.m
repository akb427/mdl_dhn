function  fig_graph(G,n)
%FIG_GRAPH  Plots the graph with node types labeled.
%
%   FIG_GRAPH(G,n)
%
%   DESCRIPTION:
%   Plots the graph with node types labeled. Assumes node 1 is the plant,
%   then the next set are all users, then the split nodes are all at the
%   end. 
%
%   INPUTS:
%       G   - Graph to be plotted.
%       n   - Structure of network sizes.

%% Plot Parameters

mkr = {'diamond','o','square'};
idx = [1,repelem(3,n.u),repelem(2,n.s)];
clr = [[0.6350 0.0780 0.1840];[0 0.4470 0.7410];[0.4660 0.6740 0.1880]];

%% Plot Graph
figure('Name','Graph')
set(gcf,'Position',[2240,90,260,270])
hold on

% dummy plot for legend of node types
for idx_style =1:3
    plot(nan, nan,'Marker',mkr(idx_style),'MarkerFaceColor', clr(idx_style,:),'MarkerEdgeColor', clr(idx_style,:),'LineStyle','none')
end
L = legend('Plant\quad', 'Node\quad', 'User','AutoUpdate','off','FontSize',11,'Orientation','horizontal','Location','southoutside');
L.ItemTokenSize(1) = 7;

% plot graph
plot(G, 'marker', mkr(idx), 'NodeColor', clr(idx,:), 'EdgeColor','k','interpreter','latex','layout','layered','NodeFontSize',12,'Linewidth',1,'MarkerSize',7,'ArrowPosition',.7)

% plot settings
set(gca,'xtick',[],'ytick',[])
box on
hold off

end