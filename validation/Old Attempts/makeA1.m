function [A] = makeA(c1,c2,c3,b,a,L2, flag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


K = 1;

a11 = c3(1);

a33 = c3(14);
a32 = [zeros(1,5) (1-L2)*c1(14), zeros(1,5) L2*c1(14)];
A1 = diag(c3(2:7));
A2 = diag(c3(8:13));
A1(2,1) = c1(2+1);
A1(3,2) = c1(3+1);
A1(4,3) = c1(4+1);
A1(5,1) = c1(5+1);
A1(6,4) = a(1)*c1(6+1);
A1(6,5) = (1-a(1))*c1(6+1);
A2(2,1) = c1(2+7);
A2(3,2) = c1(3+7);
A2(4,3) = c1(4+7);
A2(5,1) = c1(5+7);
A2(6,4) = a(2)*c1(6+7);
A2(6,5) = (1-a(2))*c1(6+7);

if flag         % Augement for ThM
    L = 14;
    a21 = [c1(2); zeros(6,1); c1(8); zeros(6,1)];
    a32 = [zeros(1,5) (1-L2)*c1(14), 0, zeros(1,5) L2*c1(14), 0];
    A1 = [A1 [0; 0; c2(4); 0; 0; 0];[0 0 b(1,1) 0 0 0 -(b(1,1)+b(1,2))]];
    A2 = [A2 [0; 0; c2(10); 0; 0; 0];[0 0 b(2,1) 0 0 0 -(b(2,1)+b(2,2))]];
    a22 = [A1 zeros(7);zeros(7) A2];
    A = [a11 zeros(K,L) zeros(K,K); a21 a22 zeros(L,K); zeros(K,K) a32 a33];
else
    L = 12;
    a21 = [c1(2); zeros(5,1); c1(8); zeros(5,1)];
    a22 = [A1 zeros(6);zeros(6) A2];
    a32 = [zeros(1,5) (1-L2)*c1(14), zeros(1,5) L2*c1(14)];
    A = [a11 zeros(K,L) zeros(K,K); a21 a22 zeros(L,K); zeros(K,K) a32 a33];
end

end