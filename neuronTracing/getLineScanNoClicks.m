%%% getLineScanNoClicks.m
%%% This function has two purposes:
%%%      1.  It identifies the spline that most accurately traces then
%%%          neurite of interest specified by the mask
%%%      2.  It interpolates the pixel intensities perpendicular to the
%%%          spline and sums them to generate the line scan
%%%
%%% Input arguments
%%% mpFile = either file name of projection file or a 2D image
%%% maskFile = either file name of mask image file or a 2D image
%%% toAvg = if true, the output line scan is the average of pixels
%%%      perpendicular to the spline at every point.  If false, the output line
%%%      scan is the sum of the pixels perpendicular to the spline.  SUM is
%%%      recommended
%%%
%%% Output arguments
%%% lineScan = sum/average of pixel values at finalLineSumInds
%%% straightNeurite = all of the interpolated values
%%% finalLineSumInds1 = Interpolated locations of the pixels summed to
%%%      generate the line scan.  
%%%      Its dimensions are length(lineScan) X 201 X 2 where each plane
%%%      represents the Y coordinates and the X coordinates, respectively

function [lineScan,straightNeurite,finalLineSumInds1] = getLineScanNoClicks(mpFile,maskFile,toAvg)

if nargin < 3
    toAvg = 0;
end

if ischar(mpFile)
    imIn = imread(mpFile);
    if size(imIn,3) > 1
        imIn = imIn(:,:,1);
    end
else
    imIn = mpFile;
end
[h,w] = size(imIn);

if ischar(maskFile)
    axonMask = imread(maskFile);
    if size(axonMask,3) > 1
        axonMask = axonMask(:,:,1);
    end
else
    axonMask = maskFile;
end

if isempty(axonMask)
    lineScan = [];
    return;
end

%%% Remove the image mean and mask the image
imNoMean1 = imIn - mean(imIn(:));
imNoMean = imNoMean1 .* uint16(axonMask);

%%% Find an endpoint at which to begin tracing the mask
thinMask = bwmorph(axonMask,'thin','inf');
ep = bwmorph(thinMask,'endpoints');
if nnz(ep) == 0
    ep = false(size(thinMask));
    ep(find(thinMask,1)) = 1;
end
cbMask = false(h,w);
cbMask(find(ep,1)) = 1;

%%% Initialize the steps that will trace the spline
tLen = 1000;
tStep1 = 1;
t1 = 1:tStep1:tLen;

%%% The number of steps to jump by when tracing the neuron
searchPixInit = floor(h/16);

[x1,y1] = growMask(axonMask,cbMask,searchPixInit,t1,tStep1,imNoMean,false(h,w));

minT1 = find(x1 ~= 0 | y1 ~= 0,1,'first');
maxT1 = find(x1 ~= 0 | y1 ~= 0,1,'last');

t1ToKeep = t1(max(minT1-100,1):min(maxT1+100,tLen));

[ps1, psPrime1] = fitSpline(t1,x1,y1);

imBlurred = imNoMean;

imA = imBlurred .* uint16(axonMask);

segLen = 2*10;
segPts = 2*100+1;

[lineSumInds1,allY1,allX1,tOut1tempA] = getLineSumIndsInterp(t1ToKeep,ps1,psPrime1,h,w,segLen,segPts);

tOut1 = tOut1tempA;

allX1 = allX1(ismember(t1ToKeep,tOut1));
allY1 = allY1(ismember(t1ToKeep,tOut1));

newY1 = zeros(size(allY1));
newX1 = zeros(size(allX1));
newLineSumInds1 = lineSumInds1;

normX = norm(allX1-newX1);
normY = norm(allY1-newY1);

numIters = 0;
maxIters = 1000;
epsilon =1;

%%% Iteratively update the spline until it is no longer changing
while (normY > epsilon || normX > epsilon) && (numIters < maxIters)
    allX1 = newX1;
    allY1 = newY1;
    [newLineSumInds1,newY1,newX1,newPs1,newPsPrime1,tOut1temp] = updateCurveInterp(newLineSumInds1,imA,tOut1,segLen,segPts,10,2);
    allX1 = allX1(ismember(tOut1,tOut1temp));
    allY1 = allY1(ismember(tOut1,tOut1temp));
    newX1 = newX1(ismember(tOut1,tOut1temp));
    newY1 = newY1(ismember(tOut1,tOut1temp));
    tOut1 = tOut1temp;
    normX = norm(allX1-newX1);
    normY = norm(allY1-newY1);
    numIters = numIters + 1;
end

tOut2 = fillInPoints(tOut1,allY1,allX1,newPs1);
[newLineSumInds1,~,~,tOut1] = getLineSumIndsInterp(tOut2,newPs1,newPsPrime1,h,w,segLen,segPts);

approxLineSumInds = sub2ind([h,w],round(newLineSumInds1(:,(segPts+1)/2,1)),round(newLineSumInds1(:,(segPts+1)/2,2)));

%%% Remove extraneous points at the end of the spline that are tracing dark pixels
tOut1tempB = removeDimPts(axonMask,approxLineSumInds,tOut1,tStep1);
finalLineSumInds1 = newLineSumInds1(ismember(tOut1,tOut1tempB),:,:);

%%% Interpolate the pixels using interp2
[Y,X] = ndgrid(1:h,1:w);
Xq = finalLineSumInds1(:,:,2);
Yq = finalLineSumInds1(:,:,1);
values = interp2(X,Y,double(imNoMean),Xq,Yq);
values((Xq<1) | (Xq>w) | (Yq<1) | (Yq>h)) = 0;

%%% average pixels if necessary
if toAvg
    lineScan = sum(values,2)./sum(values>0,2);
else
    lineScan = sum(values,2);
end

straightNeurite = values';