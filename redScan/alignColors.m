%%% alignColors.m
%%% Find the best translation by which to align two color channels of an
%%% image.  Similarity metric used is correlation.
%%%
%%% Input arguments
%%% imIn = 3 color channel input image.  Can be uint8, uint16, or double.
%%%      The first color channel is shifted to align with the second.
%%% searchWindowX,searchWindowY,searchStepX,searchStepY (optional) = all
%%%      dictate how far to search for the alignment
%%%
%%% Output arguments
%%% imAlign = aligned image
%%% bestX,bestY = x,y offset of the best alignment

function [imAlign,bestX,bestY] = alignColors(imIn,searchWindowX,searchWindowY,searchStepX,searchStepY)
if nargin < 3
    searchWindowY = searchWindowX;
end

if nargin < 4
    searchStepX = 1;
end

if nargin < 5 
    searchStepY = searchStepX;
end

if isa(imIn,'uint8')
    inType = 'uint8';
    imIn = double(imIn)/255;
elseif isa(imIn,'uint16')
    inType = 'uint16';
    imIn = double(imIn)/4095;
elseif isa(imIn,'double')
    inType = 'double';
end

inA = imIn(:,:,2);
inB = imIn(:,:,1);

[h,w] = size(inB);

maxCorr = 0;
bestX = 0;
bestY = 0;
bestB = inB;

for i = searchWindowY(1):searchStepY:searchWindowY(2)
    if i < 0 % shift up
        yShiftedB = [inB(abs(i)+1:end,:); zeros(abs(i),w)];
    elseif i > 0
        yShiftedB = [zeros(i,w); inB(1:end-i,:)];        
    else
        yShiftedB = inB;
    end
        
    for j = searchWindowX(1):searchStepX:searchWindowX(2)
        if j < 0
            xyShiftedB = [yShiftedB(:,abs(j)+1:end) zeros(h,abs(j))];
        elseif j > 0
            xyShiftedB = [zeros(h,j) yShiftedB(:,1:end-j)];
        else
            xyShiftedB = yShiftedB;
        end
        
        currCorr = sum(sum(inA .* xyShiftedB));
        
        if currCorr > maxCorr
            maxCorr = currCorr;
            bestY = i;
            bestX = j;
            bestB = xyShiftedB;
        end
    end
end

imAlign = cat(3,bestB,inA,zeros(h,w));

if strcmp(inType,'uint8')
    imAlign = uint8(imAlign * 255);
elseif strcmp(inType,'uint16')
    imAlign = uint16(imAlign * 4095);
end
