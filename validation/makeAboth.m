function [A] = makeAboth(c1,c2,c3,b,a,Lp)
%MAKEABOTH  Generate state matrix for DHN model.
%
%   [A] = MAKEABOTH(c1,c2,c3,b,a,Lp)
%
%   DESCRIPTION: Creates the state matrix for the the two user DHN loop
%   based on the given coefficient and mass flow rate splits. Include all
%   pipe states and two states for the temperature of both thermal masses. 
%   
%   INPUTS:
%       c1  - Pipe coefficients, mdot/rhoV
%       c2  - Pipe coefficients, hAs/rhocpV
%       c3  - Pipe coefficients, -(c1+c2)
%       b   - Building coefficients
%       a   - Mass flow split at thermal mass
%       Lp  - Mass flow split between loops
%
%   OUTPUTS:
%       A   - State transition matrix

%% Matrix for loop 1

A1 = diag(c3(2:7));
A1(2,1) = c1(2+1);
A1(3,2) = c1(3+1);
A1(4,3) = c1(4+1);
A1(5,1) = c1(5+1);
% Mass flow split
A1(6,4) = a(1)*c1(6+1);
A1(6,5) = (1-a(1))*c1(6+1);

%% Matrix for loop 2

A2 = diag(c3(8:13));
A2(2,1) = c1(2+7);
A2(3,2) = c1(3+7);
A2(4,3) = c1(4+7);
A2(5,1) = c1(5+7);
% Mass flow split
A2(6,4) = a(2)*c1(6+7);
A2(6,5) = (1-a(2))*c1(6+7);

%% Interconnection Matrices

% Self dependence of input and output
a11 = c3(1);
a33 = c3(14);

% Loop feeding temps
a21 = [c1(2); zeros(6,1); c1(8); zeros(6,1)];

% Averaged return temp
a32 = [zeros(1,5) Lp*c1(14), 0 zeros(1,5) (1-Lp)*c1(14), 0];

% Add building states
A1 = [A1 [0; 0; c2(4); 0; 0; 0];[0 0 b(1,1) 0 0 0 -(b(1,1)+b(1,2))]];
A2 = [A2 [0; 0; c2(10); 0; 0; 0];[0 0 b(2,1) 0 0 0 -(b(2,1)+b(2,2))]];

%% Combine in to single matrix

% spacing dimensions
K = 1;
L = 14;

a22 = [A1 zeros(7); zeros(7) A2];
A = [a11 zeros(K,L) zeros(K,K); a21 a22 zeros(L,K); zeros(K,K) a32 a33];

end