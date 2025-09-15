function figPID_ThM(d,d_act,d_sim,params_plot)
%FIGPID_THM  Compare the simulated and actual thermal mass temps.
%
%   FIGPID_THM(d,d_act,d_sim,params_plot)
%
%   DESCRIPTION:
%   Plots either a one pane or two pane figure comparin the thermal mass
%   temperatures between the simulation and the experimental data. Changes
%   the number of panels based on params_plot.num_panel. Works to plot two
%   thermal masses results.
%
%   INPUTS:
%       d           - Table of experimental data.
%       d_act       - Matrix of experimental data.
%       d_sim       - Matrix of simulation data.
%       params_plot - Structure of plotting parameters.

%% Create figure

figure('Name','ThM')
set(gcf,Position=params_plot.pos)

%% Case specific

switch params_plot.num_panel
    % 2 pane Styling
    case 2
        t = tiledlayout(2,1,TileSpacing='compact');
        ylabel(t,'Temperature (C)','FontSize',params_plot.fn)
        
        nexttile
        hold on
        plot(d.Time_hr, d_act(:,12),Linewidth=params_plot.ln,Color=params_plot.clr(1,:))
        plot(params_plot.simt, d_sim(:,12),':',LineWidth=params_plot.ln,Color=params_plot.clr(2,:))
        xlim([0 params_plot.simt(end)])
        ylim(params_plot.ylim)
        set(gca,'FontSize',params_plot.fn)
        legend('Act','Sim','location','southeast')
        title('Building 1')
        box on; grid on; hold off
        
        nexttile
        hold on
        plot(d.Time_hr, d_act(:,13),LineWidth=params_plot.ln)
        plot(params_plot.simt, d_sim(:,13),':',LineWidth=params_plot.ln)
        xlim([0 params_plot.simt(end)])
        ylim(params_plot.ylim)
        set(gca,FontSize=params_plot.fn)
        xlabel('Time (hr)','FontSize',params_plot.fn)
        title('Building 2')
        box on; grid on; hold off
    % 1 pane Styling
    case 1
        hold on
        plot(1:size(d,1), d_sim(:,12:13),LineWidth=params_plot.ln)
        plot(d.Time, d_act(:,12:13),'--',LineWidth=params_plot.ln)
        legend('Sim $T_{ThM1}$', 'Sim $T_{ThM2}$', 'Act $T_{ThM1}$','Act $T_{ThM1}$','location','southeast',FontSize=params_plot.fn)
        ylabel('Temperature (C)',FontSize=params_plot.fn)
        xlabel('Time (s)',FontSize=params_plot.fn)
        xlim([1 size(d,1)])
        set(gca,FontSize=params_plot.fn)
        box on; grid on; hold off
end

end