%%% growMask.m
%%% Effectively traces the neuriteMaskIn from one endpoint to the last, and returns the pixels in order
%%%
%%% Input parameters:
%%% neuriteMaskIn = 2D image of neurite mask
%%% cbMask = mask image of the endpoint to begin tracing from
%%% searchPixInit = the number of pixels to skip ahead by (searching one
%%%      pixel after another would be too slow)
%%% t = spline tracing parameter
%%% tStep = amount to increment t by
%%% imIn (optional) = neuron image
%%% epMask (optional) = mask with ending location
%%% 
%%% Output parameters
%%% x,y = x and y coordinates, respectively, of the traced mask

function [x,y] = growMask(neuriteMaskIn,cbMask,searchPixInit,t,tStep,imIn,epMask)

if nargin == 5
    imIn = ones(size(neuriteMaskIn),'uint16');
    epMask = false(size(neuriteMaskIn));
end

x = zeros(size(t));
y = zeros(size(t));

[newY,newX] = find(cbMask,1);

neuriteMask = neuriteMaskIn;

searchPix = searchPixInit;
initMask = cbMask;
testMask = imdilate(initMask,strel('disk',searchPix));
nextMask = neuriteMask & testMask;

beta=0;
maskDiff = nextMask & ~initMask;
currInds = find(maskDiff);
[currY,currX] = ind2sub(size(imIn),currInds);
dists = sqrt((newX-currX).^2+(newY-currY).^2)+beta*double(imIn(currInds));
[~,loc] = min(dists);
if tStep == 1
    x(1) = currX(loc);
    y(1) = currY(loc);
else
    x(end) = currX(loc);
    y(end) = currY(loc);
end

tCount = tStep * searchPix;

%%% Iteratively grow the mask until reaching the end point
while tCount*tStep < max(abs(t)) && nnz(epMask(testMask)) == 0 && searchPix < size(neuriteMaskIn,1)
    maskDiff = nextMask & ~initMask; 
    initMask = nextMask;
    if nnz(maskDiff ) > 0
        currInds = find(maskDiff);
        [currY,currX] = ind2sub(size(imIn),currInds);
        currImg = double(imIn(currInds));
        newX = sum(currX.*currImg)/sum(currImg);
        newY = sum(currY.*currImg)/sum(currImg);
        x(t==tCount) = newX;
        y(t==tCount) = newY;
        searchPix = searchPixInit;
        testMask = imdilate(initMask,strel('disk',searchPix));
        nextMask = neuriteMask & testMask;
    else
        %%% grow the mask by a larger step
        searchPix = searchPix * 2;
        testMask = imdilate(initMask,strel('disk',searchPix));
        nextMask = neuriteMask & testMask;
    end
    tCount = tCount + tStep * searchPix;
end
