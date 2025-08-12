function [d] = convertUnits(d,rho)
%CONVERTUNITS  Convert collected units to SI.
%
%   [d] = CONVERTUNITS(d, rho)
%
%   DESCRIPTION:
%   convert mass flow units from gal/min to kg/s and pressure units from
%   PSIG to Pa using current fluid density rho 
%
%   INPUTS:
%       d   - Structure of data to be converted.
%       rho - Fluid density.
%
%   OUTPUTS:
%       d   - Structure of converted data.

%% Convert data

% Extract variable types
names = d.Properties.VariableNames;
idxM = find(contains(names,'M_'));
idxP = find(contains(names,'P_'));

% Perform conversions
d{:,idxM} = d{:,idxM}*3.7854/1000*rho/60;   % Convert from gal/min to kg/s
d{:,idxP} = d{:,idxP}*6.895*1000;           % Convert from psig to Pa

end