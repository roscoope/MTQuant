%%% sweetHRange.m
%%% Test all possible single MT brightnesses and select the one with the
%%% minimum cost.
%%%
%%% Input arguments
%%% allH = array of possible single MT brightness.  These range from 5% to
%%%      100% of max(gLineScan)
%%% gLineScan = green line scan
%%% rPeaksIn = vector of pixel locations of MT minus-ends
%%% distThresh = number of allowable pixels between a step up in the
%%%      quantized signal and a MT minus-end
%%% alpha1 = weight on MSE cost
%%% alpha2 = weight on cost of mislocalized MT starts
%%% alpha3 = weight on cost of difference in number of MT starts
%%% toSmooth = if true, smooth the total cost before selecting the minimum.
%%%      If false, there are too many local minima to easily identify the
%%%      global minimum.
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
%%% h = the best single MT brightness
%%% totalErrNotSmooth = weighted sum of the three costs
%%% c1 = MSE cost
%%% c2 = cost of mislocalized steps up
%%% c3 = cost of difference in number of steps up

function [h,totalErrNotSmooth,c1,c2,c3] = sweepHRange(allH,gLineScan,rPeaksIn,...
    distThresh,alpha1,alpha2,alpha3,toSmooth,numMTs,roundLevel,toUseBlurCorr)

if ~exist('alpha1','var') || isempty(alpha1)
    alpha1 = 0.26/mean(gLineScan);
end

if ~exist('alpha2','var') || isempty(alpha2)
    alpha2 = 0.0013;
end

if ~exist('alpha3','var') || isempty(alpha3)
    alpha3 = 1;
end

if ~exist('distThresh','var') || isempty(distThresh)
    distThresh = 3;
end

if ~exist('toSmooth','var') || isempty(toSmooth)
    toSmooth = 0;
end

if ~exist('numMTs','var') || isempty(numMTs)
    numMTs = length(rPeaksIn);
end

if ~exist('roundLevel','var') || isempty(roundLevel)
    roundLevel = 0.5;
end

c1= zeros(size(allH));
c2= zeros(size(allH));
c3= zeros(size(allH));

for i = 1:length(allH)
    currH = allH(i);
    [currC1,currC2,currC3] = stepCost(currH,gLineScan,rPeaksIn,distThresh,numMTs,roundLevel,toUseBlurCorr);
    c1(i) = currC1;
    c2(i) = currC2;
    c3(i) = currC3;
end

totalErrNotSmooth = alpha1*c1+alpha2*c2+alpha3*c3;

%%% Smooth the cost to find the global minimum
if toSmooth
    temp = [totalErrNotSmooth(1)*ones(100,1);totalErrNotSmooth;totalErrNotSmooth(end)*ones(100,1)];
    temp2 = conv(temp,1/51*ones(1,51),'same');
    totalErr = temp2(101:end-100);
else
    totalErr = totalErrNotSmooth;
end
[~,ind] = min(totalErr);
h = allH(ind);
