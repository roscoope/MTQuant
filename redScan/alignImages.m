%%% alignImages.m
%%% Wrapper file to align two separate images
%%%
%%% Input arguments
%%% gIn = the stationary image
%%% rIn = the image to be translated in order to be aligned with gIn
%%%
%%% Output arguments
%%% g = the stationary image (same as input)
%%% r = the aligned image

function [g,r] = alignImages(gIn,rIn)

[h,w] = size(rIn);

imIn = cat(3,linRescale(rIn)*4,linRescale(gIn)*2,zeros(512));
[~,bestX,bestY] = alignColors(imIn,[-5 5],[-5 5],1,1);

if bestY < 0 % shift up
    yShiftedB = [rIn(abs(bestY)+1:end,:); zeros(abs(bestY),w)];
elseif bestY > 0
    yShiftedB = [zeros(bestY,w); rIn(1:end-bestY,:)];
else
    yShiftedB = rIn;
end

if bestX < 0
    xyShiftedB = [yShiftedB(:,abs(bestX)+1:end) zeros(h,abs(bestX))];
elseif bestX > 0
    xyShiftedB = [zeros(h,bestX) yShiftedB(:,1:end-bestX)];
else
    xyShiftedB = yShiftedB;
end

r = xyShiftedB;
g = gIn;

