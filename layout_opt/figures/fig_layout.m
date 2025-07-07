function [trl_ce, trl_cl, tre_ce, tre_cl]=fig_layout(map,tre,trl,mdpts,n,pairs,tc,params)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%%

addpath("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Project Codes\Layout Optimization")
[trl,~] = expand_tree(trl,mdpts,n,0);
[tre,~] = expand_tree(tre,mdpts,n,0);
map = [0 0; map];

idx = unique(trl);
n.sl = sum(idx>n.u);
n.s =n.sl;
mapl = map(idx+1,:);
[trl_ce, ~] = fincalc_enthalpy(trl,n,params,tc,mdpts,pairs);

idx = unique(tre);
n.se = sum(idx>n.u);
n.s = n.se;
mape = map(idx+1,:);
[tre_ce, ~] = fincalc_enthalpy(tre,n,params,tc,mdpts,pairs);

prrd_e = (trl_ce-tre_ce)/trl_ce

x = (map(tre(:,1)+1,1)-map(tre(:,2)+1,1)).^2;
y = (map(tre(:,1)+1,2)-map(tre(:,2)+1,2)).^2;
tre_cl = sum(sqrt(x+y),'all');

x = (map(trl(:,1)+1,1)-map(trl(:,2)+1,1)).^2;
y = (map(trl(:,1)+1,2)-map(trl(:,2)+1,2)).^2;
trl_cl = sum(sqrt(x+y),'all');

idx = unique(sort(trl(trl>n.u)));
trln = trl;
for i = 1:numel(idx)
    trln(trl==idx(i)) = i+n.u;
end

Ge = digraph(tre(:,1)+1,tre(:,2)+1,[],string(unique(tre)));
Gl = digraph(trln(:,1)+1,trln(:,2)+1,[],string(unique(trl)));


%% Length minimized
figure('Name','Length')
tiledlayout(2,1)
set(gcf,'Position',[801,1325,523,229])
hold on

mkr = {'diamond','o','square'};
idx = [1,repelem(3,n.u),repelem(2,n.sl)];
clr = [[0.6350 0.0780 0.1840];[0 0.4470 0.7410];[0.4660 0.6740 0.1880]];

for i =1:3
    plot(nan, nan,'Marker',mkr(i),'MarkerFaceColor', clr(i,:),'MarkerEdgeColor', clr(i,:),'LineStyle','none')
end
L = legend('Plant\quad', 'Node\quad', 'User','AutoUpdate','off','FontSize',11,'Location','northeast','interpreter','latex');
L.ItemTokenSize(1) = 7;

plot(Gl, 'marker', mkr(idx),'XData',mapl(:,1),'YData',mapl(:,2), 'NodeColor', clr(idx,:), 'EdgeColor','k','interpreter','latex','NodeFontSize',12,'Linewidth',1,'MarkerSize',7,'ArrowPosition',.7)

% textString = {['Length Cost =', num2str(trl_cl,'%.2e'), ' m'],['Loss Cost = ' num2str(trl_ce,'%.2e') ' W']};
% tl = annotation('textbox');
% tl.Interpreter = 'Latex';
% tl.String = textString;
% tl.Position = [0.137508028259473,0.137954033745666,0.166167487681639,0.095379299587674];
% tl.FitBoxToText = 'on';
% tl.BackgroundColor = 'w';


%title('Length Minimized Layout')
xlim([-800 50])
ylim([-150 250])
xlabel('(m)')
ylabel('(m)')
ax = gca;
box on; grid on; grid minor
ax.GridLineWidth = .85;
ax.MinorGridLineWidth = 0.5;
hold off

%% Enthalpy minimized
figure('Name','Enthalpy')
tiledlayout(2,1)
set(gcf,'Position',[801,1325,523,229])
hold on

idx = [1,repelem(3,n.u),repelem(2,n.se)];
plot(Ge, 'marker', mkr(idx),'XData',mape(:,1),'YData',mape(:,2), 'NodeColor', clr(idx,:), 'EdgeColor','k','interpreter','latex','NodeFontSize',12,'Linewidth',1,'MarkerSize',7,'ArrowPosition',.7)

% textString = {['Length Cost = ' num2str(tre_cl,'%.2e') ' m'],['Loss Cost = ' num2str(tre_ce,'%.2e') ' W']};
% te = annotation('textbox');
% te.Interpreter = 'Latex';
% te.Position = [0.589017341040462,0.137954033745666,0.166167487681639,0.095379299587674];
% te.FitBoxToText = 'on';
% te.String = textString;
% te.BackgroundColor = 'w';

%title('Loss Minimized Layout')
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