%%% makeProj.m
%%% Wrapper to make the maximum projection for a stack of images.  A green
%%% file must exist, but if a corresponding red file doesn't exist, the
%%% function simply ignores it.
%%%
%%% Input arguments
%%% gFileIn = file name of green stack
%%% gFileExt = string in green stack name to replace when green projection is written
%%% rFileExt = string to replace "gFileExt" with in green stack name to yield red stack name.
%%%      Also string in red stack name to replace when red projection is written
%%%
%%% Output argument
%%% gFile = file name of green stack
%%% 
%%% Output files
%%% *_g_proj.tif = green maximum projection image
%%% *_stackInds.csv = every entry in this file is the stack slick from which each pixel in g was selected
%%% *_r_proj.tif = red maximum projection image

function gFile = makeProj(gFileIn,gFileExt,rFileExt)
if exist(gFileIn,'file')
    gFile = strrep(gFileIn,gFileExt,'_g_proj.tif');
    [~, ~, gIn, gInds] = readStackSingle(gFileIn);
    imwrite(gIn,gFile);
    csvwrite(strrep(gFile,'_g_proj.tif','_stackInds.csv'),gInds);
else
    error(['Error while making a maximum projection: "',gFileIn,'" file does not exist.']);
end

rFileIn = strrep(gFileIn,gFileExt,rFileExt);
if exist(rFileIn,'file')
    rFile = strrep(rFileIn,rFileExt,'_r_proj.tif');
    [~, ~, rIn, ~] = readStackSingle(rFileIn);
    imwrite(rIn,rFile);
end

