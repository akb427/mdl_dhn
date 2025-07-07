function [c, x_act] = calc_enthalpy(tr,tc,params, mdpts, usersm, pairs, usersp)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% calculate tree connector parameters
trpt = pairs(tr,:);
leaf = trpt(~ismember(trpt(:,2),trpt(:,1)),2);
nbr = numel(leaf);
br = cell(1,nbr);
for i = 1:nbr
    br_i = [trpt(trpt(:,2)==leaf(i),:)];
    idx = tr(trpt(:,2)==leaf(i));
    no = br_i(1,1);
    un_i = sum(usersm(leaf(i),:));
    while no>0
        br_i = [trpt(trpt(:,2)==no,:); br_i];
        idx = [tr(trpt(:,2)==no); idx];
        no = br_i(1,1);
        un_i = [+un_i(1);un_i];
    end
    br{i} = br_i;
    un_i = sum(usersm(br_i(:,2),:),2);
    un_i = cumsum(un_i,1,'reverse');
    mcp{i} = un_i*tc.mi*params.cp;
    D = params.DL*ones(size(br_i,1),1);
    D(un_i==1) = params.Ds;
    hAs{i} = pi*params.h.*tc.L_pairs(idx).*D;
end

%% Calculate SS T_pipes


end