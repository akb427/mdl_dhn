function figPID_all(d,d_act,d_sim,params_plot)
%FIGPID_ALL  Plot all simulation outputs and corresponding sets from the experimental data.
%
%   figPID_all(d_act,d_sim,params_plot)
%
%   DESCRIPTION:
%   Takes the experimental data, sorts it to match the order of the
%   simulation results and plots both in a side by side tiled plot.
%
%   INPUTS:
%       d           - Table of experimental data.
%       d_act       - Matrix of experimental data.
%       d_sim       - Matrix of simulation data.
%       params_plot - Structure of plotting parameters.

%% Setup figure

figure('Name', 'Compare Data')
set(gcf,Position=params_plot.pos)
tiledlayout(1,2,'TileSpacing','compact')

%% Simulation results

nexttile
hold on
plot_sets(d,d_sim)
ylim(params_plot.ylim)
xlim([0 max(d.Time_hr)])
title('Simulation')
box on; grid on; hold off

%% Experimental results
nexttile
hold on
plot_sets(d, d_act)
ylim(params_plot.ylim)
xlim([0 max(d.Time_hr)])
box on; grid on; hold off
legend('F1','ByIn1','HxIn1','HxOut1','ByOut1','ByIn2','HxIn2','HxOut2',...
    'ByOut2','LoopsOut','R1','ThM1','ThM2','Heater','Ambient')
title('Experimental')
box on; grid on; hold off

end

function plot_sets(d,y_i)
    plot(d.Time_hr, y_i(:,1:7), 'Linewidth',2)
    plot(d.Time_hr, y_i(:,8:11), '--', 'Linewidth',2)
    plot(d.Time_hr, y_i(:,12:13),':','linewidth',2)
    plot(d.Time_hr, d.T_HeaterOut,'--k' ,'Linewidth',2);
    plot(d.Time_hr, d.T_Ambient, 'k','linewidth',2)
end