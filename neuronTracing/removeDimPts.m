%%% removeDimPts.m
%%% removes points in the line scan trace that are not part of the mask
function tOut = removeDimPts(maskIn,lineSumInds0,tIn,tStep)

ptsInMask = maskIn(lineSumInds0);

if tStep == 1
    t = tIn(end:-1:1);
    ptsInMask = ptsInMask(end:-1:1);
else
    t = tIn;
end

maskCount = 1;

currPt = ptsInMask(maskCount);

tOutTemp = t;

while ~currPt 
    tOutTemp = tOutTemp(2:end);
    maskCount = maskCount + 1;
    currPt = ptsInMask(maskCount);
end

if tStep == 1
    tOut = tOutTemp(end:-1:1);
else
    tOut = tOutTemp;
end

