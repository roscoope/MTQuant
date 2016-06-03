%%% readStackSignle.m
%%% This function reads a stack from fileIn and return the stack and its 
%%% corresponding a maximum projection
%%% 
%%% Input arguments
%%% fileIn = stack file.  This file is assumed to exist and contain a 16-bit stack.
%%%
%%% Output arguments
%%% stack = 3D vector of images
%%% stackSize = number of images in stack
%%% mp = maximum projection image of the stack
%%% inds = size of images mp.  Each entry corresponds to the stack slice
%%%      containing the maximum value.

function [stack, stackSize, mp, inds] = readStackSingle(fileIn)
stackSize = numel(imfinfo(fileIn));
for i = 1:stackSize
    stackIn = imread(fileIn,i);
    if i==1
        stack = zeros(size(stackIn,1),size(stackIn,2),stackSize);
    end
    stack(:,:,i) = stackIn;
end
[mp,inds] = max(stack,[],3);
mp = uint16(mp);
