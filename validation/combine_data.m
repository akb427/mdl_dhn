function [data] = combine_data(data1,data2,time_rm)
%FUNCTION_NAME  Trim and combine data sets.
%
%   [data] = combine_data(data1,data2,time_rm)
%
%   DESCRIPTION:
%   Trims the data in both data sets according to the limits in time_rm.
%   Then combines the two data sets into one continuous data set. 
%
%   INPUTS:
%       data1   - Structure of first data set.
%       data2   - Structure of second data set.
%       time_rm - Matrix of upper and lower time limis (columms) for both 
%                 data sets (rows)
%
%   OUTPUTS:
%       data - Structure of combined data.

%% Trim Data

% trim lower limit time in data set 1
data1.dhn(data1.dhn.Time<time_rm(1,1),:) = [];
data1.pelt1(data1.pelt1.Time<time_rm(1,1),:) = [];
data1.pelt2(data1.pelt2.Time<time_rm(1,1),:) = [];

% trim upper limit time in data set 1
data1.dhn(data1.dhn.Time>time_rm(1,2),:) = [];
data1.pelt1(data1.pelt1.Time>time_rm(1,2),:) = [];
data1.pelt2(data1.pelt2.Time>time_rm(1,2),:) = [];

% trim lower limit time in data set 2
data2.dhn(data2.dhn.Time<time_rm(2,1),:) = [];
data2.pelt1(data2.pelt1.Time<time_rm(2,1),:) = [];
data2.pelt2(data2.pelt2.Time<time_rm(2,1),:) = [];

% trim upper limit time in data set 2
data2.dhn(data2.dhn.Time>time_rm(2,2),:) = [];
data2.pelt1(data2.pelt1.Time>time_rm(2,2),:) = [];
data2.pelt2(data2.pelt2.Time>time_rm(2,2),:) = [];

%% Combine data

% offset time in data set 2 for combination
data2.dhn.Time = data2.dhn.Time+time_rm(1,2)+1-time_rm(2,1);
data2.pelt1.Time = data2.pelt1.Time+time_rm(1,2)+1-time_rm(2,1);
data2.pelt2.Time = data2.pelt2.Time+time_rm(1,2)+1-time_rm(2,1);

% combine data into 1 table
data.dhn = [data1.dhn; data2.dhn];
data.pelt1 = [data1.pelt1; data2.pelt1];
data.pelt2 = [data1.pelt2; data2.pelt2];

% interpolate peltier data
data.dhn.Q1 = interp1(data.pelt1.Time, data.pelt1.Power*0.79, data.dhn.Time);
data.dhn.Q2 = interp1(data.pelt2.Time, data.pelt2.Power*0.79, data.dhn.Time);

end