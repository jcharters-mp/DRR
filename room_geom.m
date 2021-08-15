%% DRR generator parameters based on assumed linac geometry
% John Charters, M.S.
% David Geffen School of Medicine at UCLA

%{
All measurements are in IEC coordinates, and linac isocenter = [0;0;0]

References
ExacTrac 6.2 - Clinical User Guide
"2D/3D image fusion for accurate target localization..." by Jin et al.

Input
distTubeToFP: distance from x-ray tube to flat panel [mm]
distTubeToIso: distance from x-ray tube to isocenter [mm]
angleCenterlines: beam centerline intersection angle in imaging plane [rad]
angleObliquePlane: beam centerline angle above horizontal plane [rad]
res: DRR resolution [pix]
spc: DRR pixel spacing [mm/pix]

Output
(foc1,foc2): x-ray tube focal point positions [mm]
(orig1,orig2): DRR upper-left corner origins [mm]
(pan1XDir,pan1YDir,beam1Dir): orthogonal directions for flat panel 1
(pan2XDir,pan2YDir,beam2Dir): orthogonal directions for flat panel 2
%}

function [foc1,foc2,orig1,orig2,pan1XDir,pan1YDir,beam1Dir,pan2XDir,pan2YDir,beam2Dir] = ...
    room_geom(distTubeToFP,distTubeToIso,angleCenterlines,angleObliquePlane,res,spc)

% oblique plane defined by the central beamlines crossing at linac iso.
angleTube1 = (pi - angleCenterlines) / 2;
beam1Dir = [1;0;tan(angleTube1)];
beam1Dir = rot([1,0,0], pi/2-angleObliquePlane) * beam1Dir;

% reparameterize by arclength, so that
% beamline = tube1Pos + [deltaX,deltaY,deltaZ]*arclength
beam1Dir = beam1Dir / norm(beam1Dir);
beam2Dir = [-1;1;1] .* beam1Dir; % by symmetry

% at isocenter, beamline = [0;0;0]
foc1 = -distTubeToIso * beam1Dir;
foc2 = [-1;1;1] .* foc1; % by symmetry

% flat panel centers
pan1 = foc1 + beam1Dir*distTubeToFP;
pan2 = foc2 + beam2Dir*distTubeToFP;

% flat panel 1 orthogonal directions
beam1DirFloor = [1;1;0] .* beam1Dir;
beam1DirFloor = beam1DirFloor / norm(beam1DirFloor);

beam1DirFloorPerp = rot([0,0,1], pi/2) * beam1DirFloor;
pan1YDir = rot(beam1DirFloorPerp, pi/2) * beam1Dir; % rotate beam1 centerline vertically down

pan1XDir = cross(pan1YDir,beam1Dir);

% flat panel 2 orthogonal directions
beam2DirFloor = [1;1;0] .* beam2Dir;
beam2DirFloor = beam2DirFloor / norm(beam2DirFloor);

beam2DirFloorPerp = rot([0,0,1], pi/2) * beam2DirFloor;
pan2YDir = rot(beam2DirFloorPerp, pi/2) * beam2Dir; % rotate beam2 centerline vertically down

pan2XDir = cross(pan2YDir,beam2Dir);

% DRR origins
cx = ceil(res(1)/2); % X pixel shift
cy = ceil(res(2)/2); % Y pixel shift
orig1 = pan1 - cx*spc(1)*pan1XDir - cy*spc(2)*pan1YDir;
orig2 = pan2 - cx*spc(1)*pan2XDir - cy*spc(2)*pan2YDir;

end
