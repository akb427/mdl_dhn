function fig_spltnds
%FIG_SPLTNDS Summary of this function goes here
%   Detailed explanation goes here

%% Make Graphs
G{1} = graph([1 6 6 6 6],[6 2 3 4 5]);
G{2} = graph([1 8 8 6 6 7 7],[8 6 7 2 3 4 5]);
G{3} = graph([1 7 6 6 7 7],[7 6 2 3 4 5]);

xi = [0 -2 -1 1 2];
x{1} = [xi 0];
x{2} = [xi -1.5 1.5 0];
x{3} = [xi -1.5 .5];

yi = [-1 -2 -4 -4 -2];
y{1} = [yi -3];
y{2} = [yi -3 -3 -3];
y{3} = [yi -3 -3];

idxi = [1 3 3 3 3];
idx{1} = [idxi 2];
idx{2} = [idxi 2 2 2];
idx{3} = [idxi 2 2];

lbl{1} = ["",string(1:4),""];
lbl{2} = ["",string(1:4),"","",""];
lbl{3} = ["",string(1:4),"",""];
name{1} = 'Simple';
name{2} = 'Complex';
name{3} = 'Mixed';
%% Plot

mkr = {'diamond','o','square'};
clr = [[0.6350 0.0780 0.1840];[0 0.4470 0.7410];[0.4660 0.6740 0.1880]];

figure('Name','Split Nodes')
set(gcf,'Position',[2303,583,457,173])

tiledlayout(1,3,'TileSpacing','compact','Padding','compact')

for i = 1:3
    nexttile
    if i==3
        hold on
        for j =1:3
            plot(nan, nan,'Marker',mkr(j),'MarkerFaceColor', clr(j,:),'MarkerEdgeColor', clr(j,:),'LineStyle','none','MarkerSize',7)
        end
        L = legend('Plant\quad', 'Node\quad', 'User','AutoUpdate','off','FontSize',11,'Orientation','horizontal');
        L.ItemTokenSize(1) = 9;
        L.Layout.Tile = 'South';
    end
    hold on
    plot(G{i}, 'Xdata',x{i},'Ydata',y{i},'NodeLabel',lbl{i} ,'marker', mkr(idx{i}), 'NodeColor', clr(idx{i},:), 'EdgeColor','k','interpreter','latex','NodeFontSize',12,'Linewidth',1,'MarkerSize',7)
    box on
    set(gca,'xtick',[],'ytick',[])
    xlabel(name{i},'FontSize',12,'FontWeight','bold')
    hold off
end

%%


%L.Units = 'pixel';
%L.Position(3) = 260;


end

