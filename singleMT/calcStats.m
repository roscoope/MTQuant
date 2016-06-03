%%% calcStats.m
%%% Calculate the organization parameters for one animal
%%%
%%% Input arguments
%%% gHF = green line scan
%%% rPeaks = vector of MT minus-end locations (in pixels)
%%% h = single MT brightness
%%% toUseHalfMTs = correction for the beginning and end of the signal 
%%%      Makes very inconsequential changes; can be ignored
%%% numMTs = number of microtubules detected in the worm
%%%
%%% Output arguments
%%% meanArrTime = average number of pixels between each minus-end
%%% stdArrTime = std dev of number of pixels between each minus-end
%%% meanCvg = average number of MTs in neuron cross-section
%%% stdCvg = std dev of number of MTs in neuron cross-section
%%% meanLen = average MT length in pixels

function [meanArrTime,stdArrTime,meanCvg,stdCvg,meanLen] = calcStats(gHF,rPeaks,h,toUseHalfMTs,numMTs)

lsLen = length(gHF);

upLocs = diff(sort(rPeaks,'ascend'));
meanArrTime = mean(upLocs);
stdArrTime = std(upLocs);

totalCvg = sum(gHF) / h;
meanCvg = totalCvg / lsLen;
stdCvg = std(gHF/h);

if toUseHalfMTs == 1
    num1 = round(gHF(1)/h);
    num2 = round(gHF(end)/h);
    meanLen = totalCvg / (numMTs - num2 + 0.5*(num1+num2)) ;
elseif toUseHalfMTs == 2
    num1 = round(gHF(1)/h);
    meanLen = totalCvg / (numMTs + num1);
else
    meanLen = totalCvg / numMTs;
end

