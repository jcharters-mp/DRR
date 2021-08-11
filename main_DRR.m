%% main script for ExacTrac DRR generation
% John Charters
% Summer 2021

%{
References
ExacTrac 6.2 - Clinical User Guide
"2D/3D image fusion for accurate target localization..." by Jin et al.
"Fast calculation of the exact radiological path for a
three-dimensional CT array" by Siddon
"A fast ray-tracing technique for TCT and ECT studies" by Han et al.
%}

%% load CT

q = fullfile(pwd,'ITK','CT_phantom','CT');
[CTmat,CTinfo] = load_CT(pwd,q);

save('CT_phantom.mat', 'CTmat','CTinfo');

%% control point sequence parameters

RTplan = dicominfo('RTPLAN0001.dcm');

% isocenter
iso = RTplan.BeamSequence.Item_1.ControlPointSequence.Item_1.IsocenterPosition; % HFS [mm]

% mass attenuation coefficient of water for 70 keV X-ray beam
muH2O = 2.8935e-2; % [cm^2/g]
rhoH2O = 1; % [g/cm^3]

thresh = 100; % CT number threshold [HU]

%% in-room measurements

distTubeToFP = 3.6 * 1e3; % User Guide section 3.4.2 [mm]
distTubeToIso = 2.3 * 1e3; % User Guide section 3.4.2 [mm]
angleCenterlines = 62 * pi/180; % Jin et al. [rad]
angleObliquePlane = 53 * pi/180; % Jin et al. [rad]

res = [200,200]; % resolution [pix]
spc = [1,1]; % pixel spacing [mm/pix]

[foc1,foc2,orig1,orig2,pan1XDir,pan1YDir,~,pan2XDir,pan2YDir,~] = ...
    room_geom(distTubeToFP,distTubeToIso,angleCenterlines,angleObliquePlane,res,spc);

%% ray tracing with assumed geometry

aDRR1 = raytrace_DRR(CTmat,CTinfo,iso,res,spc,foc1,orig1,...
    pan1XDir,pan1YDir,muH2O*rhoH2O,thresh);
aDRR2 = raytrace_DRR(CTmat,CTinfo,iso,res,spc,foc2,orig2,...
    pan2XDir,pan2YDir,muH2O*rhoH2O,thresh);

figure; imshow(aDRR1);
figure; imshow(aDRR2);

%% run ITK_render.m before proceeding below

% ITK_render;

% change coordinates for my algorithms
hfs2iec = iec2hfs'; % Q^-1 = Q^T

foc1 = hfs2iec * foc1; % IEC [mm]
orig1 = hfs2iec * orig1; % IEC [mm]
pan1XDir = hfs2iec * dirCos1(:,1); % IEC
pan1YDir = hfs2iec * dirCos1(:,2); % IEC

foc2 = hfs2iec * foc2; % IEC [mm]
orig2 = hfs2iec * orig2; % IEC [mm]
pan2XDir = hfs2iec * dirCos2(:,1); % IEC
pan2YDir = hfs2iec * dirCos2(:,2); % IEC

res = [W,H]; % [pix]
spc = [sx,sy]; % [mm/pix]

tpre = [tXpre;tYpre;tZpre]; % HFS [mm]
tpost = [tXpost;tYpost;tZpost]; % HFS [mm]

rpre = [rXpre;rYpre;rZpre]; % HFS [deg]
rpost = [rXpost;rYpost;rZpost]; % HFS [deg]
rpre = hfs2iec * rpre; % IEC [deg]
rpost = hfs2iec * rpost; % IEC [deg]

%% ray tracing with ExacTrac variables

DRR1pre = raytrace_DRR(CTmat,CTinfo,iso,res,spc,foc1,orig1,...
    pan1XDir,pan1YDir,muH2O*rhoH2O,thresh, tpre,rpre);
DRR2pre = raytrace_DRR(CTmat,CTinfo,iso,res,spc,foc2,orig2,...
    pan2XDir,pan2YDir,muH2O*rhoH2O,thresh, tpre,rpre);
DRR1post = raytrace_DRR(CTmat,CTinfo,iso,res,spc,foc1,orig1,...
    pan1XDir,pan1YDir,muH2O*rhoH2O,thresh, tpost,rpost);
DRR2post = raytrace_DRR(CTmat,CTinfo,iso,res,spc,foc2,orig2,...
    pan2XDir,pan2YDir,muH2O*rhoH2O,thresh, tpost,rpost);

% imwrite(DRR1pre,'myDRR1pre.png');
% imwrite(DRR2pre,'myDRR2pre.png');
% imwrite(DRR1post,'myDRR1post.png');
% imwrite(DRR2post,'myDRR2post.png');

% SuperimposeGUI(exactracDRR1pre,DRR1pre);
% SuperimposeGUI(exactracDRR2pre,DRR2pre);
% SuperimposeGUI(exactracDRR1post,DRR1post);
% SuperimposeGUI(exactracDRR2post,DRR2post);
