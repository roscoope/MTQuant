%%% stepCost.m
%%% Calculate cost for one possible single MT brightness.
%%%
%%% Input arguments
%%% currH = single MT brightness
%%% gLineScan = green line scan
%%% rPeaksIn = vector of pixel locations of MT minus-ends
%%% distThresh = number of allowable pixels between a step up in the
%%%      quantized signal and a MT minus-end
%%% numMTs = number of MT minus-ends.  This number is the length of rPeaksIn except in two cases:
%%%      1.  If the user entered a number of MT minus-ends when analyzing this worm, then numMTs is
%%%          the number entered by the user
%%%      2.  If randomness was not used to identify the minus-ends, then numMTs is 
%%%          twice the length of rPeaks as a first order approximation of the true number of microtubules
%%% roundLevel = level at which to round the green line scan up or down
%%%      (default is 0.5, i.e. normal rounding) when calculating the quantized
%%%      signal for cost calculations
%%% toUseBlurCorr = if true, we assume some steps up are lost in the quantized signal due to
%%%      overlapping MT starts and ends thta blur together.
%%%
%%% Output arguments
%%% c1 = MSE cost
%%% c2 = cost of mislocalized steps up
%%% c3 = cost of difference in number of steps up

function [c1,c2,c3] = stepCost(currH,gLineScan,rPeaksIn,distThresh,numMTs,roundLevel,toUseBlurCorr)

N = numMTs;

%%% Quantize the signal
if ~exist('roundLevel','var')
    bScan= round(gLineScan/currH);
else
    rScan = gLineScan/currH-floor(gLineScan/currH);
    ceilInds = rScan >= roundLevel;
    floorInds = rScan < roundLevel;
    bScan = zeros(size(gLineScan));
    bScan(ceilInds) = ceil(gLineScan(ceilInds)/currH);
    bScan(floorInds) = floor(gLineScan(floorInds)/currH);
end

c1 = norm(gLineScan-currH*bScan,1);

%%% Identify location of steps up in the quantized signal
bDiff = diff(bScan);
stepsUp = find(bDiff>0);
multUps = find(bDiff>1);
for i = 1:length(multUps)
    stepsUp = [stepsUp; multUps(i)*ones(bDiff(i),1)];
end
stepsUp = [stepsUp;zeros(bScan(1),1)];

numSteps = length(stepsUp);
if numSteps > 0
    %%% Calculate the distances from each quantized step up to a MT minus-end
    dists = abs(repmat(rPeaksIn(:),1,length(stepsUp))-repmat((stepsUp(:))',length(rPeaksIn),1));
    [vals,inds] = min(dists,[],1);
    goodUpLocs = inds(vals<=distThresh);
    numGoodUps = length(unique(goodUpLocs));
    numBadUps = numSteps - numGoodUps;
    c2 = numBadUps;
    
    %%% Calculate the difference in total number of MTs
    if toUseBlurCorr
        numLoss = N*2/length(gLineScan);
    else
        numLoss = 0;
    end
    c3 = (numSteps-(1-numLoss)*N)^2;
else
    c2 = 0;
    c3 = N^2;
end