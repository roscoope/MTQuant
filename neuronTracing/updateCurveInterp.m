%%% udpateCurveInterp.m
%%% Updates the spline to trace the brightest nearby point
%%%
%%% Input arguments
%%% lineSumInds = indices around the current spline
%%% imIn = neuron image
%%% t = parameter for indexing the spline
%%% segLen = length of perpendicular line segment to trace (in pixels)
%%% segPts = number of points to sample the perpendicular line segments
%%% step (optional) = step by which to respace the spline
%%% beta (optional) = weight on distance penalty
%%% 
%%% Output arguments
%%% newLineSumInds = updated indices around the current spline
%%% yOut, xOut = y and x coordinates of the spline tracing the neuron
%%% ps = MATLAB spline 
%%% psPrime = first derivative of ps
%%% tOut = updated parameter for indexing the spline

function [newLineSumInds,yOut,xOut,ps,psPrime,tOut] = updateCurveInterp(lineSumInds,imIn,t,segLen,segPts,step,beta)

alpha = 1;
if ~exist('beta','var')
    beta = 2;
end
if ~exist('step','var')
    step = 10;
end

[h,w] = size(imIn);

%%% Find new x,y values to pass into the next functions
prevY = lineSumInds(:,:,1);
prevX = lineSumInds(:,:,2);
prevMaxY = lineSumInds(:,ceil(segPts/2),1);
prevMaxX = lineSumInds(:,ceil(segPts/2),2);

%%% Calculate Euclidean distance of each point to the previous spline
distToPrev = sqrt((prevY-repmat(prevMaxY,1,segPts)).^2 + ...
    (prevX-repmat(prevMaxX,1,segPts)).^2);

[Y,X] = ndgrid(1:h,1:w);
values = interp2(X,Y,double(imIn),prevX,prevY);

%%% Calculate a penalty for each pixel based on the intensity and the
%%% Euclidean distance from the previous spline.
[~,maxInds] = max(alpha*values-beta*distToPrev.^2,[],2);

y = lineSumInds(sub2ind(size(lineSumInds),(1:length(t))',maxInds,1*ones(size(maxInds))));
x = lineSumInds(sub2ind(size(lineSumInds),(1:length(t))',maxInds,2*ones(size(maxInds))));

tToFit = t(1:step:end);
xToFit = x(1:step:end)';
yToFit = y(1:step:end)';

tToFit(1) = t(1);
tToFit(end) = t(end);
xToFit(1) = prevMaxX(1);
xToFit(end) = prevMaxX(end);
yToFit(1) = prevMaxY(1);
yToFit(end) = prevMaxY(end);

%%% Update the spline
[ps, psPrime] = fitSpline(tToFit,xToFit,yToFit);

%%% Get new scan locations for the updated spline
[newLineSumInds,yOut,xOut,tOut] = getLineSumIndsInterp(t,ps,psPrime,h,w,segLen,segPts);
