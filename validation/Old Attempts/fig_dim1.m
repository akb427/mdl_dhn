function fig_dim(d, d_p1, d_p2)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
%%
T_pipes = [d.T_PumpIn d.T_Heater d.T_HeaterOut d.T_ByIn1 d.T_HxIn1 d.T_HxOut1 d.T_ByOut1 d.T_Supply2 d.T_ByIn2 d.T_HxIn2 d.T_HxOut2 d.T_ByOut2 d.T_Return2];

figure('Name', 'Temp')
hold on
plot(d.Time, T_pipes(:,1:7), '--','Linewidth',2)
plot(d.Time, T_pipes(:,8:end), 'linewidth',2)
plot(d.Time, d.T_Ambient, 'k','linewidth',2)
plot(d.Time, d.T_ThM1,':', d.Time, d.T_ThM2, ':','linewidth',2)
legend('Pump In', 'Heater', 'Heater Out', 'By In 1', 'Hx In 1','Hx Out1' ,'By Out 1', 'Supply 2', 'By In 2', 'Hx In 2', 'Hx Out 2', 'By Out 2', 'Return','Ambient','ThM1','ThM2')
box on; grid on; hold off

M_tot = [d.M_Heater d.M_Supply2 d.M_By1 d.M_By2];

figure('Name', 'Mdot')
hold on
plot(d.Time, M_tot, 'linewidth',2)

yyaxis right
plot(d.Time, [d.V_ThM1 d.V_ThM2],'linewidth',.5)
legend('Heater', 'Supply', 'By1', 'By2', 'V1','V2')
box on; grid on; hold off


P_tot = [d.P_PumpIn, d.P_HeaterIn, d.P_HeaterOut, d.P_ByIn1, d.P_HxIn1, d.P_HxOut1, d.P_ByIn2, d.P_HxIn2, d.P_HxOut2, d.P_Return2];
figure('Name','Pressure')
hold on
plot(d.Time, P_tot(:,1:7), '--','Linewidth',2)
plot(d.Time, P_tot(:,7:end), 'linewidth',2)
legend('Pump In', 'Heater In', 'Heater Out', 'By In 1', 'Hx In 1','Hx Out1', 'By In 2', 'Hx In 2', 'Hx Out 2', 'Return')
box on; grid on; hold off

figure('Name','Peltier Power')
hold on
plot(d_p1.Time, d_p1.Power*.79,d_p2.Time, d_p2.Power*.79,'linewidth',2)
legend('1','2')
box on; grid on; hold off

%% Lab Scale Plots
figure('Name','Lab Scale')
subplot(1,2,1)
hold on
plot(d.Time,d.T_Ambient)
plot(d.Time,d.T_HeaterOut)
plot(d.Time,d.T_ThM1)
ylabel('Temperature [$^{\circ}$C]')
ylim([15 30])

yyaxis right
ylim([0 100])
plot(d_p1.Time,d_p1.Power)
ylabel('Power [\%]')

xlim([0 63197])
xlabel('Time [s]')
subtitle('ThM1')
box on; grid on; hold off

subplot(1,2,2)
hold on
plot(d.Time,d.T_Ambient)
plot(d.Time,d.T_HeaterOut)
plot(d.Time,d.T_ThM2)
ylabel('Temperature [$^{\circ}$C]')
ylim([15 30])

yyaxis right
plot(d_p2.Time,d_p2.Power)
ylim([0 100])
ylabel('Power [\%]')

legend('Ambient','Supply','ThM','Peltier', 'location', 'southeast')
xlabel('Time [s]')
xlim([0 63197])
subtitle('ThM2')
box on; grid on; hold off

end