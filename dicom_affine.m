%% DICOM affine formula
% John Charters
% Fall 2020

% Reference: https://nipy.org/nibabel/dicom/dicom_orientation.html
% note: voxel indices (row,col,slice) begin at 0

% Input --
% (info{1},info{2}): DICOM headers

% Output --
% A: matrix that converts homog. voxel indices to homog. coords. [mm]

function A = dicom_affine(info1,info2)

F = info1.ImageOrientationPatient;
S = info1.ImagePositionPatient;
delta = info1.PixelSpacing;

T = info2.ImagePositionPatient - info1.ImagePositionPatient;

A = zeros(4);

A(:,1) = [F(4); F(5); F(6); 0] * delta(1);
A(:,2) = [F(1); F(2); F(3); 0] * delta(2);
A(:,3) = [T(1); T(2); T(3); 0];
A(:,4) = [S(1); S(2); S(3); 1];

end

