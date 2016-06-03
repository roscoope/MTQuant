%%% fillInPoints.m
%%% This function takes a spline defined by ps and determines how to sample
%%% such that each value of ps(tOut) is separated by one pixel in either
%%% direction.

function tOut = fillInPoints(tIn,yIn,xIn,ps)

tOut = tIn;

xInt = xIn;
yInt = yIn;

allDists = sqrt((diff(round(xInt))).^2+(diff(round(yInt))).^2);

jumpLocs = find(allDists > sqrt(2));

%%% For each pair of points that are separated by more than one pixel in
%%% either direction, add more sample points.
for i = 1:length(jumpLocs)
    currT = [tIn(jumpLocs(i)) tIn(jumpLocs(i)+1)];
    currX = [xInt(jumpLocs(i)) xInt(jumpLocs(i)+1)];
    currY = [yInt(jumpLocs(i)) yInt(jumpLocs(i)+1)];
    currDists = sqrt((diff(round(currX))).^2+(diff(round(currY))).^2);
    currJumpLocs = find(currDists > sqrt(2));
    tStepInv = 1;
    while ~isempty(currJumpLocs)
        tStepInv = tStepInv + 1;
        newT = currT(1):1/tStepInv:currT(end);
        currPts = ppval(ps,newT);
        currX = currPts(1,:);
        currY = currPts(2,:);
        currDists = sqrt((diff(round(currX))).^2+(diff(round(currY))).^2);
        currJumpLocs = find(currDists > sqrt(2));
        
        currT = newT;
    end
    
    outInd1 = find(tOut == tIn(jumpLocs(i)),1);
    outInd2 = find(tOut == tIn(jumpLocs(i)+1),1);
    tOut = [tOut(1:outInd1-1) currT tOut(outInd2+1:end)];
end