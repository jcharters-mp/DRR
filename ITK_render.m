%% ITK rendering
% John Charters, M.S.
% David Geffen School of Medicine at UCLA

%% load CT volume

% directory containing the DICOM files
dicomDir = '.\CT';
filenameCT = 'myCT.nrrd';

if ~exist(dicomDir,'dir')
    error('DICOM directory does not exist');
end

% ReadDicom.cxx
%system('.\ReadDicom -h'); % to display help
system(strcat(['.\ReadDicom ',dicomDir,' ',filenameCT]));

%% ExacTrac config matrices

ini = IniConfig(); % from FileExchange
ini.ReadFile('ExacTrac61_0_1.ini');

% MLinToFlat1
strMLinToFlat1 = ini.GetValues('[FlatPanel]','MLinToFlat1');
cellMLinToFlat1 = textscan(strMLinToFlat1,'%s', 'Delimiter',',');
cellMLinToFlat1{1}(1) = []; % remove preceding zero
cellMLinToFlat1{1} = cellfun(@str2num, cellMLinToFlat1{1});
MLinToFlat1 = reshape(cellMLinToFlat1{1},[4,3]);
MLinToFlat1 = MLinToFlat1'; % IEC

% MLinToFlat2
strMLinToFlat2 = ini.GetValues('[FlatPanel]','MLinToFlat2');
cellMLinToFlat2 = textscan(strMLinToFlat2,'%s', 'Delimiter',',');
cellMLinToFlat2{1}(1) = []; % remove preceding zero
cellMLinToFlat2{1} = cellfun(@str2num, cellMLinToFlat2{1});
MLinToFlat2 = reshape(cellMLinToFlat2{1},[4,3]);
MLinToFlat2 = MLinToFlat2'; % IEC

% IEC to HFS coordinate transformation
iec2hfs = [1,0,0; 0,0,-1; 0,1,0];

%% DRR parameters

% DRRs are 512x512 pix
W = 512; % [pix]
H = 512; % [pix]

% DRRs are 200x200 mm
sx = 200/512; % [mm/pix]
sy = 200/512; % [mm/pix]

% isocenter
RTplan = dicominfo('RTPLAN0001.dcm');
iso = RTplan.BeamSequence.Item_1.ControlPointSequence.Item_1.IsocenterPosition; % HFS [mm]

% RQ decomposition
[P1,L1] = RQ_factor(MLinToFlat1(1:3,1:3));
[P2,L2] = RQ_factor(MLinToFlat2(1:3,1:3));

% projection matrix P_det
Pdet1 = P1 / P1(3,3);
Pdet2 = P2 / P2(3,3);

% tube-detector distance (SID)
SID1 = Pdet1(1,1) * sx; % [mm]
SID2 = Pdet2(1,1) * sx; % [mm]

% focal point
foc1 = -MLinToFlat1(1:3,1:3) \ MLinToFlat1(1:3,4); % [mm]
foc2 = -MLinToFlat2(1:3,1:3) \ MLinToFlat2(1:3,4); % [mm]

foc1 = iec2hfs * foc1;
foc2 = iec2hfs * foc2;

% direction cosines
dirCos1 = L1(1:3,1:3)';
dirCos2 = L2(1:3,1:3)';

dirCos1 = iec2hfs * dirCos1;
dirCos2 = iec2hfs * dirCos2;

% pixel shift
cx1 = Pdet1(1,3); % [pix]
cy1 = Pdet1(2,3); % [pix]
cx2 = Pdet2(1,3); % [pix]
cy2 = Pdet2(2,3); % [pix]

% DRR origin
orig1 = foc1 + dirCos1 * [-cx1*sx; -cy1*sy; SID1]; % [mm]
orig2 = foc2 + dirCos2 * [-cx2*sx; -cy2*sy; SID2]; % [mm]

% threshold
thresh = 100; % [uint8]

%% ExacTrac Positioning Report (treatment.pdf)

%{
NB: Extra negative sign in rotations is conventional for ZYX Euler angles.
See Wikipedia "Euler angles: Angles of a given frame: Tait-Bryan angles".
NB: To get pre-reg images for Verification N > 0, you will need to apply
the rotations in the first row of the table.
%}

% X-ray translation corrections (HFS)
tXpre = 0; % lateral [mm]
tYpre = 0; % -ve vertical [mm]
tZpre = 0; % longitudinal [mm]

tXpost = 0.31; % lateral [mm]
tYpost = -0.31; % -ve vertical [mm]
tZpost = 0.35; % longitudinal [mm]

% X-ray rotation corrections (HFS)
rXpre = 0.1; % lateral [deg]
rYpre = -1.9; % vertical [deg]
rZpre = -0.1; % longitudinal [deg]

rXpost = 0.5; % lateral [deg]
rYpost = -1.7; % vertical [deg]
rZpost = -0.8; % longitudinal [deg]

%% generate DRRs

% DRR.cxx
%system('.\DRR -h'); % to display help

%% DRR1 pre

filenameDRR1pre = '.\itkDRR1pre.png';

system(strcat(['.\DRR',...
    ' -size ',num2str(W),' ',num2str(H),...
    ' -res ',num2str(sx),' ',num2str(sy),...
    ' -iso ',num2str(iso'),...
    ' -foc ',num2str(foc1'),...
    ' -dirCos ',num2str(dirCos1(:)'),...
    ' -orig ',num2str(orig1'),...
    ' -thresh ',num2str(thresh),...
    ' -transl ',num2str(tXpre),' ',num2str(tYpre),' ',num2str(tZpre),...
    ' -rot ',num2str(rXpre),' ',num2str(rYpre),' ',num2str(rZpre),...
    ' -o ',filenameDRR1pre,...
    ' ',filenameCT]));

%% DRR1 post

filenameDRR1post = 'itkDRR1post.png';

system(strcat(['.\DRR',...
    ' -size ',num2str(W),' ',num2str(H),...
    ' -res ',num2str(sx),' ',num2str(sy),...
    ' -iso ',num2str(iso'),...
    ' -foc ',num2str(foc1'),...
    ' -dirCos ',num2str(dirCos1(:)'),...
    ' -orig ',num2str(orig1'),...
    ' -thresh ',num2str(thresh),...
    ' -transl ',num2str(tXpost),' ',num2str(tYpost),' ',num2str(tZpost),...
    ' -rot ',num2str(rXpost),' ',num2str(rYpost),' ',num2str(rZpost),...
    ' -o ',filenameDRR1post,...
    ' ',filenameCT]));

%% DRR2 pre

filenameDRR2pre = 'itkDRR2pre.png';

system(strcat(['.\DRR',...
    ' -size ',num2str(W),' ',num2str(H),...
    ' -res ',num2str(sx),' ',num2str(sy),...
    ' -iso ',num2str(iso'),...
    ' -foc ',num2str(foc2'),...
    ' -dirCos ',num2str(dirCos2(:)'),...
    ' -orig ',num2str(orig2'),...
    ' -thresh ',num2str(thresh),...
    ' -transl ',num2str(tXpre),' ',num2str(tYpre),' ',num2str(tZpre),...
    ' -rot ',num2str(rXpre),' ',num2str(rYpre),' ',num2str(rZpre),...
    ' -o ',filenameDRR2pre,...
    ' ',filenameCT]));

%% DRR2 post

filenameDRR2post = 'itkDRR2post.png';

system(strcat(['.\DRR',...
    ' -size ',num2str(W),' ',num2str(H),...
    ' -res ',num2str(sx),' ',num2str(sy),...
    ' -iso ',num2str(iso'),...
    ' -foc ',num2str(foc2'),...
    ' -dirCos ',num2str(dirCos2(:)'),...
    ' -orig ',num2str(orig2'),...
    ' -thresh ',num2str(thresh),...
    ' -transl ',num2str(tXpost),' ',num2str(tYpost),' ',num2str(tZpost),...
    ' -rot ',num2str(rXpost),' ',num2str(rYpost),' ',num2str(rZpost),...
    ' -o ',filenameDRR2post,...
    ' ',filenameCT]));

%% compare to known DRRs

exactracDRR1pre = im2double(imread('drr1_0_preReg.png'));
exactracDRR1post = im2double(imread('drr1_0_postReg.png'));
exactracDRR2pre = im2double(imread('drr2_0_preReg.png'));
exactracDRR2post = im2double(imread('drr2_0_postReg.png'));

itkDRR1pre = im2double(imread(filenameDRR1pre));
itkDRR1post = im2double(imread(filenameDRR1post));
itkDRR2pre = im2double(imread(filenameDRR2pre));
itkDRR2post = im2double(imread(filenameDRR2post));

% SuperimposeGUI(exactracDRR1pre,itkDRR1pre);
% SuperimposeGUI(exactracDRR1post,itkDRR1post);
% SuperimposeGUI(exactracDRR2pre,itkDRR2pre);
% SuperimposeGUI(exactracDRR2post,itkDRR2post);
