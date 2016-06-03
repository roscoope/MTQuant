%%% getLineSumIndsInterp.m
%%% Find the locations to trace to extract the line scan.
%%%
%%% Input arguments:
%%% t = parameter for indexing the spline
%%% ps = MATLAB spline 
%%% psPrime = first derivative of ps
%%% h,w = dimensions of neuron image
%%% segLen = length of perpendicular line segment to trace (in pixels)
%%% segPts = number of points to sample the perpendicular line segments
%%%
%%% Output arguments:
%%% lineSumInds = Interpolated locations of the pixels to be summed to
%%%      generate the line scan.  
%%%      Its dimensions are length(lineScan) X 201 X 2 where each plane
%%%      represents the Y coordinates and the X coordinates, respectively
%%% allY0, allX0 = y and x coordinates of the spline tracing the neuron
%%% tOut = updated parameter for indexing the spline

function [lineSumInds,allY0,allX0,tOut] = getLineSumIndsInterp(t,ps,psPrime,h,w,segLen,segPts)

%%% Evaluate the spline at the input points t
allPts = ppval(ps,t);
allX0 = allPts(1,:)';
allY0 = allPts(2,:)';

%%% Calculate the first derivative of the spline at input points t and
%%% calculate the perpendicular slopes at each point
allPtsPrime = ppval(psPrime,t);
allM = (allPtsPrime(2,:) ./ allPtsPrime(1,:))';
m = allM;

x0 = allX0;
y0 = allY0;
y0Rep = repmat(y0,1,segPts);

%%% Calculate the locations of the pixels along the perpendiculars
tanM = -1./m;
K = sqrt((segLen ^ 2) ./ (tanM .^ 2 + 1));

spacing = 2 * K / segPts;
xInit = repmat(x0,1,segPts);
numSegs = length(x0);
s = repmat(spacing,1,segPts).*repmat(-1*floor(segPts/2):floor(segPts/2),numSegs,1);
allX = xInit + s;
allY = repmat(tanM,1,segPts) .* (allX - repmat(x0,1,segPts)) + repmat(y0,1,segPts);
allY(isnan(allY)) = y0Rep(isnan(allY));

%%% Remove any points that are falling off the edge of the image
xRowsToRemove = (x0 < 1) | (x0 > w);
yRowsToRemove = (y0 < 1) | (y0 > h);

rowsToRemove = xRowsToRemove | yRowsToRemove;
xInRange = allX;
yInRange = allY;
xInRange(rowsToRemove,:) = [];
yInRange(rowsToRemove,:) = [];

lineSumInds = cat(3,yInRange,xInRange);

tOut = t;
tOut(rowsToRemove) = [];

