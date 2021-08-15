%% raytrace DRR generator
% John Charters, M.S.
% David Geffen School of Medicine at UCLA

%{
References
"Fast calculation of the exact radiological path for a
three-dimensional CT array" by Siddon
"A fast ray-tracing technique for TCT and ECT studies" by Han et al.

Input
CTmat: CT volume [double]
CTinfo: CT DICOM headers
iso: CT isocenter (HFS) [mm]
res: DRR resolution [pix]
spc: DRR pixel spacing [mm/pix]
foc: x-ray tube focal point (IEC) [mm]
orig: DRR upper-left corner (IEC) [mm]
(panXDir,panYDir): flat panel orthogonal directions (IEC)
muH2O: linear attenuation coefficient of water [1/cm]
thresh: CT number threshold [HU]
tt (optional): 6D translation corrections (HFS) [mm]
rr (optional): 6D rotation corrections (IEC) [deg]

Output
DRR: DRR [double]
%}

function DRR = raytrace_DRR(CTmat,CTinfo,iso,res,spc,...
    foc,orig,panXDir,panYDir,muH2O,thresh, tt,rr)

% matrix to convert voxel index (row,col,slice), beginning with 0,
% to voxel location (x,y,z) [mm]
voxConv = dicom_affine(CTinfo{1},CTinfo{2});

% voxel intensity to CT number [HU]
HUslope = CTinfo{1}.RescaleSlope;
HUintercept = CTinfo{1}.RescaleIntercept;

% border of CT volume
%{
NB: Image Position attribute is w.r.t. voxel center. Volume border should
therefore be at voxConv*[-0.5;-0.5;-0.5;1]. However, to match our DRRs with
both ITK-rendered and known ExacTrac DRRs, we found that the volume border
sometimes needs to be changed to voxConv*[-0.5;-0.5;0.5;1]. Perhaps this is
related to a negative dz in our datasets.
%}
homogCTborder = voxConv * [-0.5;-0.5;-0.5;1];
CTborder = homogCTborder(1:3) - iso; % HFS [mm]

% 6D fusion corrections
if exist('tt','var')
    CTborder = CTborder + tt; % HFS [mm]
end

% parallel planes
N = size(CTmat)';
dx = CTinfo{1}.PixelSpacing(1); % +ve [mm]
dy = CTinfo{1}.PixelSpacing(2); % +ve [mm]
dz = CTinfo{2}.ImagePositionPatient(3) - CTinfo{1}.ImagePositionPatient(3); % -ve [mm]
delta = [dx;dy;dz];

% change coordinates from DICOM HFS to IEC
hfs2iec = [1 0 0; 0 0 1; 0 -1 0];

delta = hfs2iec * delta;
CTborder = hfs2iec * CTborder;
N = abs(hfs2iec) * N;

point1 = CTborder;
pointN = CTborder + N .* delta;

% 6D fusion corrections
if exist('rr','var')
    
    rr = rr * pi/180; % [rad]
    rot3D = rot([0;1;0],rr(2)) * rot([0;0;1],rr(3)) * rot([1;0;0],rr(1)); % ZYX HFS -> IEC

    foc = rot3D*foc;
    orig = rot3D*orig;
    panXDir = rot3D*panXDir;
    panYDir = rot3D*panYDir;
    
end

resX = res(1); resY = res(2); % [pix]
spcX = spc(1); spcY = spc(2); % [mm/pix]

DRR = zeros(resY,resX);

for x = 1:resX
    for y = 1:resY
        
        thisPix = orig + (x-1)*spcX*panXDir + (y-1)*spcY*panYDir;

        % range of parametric values
        alpha1 = (point1 - foc) ./ (thisPix - foc);
        alphaN = (pointN - foc) ./ (thisPix - foc);
        
        alphaMin = max([0, min(alpha1(1),alphaN(1)), min(alpha1(2),alphaN(2)), min(alpha1(3),alphaN(3))]);
        alphaMax = min([1, max(alpha1(1),alphaN(1)), max(alpha1(2),alphaN(2)), max(alpha1(3),alphaN(3))]);
        
        if alphaMax <= alphaMin
            continue;
        end
        
        % range of indices (parallel planes indexed 0,...,N)
        indMin = (alphaMin*(thisPix - foc) + foc - point1) ./ delta;
        indMax = (alphaMax*(thisPix - foc) + foc - point1) ./ delta;

        % first intersected voxel
        firstVox = zeros(3,1);
        for i = 1:3
            if (abs(rem(indMin(i),1)) > 1e-10)
                firstVox(i) = ceil(indMin(i));
            elseif (indMin(i) < indMax(i)) && (abs(rem(indMin(i),1)) <= 1e-10)
                firstVox(i) = round(indMin(i)) + 1;
            elseif (indMin(i) > indMax(i)) && (abs(rem(indMin(i),1)) <= 1e-10)
                firstVox(i) = round(indMin(i));
            elseif (indMin(i) == indMax(i)) && (abs(rem(indMin(i),1)) <= 1e-10)
                firstVox(i) = round(indMin(i));
                if firstVox(i) == 0
                    firstVox(i) = 1;
                end
            end
        end
        
        % parameter of first intersection
        intrsct = zeros(3,1);
        for i = 1:3
            if indMin(i) <= indMax(i)
                intrsct(i) = ceil(indMin(i));
            else
                intrsct(i) = floor(indMin(i));
            end
        end
        firstAlpha = (point1 + intrsct.*delta - foc) ./ (thisPix - foc); 

        % initialize radiological path
        thisInd = firstVox;
        prevAlpha = alphaMin;
        thisAlpha = firstAlpha;
        for i = 1:3
            if (thisAlpha(i) < 0) || (isnan(thisAlpha(i)))
                thisAlpha(i) = Inf;
            end
        end
        radpath = 0;
        raytrace = 1;
        iter = 0;

        while raytrace==1
            
            % find minimum in triplet
            [alphaXi,thisIndXi] = min(thisAlpha);
            
            % intersection length
            thisLen = alphaXi - prevAlpha;
            
            % CT number
            thisVox = CTmat(thisInd(3),thisInd(1),thisInd(2)); % HFS order
            thisHU = thisVox*HUslope + HUintercept;

            % increment alpha
            prevAlpha = alphaXi;
            thisAlpha(thisIndXi) = alphaXi + abs(delta(thisIndXi) / (thisPix(thisIndXi) - foc(thisIndXi)));
            
            % increment voxel index
            if indMin(thisIndXi) < indMax(thisIndXi)
                thisInd(thisIndXi) = thisInd(thisIndXi) + 1;
            elseif indMin(thisIndXi) > indMax(thisIndXi)
                thisInd(thisIndXi) = thisInd(thisIndXi) - 1;
            end
            
            % check if indices are out of range
            if any(thisInd < 1) || any(thisInd > N)
                raytrace = 0;
            end

            % radiological path
            if thisHU < thresh % cutoff HU
                continue;
            end
            
            thisMu = (muH2O*thisHU/1000 + muH2O)/10; % [1/mm]
            radpath = radpath + thisLen*thisMu;
            
            iter = iter + 1;
        end
            
        distRay = norm(thisPix - foc); % [mm]
        radpath = distRay*radpath;

        DRR(y,x) = 1 - exp(-radpath);
        
    end
end

DRR = rescale(DRR); % rescale to [0,1]

end
