function [data_filt, pelt1_filt,pelt2_filt] = clean_data(data, pelt1, pelt2)
%FILTDATA  Filter data set.
%
%   [data_filt, peltier1_filt,peltier2_filt] = filtdata(data, peltier1, peltier2)
%
%   DESCRIPTION:
%   Applies a IIR lowpassfilter keeping signals below 0.03 Hz and 
%   attenuating those above 0.039. Applies the filter to the input data 
%   except time. Allows optional inputs to filter additional data. 
%   Also ensures physically impossible values are eliminated. Plots the
%   filted data.
%
%   INPUTS:
%       data    - Table of data to filter.
%       pelt1   - Optional additional table to filter.
%       pelt2   - Optional additional table to filter.
%
%   OUTPUTS:
%       data_filt   - Table of filted data values.
%       pelt1_filt  - Table of filted peltier1 values.
%       pelt2_filt  - Table of filted peltier2 values.
%
%   DEPENDENCIES: fig_dim

%% Filter first input

% design filter
Hd = designfilt('lowpassiir','PassbandFrequency',.03,'StopbandFrequency',.039,'SampleRate',1);
% filter all but time
data_temp = filtfilt(Hd,table2array(data(:,2:end)));
data_filt = array2table([data.Time data_temp],'VariableNames',data.Properties.VariableNames);

% Limit Valve & Peltier to correct range
data_filt.V_ThM1(data_filt.V_ThM1<0)=0;
data_filt.V_ThM2(data_filt.V_ThM2<0)=0;
data_filt.V_ThM1(data_filt.V_ThM1>100)=100;
data_filt.V_ThM2(data_filt.V_ThM2>100)=100;

% plot filtered data
fig_dim(data_filt)

%% Filter additional inputs

if nargin>1
    % optional input 1
    data_temp = filtfilt(Hd,table2array(pelt1(:,2:end)));
    pelt1_filt = array2table([pelt1.Time data_temp],'VariableNames',pelt1.Properties.VariableNames);
    % fix and limit data
    pelt1_filt.Power(1:10) = pelt1.Power(1:10);
    pelt1_filt.Power(pelt1_filt.Power<0)=0;
    pelt1_filt.Power(pelt1_filt.Power>100)=100;
    
    % optional input 2
    data_temp = filtfilt(Hd,table2array(pelt2(:,2:end)));
    pelt2_filt = array2table([pelt2.Time data_temp],'VariableNames',pelt2.Properties.VariableNames);
    % fix and limit data
    pelt2_filt.Power(1:10) = pelt2.Power(1:10);
    pelt2_filt.Power(pelt2_filt.Power<0)=0;
    pelt2_filt.Power(pelt2_filt.Power>100)=100;
end

end