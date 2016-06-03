%%% linRescale.m
%%% Linearly rescale the range of vIn to fall in [0,1].  Always returns a
%%% double in the range [0,1].

function vOut = linRescale(vIn)

v = double(vIn);

minV = min(v(:));
maxV = max(v(:));

vOut = (v-minV)/(maxV-minV);