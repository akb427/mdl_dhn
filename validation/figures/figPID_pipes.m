function figPID_pipes(d,d_act,d_sim,params_plot)
%FIGPID_PIPES  Compare the simulated and actual key pipe temps.
%
%   FIGPID_PIPES(d,d_act,d_sim,params_plot)
%
%   DESCRIPTION:
%   Plots either a one pane or multi pane figure comparin the pipe
%   temperatures between the simulation and the experimental data. Changes 
%   the number of panels based on params_plot.num_panel. The multi-pane
%   layout plots return, U1R inlet, and U2R inlet temperatures. The single
%   pane layout plots supply and return temperatures only.
%
%   INPUTS:
%       d           - Table of experimental data.
%       d_act       - Matrix of experimental data.
%       d_sim       - Matrix of simulation data.
%       params_plot - Structure of plotting parameters.

%% Create figure

figure('Name','Pipes')
set(gcf,Position=params_plot.pos)

%% Case specific

switch params_plot.num_panel
    % Multi-pane Styling
    case 2
        t = tiledlayout(3,1,'TileSpacing','compact');
        ylabel(t,'Temperature (C)','FontSize',params_plot.fn)
        
        nexttile
        hold on
        plot(d.Time_hr, d_act(:,10),LineWidth=params_plot.ln)
        plot(params_plot.simt, d_sim(:,10),':',LineWidth=params_plot.ln)
        xlim([0 params_plot.simt(end)])
        ylim(params_plot.ylim)
        set(gca,FontSize=params_plot.fn)
        legend('Act','Sim','location','southwest')
        title('Return Temperature')
        box on; grid on; hold off
        
        nexttile
        hold on
        plot(d.Time_hr, d_act(:,5),LineWidth=params_plot.ln)
        plot(params_plot.simt, d_sim(:,5),':',LineWidth=params_plot.ln)
        xlim([0 params_plot.simt(end)])
        ylim([34 40])
        set(gca,'FontSize',params_plot.fn)
        title('$U1R$ Inlet Temperature')
        box on; grid on; hold off
        
        nexttile
        hold on
        plot(d.Time_hr, d_act(:,9),LineWidth=params_plot.ln)
        plot(params_plot.simt, d_sim(:,9),':',LineWidth=params_plot.ln)
        xlim([0 params_plot.simt(end)])
        ylim([34 40])
        xlabel('Time (hr)',FontSize=params_plot.fn)
        set(gca,FontSize=params_plot.fn)
        title('$U2R$ Inlet Temperature')
        box on; grid on; hold off
    % 1 pane Styling
    case 1
        hold on
        plot(d.Time, d.T_HeaterOut,'k' ,LineWidth=params_plot.ln);
        plot(1:size(d,1), d_sim(:,10),LineWidth=params_plot.ln)
        plot(d.Time, d_act(:,10),LineWidth=params_plot.ln)

        legend('$T_{s}$', 'Sim $T_{r}$', 'Act $T_{r}$',FontSize=params_plot.fn)
        ylabel('Temperature (C)',FontSize=params_plot.fn)
        xlabel('Time (s)',FontSize=params_plot.fn)
        xlim([1 size(d,1)])
        set(gca, FontSize=params_plot.fn)
        box on; grid on; hold off
end

end