%%% makeScan.m
%%% wrapper file to make the line scan
%%%
%%% Input arguments
%%% maskFile = csv mask file
%%% indivFileOut = string to prepend to the suffix "LineScans.csv" when saving the scan files
%%% toAvg = if true, the output line scan is the average of pixels
%%%      perpendicular to the spline at every point.  If false, the output line
%%%      scan is the sum of the pixels perpendicular to the spline.  SUM is
%%%      recommended
%%% rAligned = aligned red image 
%%%
%%% Output arguments
%%% lsFile = name of line scan CSV file
%%%
%%% Output files (actually created in lineScanWrapper.m)
%%% *LineScans.csv = CSV file with two vectors:  green line scan and red line scan
%%% *LineScanInds.csv = CSV file with nterpolated locations of the pixels summed to
%%%      generate the line scan.  Its dimensions are length(lineScan) X 402 
%%%      The first 201 columns refer to the y-coordinate of each point, and
%%%      the second set of 201 columns refers to the x-coordinate.  So the
%%%      starting (x,y) location of the spline is in (1,302) and (1,101) in
%%%      this csv file

function lsFile = makeScan(maskFile,indivFileOut,toAvg,rAligned)

[folder,name,ext]=fileparts(maskFile);
allMasks = getInfNestedFileNames({[folder,'\']},[name,ext]);
for i = 1:length(allMasks)
    currMask = allMasks{i};
    gFileIn = strrep(currMask,[indivFileOut,'Mask.csv'],'g_proj.tif');
    rFileIn = strrep(gFileIn,'_g_','_r_');
    toShowFigs = false;
    toPrintScans = true;
    lineScanWrapper(gFileIn,rFileIn,currMask,toAvg,toShowFigs,toPrintScans,rAligned);
end
lsFile = strrep(maskFile,'Mask.csv','LineScans.csv');