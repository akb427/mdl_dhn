function figPID_mdot(d,m_sim,params_plot)
%FIGPID_MDOT  Compare the simulated and actual key mass flow rates.
%
%   FIGPID_MDOT(d,m_sim,params_plot)
%
%   DESCRIPTION:
%   Plots either a one pane or two pane figure comparing the mass flow rate
%   in the thermal masses between the simulation and the experimental data. 
%   Changes the number of panels based on params_plot.num_panel. Works to 
%   plot two thermal masses results.
%
%   INPUTS:
%       d           - Table of experimental data.
%       m_sim       - Matrix of simulated mass flow rates.
%       params_plot - Structure of plotting parameters.

%% Create figure

figure('Name','Mdot')
set(gcf,Position=params_plot.pos)

%% Case specific

switch params_plot.num_panel
    % 2 pane Styling
    case 2
        t = tiledlayout(2,1,'TileSpacing','compact');
        ylabel(t,'Mass Flow Rate (kg/s)','FontSize',params_plot.fn)
        
        nexttile
        hold on
        plot(d.Time_hr, (d.M_Heater-d.M_Supply2)-d.M_By1,LineWidth=params_plot.ln)
        plot(params_plot.simt, m_sim(:,3),':',LineWidth=params_plot.ln)
        xlim([0 params_plot.simt(end)])
        ylim(params_plot.ylim)
        set(gca,'FontSize',params_plot.fn)
        legend('Act','Sim','location','northwest')
        title('Building 1')
        box on; grid on; hold off
        
        nexttile
        hold on
        plot(d.Time_hr, (d.M_Supply2-d.M_By2),LineWidth=params_plot.ln)
        plot(params_plot.simt, m_sim(:,9),':',LineWidth=params_plot.ln)
        xlim([0 params_plot.simt(end)])
        xlabel('Time (hr)',FontSize=params_plot.fn)
        ylim(params_plot.ylim)
        set(gca,'FontSize',params_plot.fn)
        title('Building 2')
        box on; grid on; hold off
    % 1 pane Styling
    case 1
        hold on
        plot(1:size(d,1), m_sim(:,[3 9]),LineWidth=params_plot.ln)
        plot(d.Time, [(d.M_Heater-d.M_Supply2)-d.M_By1 d.M_Supply2-d.M_By2],'--',LineWidth=params_plot.ln)
        legend('Sim $\dot{m}_{ThM1}$', 'Sim $\dot{m}_{ThM2}$','Act $\dot{m}_{ThM1}$' ,'Act $\dot{m}_{ThM2}$', FontSize=params_plot.fn)
        ylabel('Mass Flow Rate ($\frac{kg}{s}$)',FontSize=params_plot.fn)
        xlabel('Time (s)',FontSize=params_plot.fn)
        xlim(params_plot.xlim)
        ylim(params_plot.ylim)
        set(gca,FontSize=params_plot.fn)
        box on; grid on; hold off
end

end