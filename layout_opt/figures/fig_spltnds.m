function fig_spltnds
%FIG_SPLTNDS  Illustrative plot of split node types.
%
%   [out1, out2] = FUNCTION_NAME(in1, in2)
%
%   DESCRIPTION: 
%   Plots a simple node (of only users), complex (of only
%   midpoints), and mixed (of both users and midpoints) for illustrative
%   purposes.

%% Make Sample Graphs

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

%% Plot three sample node types

mkr = {'diamond','o','square'};
clr = [[0.6350 0.0780 0.1840];[0 0.4470 0.7410];[0.4660 0.6740 0.1880]];

figure('Name','Split Nodes')
set(gcf,'Position',[2303,583,457,173])

tiledlayout(1,3,'TileSpacing','compact','Padding','compact')

for idx_plot = 1:3
    nexttile
    if idx_plot == 3
        hold on
        for idx_node = 1:3
            plot(nan, nan,'Marker',mkr(idx_node),'MarkerFaceColor', clr(idx_node,:),'MarkerEdgeColor', clr(idx_node,:),'LineStyle','none','MarkerSize',7)
        end
        L = legend('Plant\quad', 'Node\quad', 'User','AutoUpdate','off','FontSize',11,'Orientation','horizontal');
        L.ItemTokenSize(1) = 9;
        L.Layout.Tile = 'South';
    end
    hold on
    plot(G{idx_plot}, 'Xdata',x{idx_plot},'Ydata',y{idx_plot},'NodeLabel',lbl{idx_plot} ,'marker', mkr(idx{idx_plot}), 'NodeColor', clr(idx{idx_plot},:), 'EdgeColor','k','interpreter','latex','NodeFontSize',12,'Linewidth',1,'MarkerSize',7)
    box on
    set(gca,'xtick',[],'ytick',[])
    xlabel(name{idx_plot},'FontSize',12,'FontWeight','bold')
    hold off
end


end

