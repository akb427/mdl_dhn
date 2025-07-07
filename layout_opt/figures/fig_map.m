function  fig_map(map,n)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%%

figure('Name','Map')

hold on
plot(map(1:n.u,1),map(1:n.u,2),'square','MarkerSize',8,'MarkerFaceColor', [0.4660 0.6740 0.1880],'MarkerEdgeColor', [0.4660 0.6740 0.1880])
plot(0,0,'diamond','MarkerSize',8,'MarkerFaceColor', [0.6350 0.0780 0.1840],'MarkerEdgeColor', [0.6350 0.0780 0.1840])
legend('Users','Plant')
xlim([-800 50])
ylim([-150 250])
xlabel('(m)')
ylabel('(m)')
ax = gca;
box on; grid on; grid minor
ax.GridLineWidth = .85;
ax.MinorGridLineWidth = 0.5;
hold off

%% Map2
map = [0 0; map];

figure('Name','Map2')
set(gcf,'Position',[801,1325,523,229])

hold on
mkr = {'diamond','square'};
idx = [1,repelem(2,n.u)];
G = digraph((0:n.u-1)+1,(1:n.u)+1,[],string(0:n.u));
clr = [[0.6350 0.0780 0.1840];[0.4660 0.6740 0.1880]];

for i =1:2
    plot(nan, nan,'Marker',mkr(i),'MarkerFaceColor', clr(i,:),'MarkerEdgeColor', clr(i,:),'LineStyle','none')
end
L = legend('Plant\quad', 'User','AutoUpdate','off','FontSize',11,'Location','northeast','interpreter','latex');
L.ItemTokenSize(1) = 7;

plot(G, 'marker', mkr(idx),'XData',map(1:n.u+1,1),'YData',map(1:n.u+1,2), 'NodeColor', clr(idx,:), 'EdgeColor','none','interpreter','latex','NodeFontSize',12,'Linewidth',1,'MarkerSize',7,'ArrowPosition',.7)

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