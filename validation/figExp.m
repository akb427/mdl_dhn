function figExp(d,nsplit)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

load("C:\Users\akb42\OneDrive - The Ohio State University\DistrictHeatingNetwork\Data\Setpoints\LSplan.mat")

Tset_ThM1 = [zeros(1,15922) 28*ones(1,15873) zeros(1,15441) 28*ones(1,15927)];
Tset_ThM2 = [28*ones(1,3453) zeros(1,14234) 28*ones(1,17023) zeros(1,14572) 28*ones(1,13881)];
LS.T_ThM1(1,end) = 28;
LS.T_ThM2(1,end) = 28;
d.Time = d.Time/(60*60);
ln = 1;
figure('Name','Experiment')
set(gcf,'Position',[320.3333333333333,230.3333333333333,461,320])
hold on
stairs(d.Time, Tset_ThM1,'Color',[0 0.4470 0.7410],'linewidth', ln)
stairs(d.Time, Tset_ThM2,':','Color',[0.8500 0.3250 0.0980],'linewidth', ln)
plot(d.Time, d.T_HeaterOut,'--','Color',[0.6350 0.0780 0.1840],'linewidth', ln)
plot([LS.t(1,:) LS.t(2,:)+LS.t(1,end)]/(60*60), [LS.T_amb(1,:) LS.T_amb(2,:)],'-.','Color',[0.4940 0.1840 0.5560],'linewidth', ln)
%stairs([LS.t(1,:) LS.t(2,:)+LS.t(1,end)]/(60*60), [LS.T_ThM1(1,:) LS.T_ThM1(2,:)],'Color',[0 0.4470 0.7410],'linewidth', ln)
%stairs([LS.t(1,:) LS.t(2,:)+LS.t(1,end)]/(60*60), [LS.T_ThM2(1,:) LS.T_ThM2(2,:)],'Color',[0.8500 0.3250 0.0980],'linewidth', ln)
%plot(d.Time,d.T_ThM1)
%plot(d.Time,d.T_ThM2)
xline(d.Time(nsplit), 'k','linewidth', ln)
ylabel('Temperature (C)')
legend('$T_{b}^{\{1\}}$ Set', '$T_{b}^{\{2\}} Set$','$T_{s}$', '$T_{amb\ sim}$','location','best','autoupdate','off')
yyaxis right
plot(d.Time, d.M_Heater,'linewidth', ln)
ylabel('Initial Mass Flow Rate ($kg/s$)')
ylim([0 .1])
xlim([0 d.Time(end)])
xlabel('Time (hr)')

box on; grid on; hold off

end