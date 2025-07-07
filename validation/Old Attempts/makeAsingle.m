function [A] = makeAsingle(c1,c2,c3,b,a)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

a11 = c3(1);
a33 = c3(8);
A1 = diag(c3(2:7));
A1(2,1) = c1(2+1);
A1(3,2) = c1(3+1);
A1(4,3) = c1(4+1);
A1(5,1) = c1(5+1);
A1(6,4) = a*c1(6+1);
A1(6,5) = (1-a)*c1(6+1);

K = 1;
L = 7;
a21 = [c1(2); zeros(6,1)];
a32 = [zeros(1,5) c1(8), 0];
A1 = [A1 [0; 0; c2(4); 0; 0; 0];[0 0 b(1,1) 0 0 0 -(b(1,1)+b(1,2))]];
a22 = A1;
A = [a11 zeros(K,L) zeros(K,K); a21 a22 zeros(L,K); zeros(K,K) a32 a33];

end