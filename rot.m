%% Rodrigues' rotation formula
% John Charters
% Fall 2020

% Goal: build rotation matrix about an arbitrary axis

% Reference: "Rodrigues' rotation formula" (Wikipedia)

% Input --
% (kx,ky,kz): unit vector rotation axis
% theta: rotation angle (+ve = ccw, -ve = cw) [rad]

% Output --
% R: rotation matrix, so that v_rot = R*v

function R = rot(k,theta)

if norm(k) ~= 1
    error('k needs to be normalized');
end

matK = [0 -k(3) k(2); k(3) 0 -k(1); -k(2) k(1) 0];

R = eye(3) + sin(theta)*matK + (1-cos(theta))*matK*matK;

end

