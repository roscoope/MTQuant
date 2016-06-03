%%% loadMaskAndBG.m
%%% Loads the information from a CSV mask file
%%%
%%% Input argument
%%% maskFile = CSV file of mask information
%%% 
%%% Output argument
%%% gBackground = green channel intensity background 
%%% rBackground = red channel intensity background.  If there was no
%%%      corresponding red image, this value is 0
%%% postEP = x,y location of the mask end point pointing to the minus ends
%%% axonMask = mask image file

function [gBackground,rBackground,postEP,axonMask] = loadMaskAndBG(maskFile)

data = csvread(maskFile);

gBackground = data(1,1);
rBackground = data(2,1);
postEP2 = data(3,1);
postEP1 = data(3,2);
postEP = [postEP1;postEP2];

axonMask = data(4:end,:);
