function figPID_can(d,y,m)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

n = size(d,1);
y_act = [d.T_Supply2 d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2 d.T_PumpIn d.T_ThM1 d.T_ThM2];



figure('Name','Mdot')
set(gcf,'Position',[733.6666666666666,257,434,312])
hold on
%plot(d.Time, d.M_Heater)
plot(1:n, m(:,[3 9]),'linewidth',1.5)
plot(d.Time, [(d.M_Heater-d.M_Supply2)-d.M_By1 d.M_Supply2-d.M_By2],'--','linewidth',1.5)
legend('Sim $\dot{m}_{ThM1}$', 'Sim $\dot{m}_{ThM2}$','Act $\dot{m}_{ThM1}$' ,'Act $\dot{m}_{ThM2}$', 'FontSize',fn)
ylabel('Mass Flow Rate ($\frac{kg}{s}$)','FontSize',fn)
xlabel('Time (s)','FontSize',fn)
xlim([1.5e4, 2.5e4])
ylim([-.002 0.03])
set(gca,'FontSize',fn)
box on; grid on; hold off

% fn = 12;
% figure('Name','ThM')
% set(gcf,'Position',[1925,110,434,312])
% hold on
% plot(1:n, y(:,12:13),'linewidth',2)
% plot(d.Time,d.T_Ambient,'linewidth',2)
% plot(d.Time, d.T_HeaterOut,'Linewidth',2)
% ylabel('Temperature (C)','FontSize',fn)
% ylim([20 40])
% yyaxis right
% ylabel('Mass Flow Rate (kg/s)','FontSize',fn)
% ylim([0 .1])
% plot(d.Time, d.M_Heater, 'Linewidth',2)
% legend('Building 1', 'Building 2','Ambient','Supply','Mass Flow','location','best','FontSize',fn)
% xlabel('Time (s)','FontSize',fn)
% xlim([1 n])
% set(gca,'FontSize',fn)
% xlim([2e4, 3e4])
% box on; grid on; hold off
end