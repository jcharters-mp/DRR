%% load 3D CT
% John Charters, M.S.
% David Geffen School of Medicine at UCLA

%{
Input
p: current directory
q: CT directory

Output
CTmat: CT volume [double]
CTinfo: CT DICOM headers
%}

function [CTmat,CTinfo] = load_CT(p,q)

cd(q);

% scan for DICOM files
myFiles = dir('*.dcm');
if isempty(myFiles)
    myFiles = dir('*.ima');
end
nSlice = length(myFiles);

CTinfo = cell(nSlice,1);

% first slice to get dimensions
CTinfo{1} = dicominfo(myFiles(1).name);
nCols = CTinfo{1}.Columns;
nRows = CTinfo{1}.Rows;

CTmat = zeros(nRows,nCols,nSlice);
CTmat(:,:,1) = double(dicomread(CTinfo{1}));

for i = 2:nSlice
    CTinfo{i} = dicominfo(myFiles(i).name);
    CTmat(:,:,i) = double(dicomread(CTinfo{i}));
end

cd(p);

end
