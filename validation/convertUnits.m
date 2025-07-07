function [d] = convertUnits(d,rho)
% convert mass flow units from gal/min to kg/s and pressure units from PSIG
% to Pa using current fluid density rho

names = d.Properties.VariableNames;
idxM = find(contains(names,'M_'));
idxP = find(contains(names,'P_'));

d{:,idxM} = d{:,idxM}*3.7854/1000*rho/60;                                   % Convert from gal/min to kg/s
d{:,idxP} = d{:,idxP}*6.895*1000;                                           % Convert from psig to Pa

end