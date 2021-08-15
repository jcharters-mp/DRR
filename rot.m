%% Rodrigues' rotation formula
% John Charters, M.S.
% David Geffen School of Medicine at UCLA

%{
This function builds a rotation matrix about an arbitrary axis

Reference
"Rodrigues' rotation formula" - Wikipedia

Input
(kx,ky,kz): unit vector rotation axis
theta: rotation angle (+ve = ccw, -ve = cw) [rad]

Output
R: rotation matrix, so that v_rot = R*v
%}

function R = rot(k,theta)

if norm(k)==0
    error('axis cannot be zero');
end

if norm(k)~=1
    k = k / norm(k);
end

matK = [0 -k(3) k(2); k(3) 0 -k(1); -k(2) k(1) 0];

R = eye(3) + sin(theta)*matK + (1-cos(theta))*matK*matK;

end
