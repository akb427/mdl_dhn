function [h1,h2]=figPID_ThMcombined(d,d_act,d_sim,m_sim,params_plot)
%FIGPID_THMcombined  Compare the simulated and actual thermal mass variables.
%
%   FIGPID_THMcombined(d,d_act,d_sim,m_sim,params_plot)
%
%   DESCRIPTION:
%   Plots two figures comparing the thermal mass temperatures and mass flow
%   between the simulation and the experimental data. Has temperature on
%   the left axis and mass flow on the right.
%
%   INPUTS:
%       d           - Table of experimental data.
%       d_act       - Matrix of experimental data.
%       d_sim       - Matrix of simulation data.
%       m_sim       - Matix of simulation mass flow rates.
%       params_plot - Structure of plotting parameters.

%% ThM 1

h1 = figure('Name','ThM1');
set(gcf,Position=params_plot.pos)
        
hold on
% Temperatures
plot(d.Time_hr, d_act(:,12),Linewidth=params_plot.ln,Color=params_plot.clr(1,:))
plot(params_plot.simt, d_sim(:,12),'--',LineWidth=params_plot.ln,Color=params_plot.clr(2,:))
ylabel('Temperature (C)','FontSize',params_plot.fn)
ylim(params_plot.ylim{1})

% Mass Flow Rates
yyaxis right
plot(d.Time_hr, (d.M_Heater-d.M_Supply2)-d.M_By1,LineWidth=params_plot.ln,Color=params_plot.clr(6,:))
plot(params_plot.simt, m_sim(:,3),'--',LineWidth=params_plot.ln,Color=params_plot.clr(3,:))
ylabel('Mass Flow Rate (kg/s)','FontSize',params_plot.fn)
ylim(params_plot.ylim{2})

% Overall
xlim([0 params_plot.simt(end)])
xlabel('Time (hr)',FontSize=params_plot.fn)
set(gca,'FontSize',params_plot.fn)
set(gca,'YColor','k');
legend('$T_{act}$','$T_{sim}$','$\dot{m}_{act}$','$\dot{m}_{sim}$',Position=params_plot.pos_leg)
box on; grid on; hold off

%% ThM 2

h2 = figure('Name','ThM2');
set(gcf,Position=params_plot.pos)
        
hold on
% Temperatures
plot(d.Time_hr, d_act(:,13),Linewidth=params_plot.ln,Color=params_plot.clr(1,:))
plot(params_plot.simt, d_sim(:,13),'--',LineWidth=params_plot.ln,Color=params_plot.clr(2,:))
ylabel('Temperature (C)','FontSize',params_plot.fn)
ylim(params_plot.ylim{1})

% Mass Flow Rates
yyaxis right
plot(d.Time_hr, (d.M_Supply2-d.M_By2),LineWidth=params_plot.ln,Color=params_plot.clr(6,:))
plot(params_plot.simt, m_sim(:,9),'--',LineWidth=params_plot.ln,Color=params_plot.clr(3,:))
ylabel('Mass Flow Rate (kg/s)','FontSize',params_plot.fn)
ylim(params_plot.ylim{2})

% Overall
xlim([0 params_plot.simt(end)])
xlabel('Time (hr)',FontSize=params_plot.fn)
set(gca,'FontSize',params_plot.fn)
set(gca,'YColor','k');
legend('$T_{act}$','$T_{sim}$','$\dot{m}_{act}$','$\dot{m}_{sim}$',Position=params_plot.pos_leg)
box on; grid on; hold off

end