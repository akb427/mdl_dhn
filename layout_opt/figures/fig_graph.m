function  fig_graph(G,n)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%%
figure('Name','Graph')
set(gcf,'Position',[2240,90,260,270])
hold on
mkr = {'diamond','o','square'};
idx = [1,repelem(3,n.u),repelem(2,n.s)];
clr = [[0.6350 0.0780 0.1840];[0 0.4470 0.7410];[0.4660 0.6740 0.1880]];
for i =1:3
    plot(nan, nan,'Marker',mkr(i),'MarkerFaceColor', clr(i,:),'MarkerEdgeColor', clr(i,:),'LineStyle','none')
end
L = legend('Plant\quad', 'Node\quad', 'User','AutoUpdate','off','FontSize',11,'Orientation','horizontal','Location','southoutside');
L.ItemTokenSize(1) = 7;
%L.Units = 'pixel';
%L.Position(3) = 260;
plot(G, 'marker', mkr(idx), 'NodeColor', clr(idx,:), 'EdgeColor','k','interpreter','latex','layout','layered','NodeFontSize',12,'Linewidth',1,'MarkerSize',7,'ArrowPosition',.7)
set(gca,'xtick',[],'ytick',[])
box on
hold off
end