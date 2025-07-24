function figPID_art(d,y,m)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

n = size(d,1);
simt = (1:n)/(60*60);
d.Time = d.Time/(60*60);
y_act = [d.T_Supply2 d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2 d.T_PumpIn d.T_ThM1 d.T_ThM2];

figure('Name', 'Compare Data')
tiledlayout(1,2,'TileSpacing','compact')

nexttile
hold on
plot(d.Time, y(:,1:7), 'Linewidth',2)
plot(d.Time, y(:,8:11), '--', 'Linewidth',2)
plot(d.Time, y(:,12:13),':','linewidth',2)
plot(d.Time, d.T_HeaterOut,'--k' ,'Linewidth',2);
plot(d.Time, d.T_Ambient, 'k','linewidth',2)
ylim([18 40])
title('Simulation')
box on; grid on; hold off

nexttile
hold on
plot(d.Time, y_act(:,1:7), 'Linewidth',2)
plot(d.Time, y_act(:,8:11), '--', 'Linewidth',2)
plot(d.Time, y_act(:,12:13),':','linewidth',2)
plot(d.Time, d.T_HeaterOut,'--k' ,'Linewidth',2);
plot(d.Time, d.T_Ambient, 'k','linewidth',2)
ylim([18 40])
box on; grid on; hold off
legend('F1','ByIn1','HxIn1','HxOut1','ByOut1','ByIn2','HxIn2','HxOut2','ByOut2','LoopsOut','R1','ThM1','ThM2','Heater','Ambient')
title('Actual')
box on; grid on; hold off

%% Thermal Masses

fn = 10;
figure('Name','ThM')
set(gcf,'Position',[320.3333333333333,230.3333333333333,461,320])
t = tiledlayout(2,1,'TileSpacing','compact');
ylabel(t,'Temperature (C)','FontSize',fn)%,'Interpreter','latex')

nexttile
hold on
plot(d.Time, y_act(:,12),'Linewidth',1)
plot(simt, y(:,12),':','linewidth',1)
xlim([0 simt(end)])
ylim([18 29])
set(gca,'FontSize',fn)
legend('Act','Sim','location','southeast')
title('Building 1')
box on; grid on; hold off

nexttile
hold on
plot(d.Time, y_act(:,13),'Linewidth',1)
plot(simt, y(:,13),':','linewidth',1)
xlim([0 simt(end)])
ylim([18 29])
set(gca,'FontSize',fn)
xlabel('Time (hr)','FontSize',fn)
title('Building 2')
box on; grid on; hold off


%% Pipes
fn = 10;
figure('Name','Pipes')
t = tiledlayout(3,1,'TileSpacing','compact');
set(gcf,'Position',[320.3333333333333,230.3333333333333,461,420])
ylabel(t,'Temperature (C)','FontSize',fn)%,'Interpreter','latex')

nexttile
hold on
plot(d.Time, y_act(:,10),'Linewidth',1)
plot(simt, y(:,10),':','Linewidth',1)
xlim([0 simt(end)])
ylim([34 40])
set(gca,'FontSize',fn)
legend('Act','Sim','location','southwest')
title('Return Temperature')
box on; grid on; hold off

nexttile
hold on
plot(d.Time, y_act(:,5),'Linewidth',1)
plot(simt, y(:,5),':','Linewidth',1)
xlim([0 simt(end)])
ylim([34 40])
set(gca,'FontSize',fn)
title('$U1R$ Inlet Temperature')
box on; grid on; hold off

nexttile
hold on
plot(d.Time, y_act(:,9),'Linewidth',1)
plot(simt, y(:,9),':','Linewidth',1)
xlim([0 simt(end)])
ylim([34 40])
xlabel('Time (hr)','FontSize',fn)%, 'Interpreter','latex')
set(gca,'FontSize',fn)
title('$U2R$ Inlet Temperature')
box on; grid on; hold off

%% Mass flow
figure('Name','Mdot')
set(gcf,'Position',[320.3333333333333,230.3333333333333,461,320])
t = tiledlayout(2,1,'TileSpacing','compact');
%ylabel(t,'Mass Flow Rate ($kg/s$)','FontSize',fn,'Interpreter','latex')
ylabel(t,'Mass Flow Rate (kg/s)','FontSize',fn)

nexttile
hold on
plot(d.Time, (d.M_Heater-d.M_Supply2)-d.M_By1,'linewidth',1)
plot(simt, m(:,3),':','linewidth',1)
xlim([0 simt(end)])
ylim([-.002 0.03])
set(gca,'FontSize',fn)
legend('Act','Sim','location','northwest')
title('Building 1')
box on; grid on; hold off

nexttile
hold on
plot(d.Time, (d.M_Supply2-d.M_By2),'linewidth',1)
plot(simt, m(:,9),':','linewidth',1)
xlim([0 simt(end)])
xlabel('Time (hr)','FontSize',fn)
ylim([-.002 0.03])
set(gca,'FontSize',fn)
title('Building 2')
box on; grid on; hold off

%%
% fn = 12;
% figure('Name','ThM')
% set(gcf,'Position',[1925,110,434,312])
% hold on
% plot(simt, y(:,12:13),'linewidth',2)
% plot(d.Time,d.T_Ambient,'linewidth',2)
% plot(d.Time, d.T_HeaterOut,'Linewidth',2)
% ylabel('Temperature (C)','FontSize',fn)
% ylim([20 40])
% yyaxis right
% ylabel('Mass Flow Rate (kg/s)','FontSize',fn)
% ylim([0 .1])
% plot(d.Time, d.M_Heater, 'Linewidth',2)
% legend('Building 1', 'Building 2','Ambient','Supply','Mass Flow','location','best','FontSize',fn)
% xlabel('Time (hr)','FontSize',fn)
% xlim([0 simt(end)])
% set(gca,'FontSize',fn)
% xlim([2e4, 3e4])
% box on; grid on; hold off
end