%%% makeMask.m
%%% wrapper to make mask file
%%%
%%% Input arguments
%%% gFileIn = file name of green stack
%%% indivFileOut = string to prepend to the suffix "Mask.csv" when saving the mask files
%%% numLineScans = number of line scans to collect.  This parameter was hardly used 
%%%      and hence not thoroughly tested
%%% diPix = number of pixels by which to dilate the user-selected line
%%%
%%% Output argument
%%% maskFile = name of saved csv mask file
%%% rAligned = aligned red image 
%%%
%%% Output files (actually created in makeMaskLoop.m)
%%% *_Mask.csv = mask csv file (include mask, green/red background, etc)
%%% *_Mask.tif = mask image file

function [maskFile,rAligned] = makeMask(gFileIn,indivFileOut,numLineScans,diPix)

rFileIn = strrep(gFileIn,'_g_','_r_');
maskFileIn = strrep(gFileIn,'g_proj.tif',[indivFileOut,'Mask.csv']);
rAligned = makeManualMasks(gFileIn,rFileIn,maskFileIn,numLineScans,diPix);
if numLineScans > 1
    maskFile = strrep(maskFileIn,'Mask.csv','*Mask.csv');
else
    maskFile = maskFileIn;
end
