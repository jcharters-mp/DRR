%% RQ factorization
% John Charters, M.S.
% David Geffen School of Medicine at UCLA

%{
Any real square matrix may be decomposed as A = RQ

Reference
"QR decomposition" - Wikipedia

Input
A: real square matrix

Output
R: upper triangular matrix
Q: orthogonal matrix
%}

function [R,Q] = RQ_factor(A)

[n,~] = size(A);

% Gram-Schmidt procedure
a = zeros(n);
u = zeros(n);
for i = 1:n
    
    % for RQ, we start with the last row of A and move up
    a(:,i) = A(n+1-i,:)'; 
    
    % initialize
    uu = a(:,i);
    
    % subtract orthogonal components from previous vectors
    for j = (i-1):-1:1
        uu = uu - (u(:,j)'*a(:,i))/(u(:,j)'*u(:,j)) * u(:,j);
    end
    u(:,i) = uu;

end

% Q matrix
Q = zeros(n);
for i = 1:n
    % for RQ, we start with the last row of Q and move up
    Q(n+1-i,:) = u(:,i) / norm(u(:,i));
end

% R matrix
R = A * Q';

end
