function figExp(d,nsplit, params_plot)
%FIGEXP  Plot the experiment profile used to collect data.
%
%   FIGEXP(d,nsplit, params_plot)
%
%   DESCRIPTION: Plots the experiment parameters used to run the
%   simulation. Shows the thermal mass temperature setpoints (hardcoded),  
%   supply temperature, and simulated ambient temperature. On the right
%   y-axis, shows the plant mass flow rate. 
%
%   INPUTS:
%       d           - Data from experiment
%       nsplit      - Split index between training and validation.
%       params_plot - Structure of plot settings.

%% Load Data
pth = string(pwd);
pth_data = pth+filesep+"data"+filesep;
load(pth_data+"LSplan.mat","LS")

%% Modify data
% Thermal mass setpoints
Tset_ThM1 = [zeros(1,15922) 28*ones(1,15873) zeros(1,15441) 28*ones(1,15927)];
Tset_ThM2 = [28*ones(1,3453) zeros(1,14234) 28*ones(1,17023) zeros(1,14572) 28*ones(1,13881)];

d.Time = d.Time/(60*60);


%% Plot Profiles
figure('Name','Experiment')
set(gcf,'Position',params_plot.pos)
hold on

% Temperatures
stairs(d.Time, Tset_ThM1, LineStyle = params_plot.ln_sty(1), Color=params_plot.clr(1,:), LineWidth=params_plot.ln)
stairs(d.Time, Tset_ThM2, LineStyle = params_plot.ln_sty(2), Color=params_plot.clr(2,:), LineWidth=params_plot.ln)
plot(d.Time, d.T_HeaterOut, LineStyle = params_plot.ln_sty(3), Color=params_plot.clr(7,:), LineWidth=params_plot.ln)
plot([LS.t(1,:) LS.t(2,:)+LS.t(1,end)]/(60*60), [LS.T_amb(1,:) LS.T_amb(2,:)], LineStyle = params_plot.ln_sty(4), Color=params_plot.clr(4,:), LineWidth=params_plot.ln)
xline(d.Time(nsplit), 'k', LineWidth = params_plot.ln)
ylabel('Temperature (C)')
legend('$T_{b}^{\{1\}}$ Set', '$T_{b}^{\{2\}} Set$','$T_{s}$', '$T_{amb\ sim}$','location','best','autoupdate','off')

% Mass flwo rates
yyaxis right
plot(d.Time, d.M_Heater,LineWidth=params_plot.ln)
ylabel('Initial Mass Flow Rate ($kg/s$)')
ylim(params_plot.ylim)
xlim(params_plot.xlim)
xlabel('Time (hr)')

box on; grid on; hold off

end