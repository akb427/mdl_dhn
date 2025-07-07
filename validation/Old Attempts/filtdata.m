function [d_filt, d_p1filt,d_p2filt] = filtdata(d, d_p1,d_p2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
%Hd = designfilt('lowpassiir','PassbandFrequency',.01,'StopbandFrequency',.019,'SampleRate',1);      % Good for mdot
Hd = designfilt('lowpassiir','PassbandFrequency',.03,'StopbandFrequency',.039,'SampleRate',1);      % Good for T

y = filtfilt(Hd,table2array(d(:,2:end)));
d_filt = array2table([d.Time y],'VariableNames',d.Properties.VariableNames);

y = filtfilt(Hd,table2array(d_p1(:,2:end)));
d_p1filt = array2table([d_p1.Time y],'VariableNames',d_p1.Properties.VariableNames);
d_p1filt.Power(1:10) = d_p1.Power(1:10);
y = filtfilt(Hd,table2array(d_p2(:,2:end)));
d_p2filt = array2table([d_p2.Time y],'VariableNames',d_p2.Properties.VariableNames);

% Limit Valve & Peltier to correct range
d_filt.V_ThM1(d_filt.V_ThM1<0)=0;
d_filt.V_ThM2(d_filt.V_ThM2<0)=0;
d_filt.V_ThM1(d_filt.V_ThM1>100)=100;
d_filt.V_ThM2(d_filt.V_ThM2>100)=100;
d_p2filt.Power(1:10) = d_p2.Power(1:10);
d_p1filt.Power(d_p1filt.Power<0)=0;
d_p2filt.Power(d_p2filt.Power<0)=0;
d_p1filt.Power(d_p1filt.Power>100)=100;
d_p2filt.Power(d_p2filt.Power>100)=100;

%fig_dim(d_filt, d_p1filt, d_p2filt)
plot(d_filt.Time, d_filt.V_ThM1)
end