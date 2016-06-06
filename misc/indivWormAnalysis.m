%%% indivWormAnalysis.m
%%% Calculate the organization parameters for all indivdiual worm images in a set
%%% of directories.
%%%
%%% Input arguments
%%% dirLists = cell array of strings, where each string is another directory to analyze
%%% taskList
%%% alpha1 = weight on MSE cost
%%% alpha2 = weight on cost of mislocalized MT starts
%%% alpha3 = weight on cost of difference in number of MT starts
%%% indivFileOut = string to prepend to the suffix "Mask.csv" when saving the mask files
%%% gFileExt = string in green stack name to replace when green projection is written
%%% rFileExt = string to replace "gFileExt" with in green stack name to yield red stack name.
%%%      Also string in red stack name to replace when red projection is written
%%% toRateImgs = if true, and if taskList includes calculating the org
%%%      params, then for every image, user will be asked to rate the image as
%%%      good (2), ok (1), or bad (0).
%%% toAvg = if true, the output line scan is the average of pixels
%%%      perpendicular to the spline at every point.  If false, the output line
%%%      scan is the sum of the pixels perpendicular to the spline.  SUM is
%%%      recommended
%%% toUseManualRPeaks = if true, displays the rLineScanF and the corresponding
%%%      identified MT minus ends, and allows the user to overwrite the number
%%%      of total peaks identified.  By default, verbose = false.%%% toPreproc
%%% toPreproc = if true, smooth and sharpen the green line scan before
%%%      analysis.
%%% toUseRandRPeaks = if true (default), additional MT minus-ends
%%%      beyond the peaks in the red line scan are chosen randomly for increased
%%%      accuracy.
%%% numLineScans = number of line scans to collect.  This parameter was hardly used
%%%      and hence not thoroughly tested
%%% roundLevel = level at which to round the green line scan up or down
%%%      (default is 0.5, i.e. normal rounding) when calculating the quantized
%%%      signal for cost calculations
%%% verbose = 2 for a display message for every animal, 0 for occasional displays, 0 for no output
%%% toUseBlurCorr = if true, we assume some steps up are lost in the quantized signal due to
%%%      overlapping MT starts and ends thta blur together.
%%% toUseHalfMTs = correction for the beginning and end of the signal 
%%%      Makes very inconsequential changes; can be ignored
%%% distThresh = number of allowable pixels between a step up in the
%%%      quantized signal and a MT minus-end
%%% rPeakTol = tolerance of peak selection.  This value is multiplied
%%%      by the maximum value of rLineScanF.  For a peak to be considered real
%%%      (and not noise), the difference between the peak and the nearest valley
%%%      must be at least tol*max(rLineScanF).  A higher value for tol means
%%%      fewer peaks are identified.  By default, tol = 0.01.
%%% diPix = number of pixels by which to dilate the user-selected line
%%% rPeakCorr = Weight on Bernouli random variable that decides if a single 
%%%      red dot is 1 or 2 MT minus-ends. As coverage increases, this value 
%%%      should increase as well (up to 20 if necessary)
%%%
%%% Output argument
%%% T = table of org parameters for each worm.  See documentation for details.
%%%
%%% Output files (created in various subfunctions)
%%% *_g_proj.tif = green maximum projection image
%%% *_stackInds.csv = every entry in this file is the stack slick from which each pixel in g was selected
%%% *_r_proj.tif = red maximum projection image
%%% *_Mask.csv = mask csv file (include mask, green/red background, etc)
%%% *_Mask.tif = mask image file
%%% *LineScans.csv = CSV file with two vectors:  green line scan and red line scan
%%% *LineScanInds.csv = CSV file with nterpolated locations of the pixels summed to
%%%      generate the line scan.  Its dimensions are length(lineScan) X 402
%%%      The first 201 columns refer to the y-coordinate of each point, and
%%%      the second set of 201 columns refers to the x-coordinate.  So the
%%%      starting (x,y) location of the spline is in (1,302) and (1,101) in
%%%      this csv file

function T = indivWormAnalysis(dirList,taskList,alpha1,alpha2,alpha3,indivFileOut,gFileExt,rFileExt,...
    toRateImgs,toAvg,toUseManualRPeaks,toPreproc,toUseRandRPeaks,numLineScans,roundLevel,...
    verbose,toUseBlurCorr,toUseHalfMTs,distThresh,rPeakTol,diPix,rPeakCorr)

taskStr = dec2bin(taskList,4);
toMakeProj = str2num(taskStr(end));
toMakeMask = str2num(taskStr(end-1));
toMakeScan = str2num(taskStr(end-2));
toCalcH = str2num(taskStr(end-3));

if toMakeProj
    initFileNames = getInfNestedFileNames(dirList,['*',gFileExt]);
elseif toMakeMask
    initFileNames = getInfNestedFileNames(dirList,'*_g_proj.tif');
elseif toMakeScan
    initFileNames = getInfNestedFileNames(dirList,['*',indivFileOut,'Mask.csv']);
elseif toCalcH
    initFileNames = getInfNestedFileNames(dirList,['*',indivFileOut,'LineScans.csv']);
end    

%%% Loop over all identified images
for i = 1:length(initFileNames)
    gFileIn = initFileNames{i};
    if (verbose==2) || (verbose==1 && mod(i,50)==0)
        disp(' ');
        disp(['worm ',num2str(i),' of ',num2str(length(initFileNames)),':  ',gFileIn]);
    end
    
    %%% Make the maximum projection images
    if toMakeProj
        projFile = makeProj(gFileIn,gFileExt,rFileExt);
    else
        projFile = gFileIn;
    end
    
    %%% Make the mask images
    rAligned = [];
    if toMakeMask
        [maskFile,rAligned] = makeMask(projFile,indivFileOut,numLineScans,diPix);
    else
        %projFile = strrep(gFileIn,gFileExt,'_g_proj.tif');
        maskFile = gFileIn;
        projFile = strrep(maskFile,[indivFileOut,'Mask.csv'],'g_proj.tif');
    end
    
    %%% Make the line scans
    if toMakeScan
        lsFile = makeScan(maskFile,indivFileOut,toAvg,rAligned);
    else
        lsFile = gFileIn;
        projFile = strrep(lsFile,[indivFileOut,'LineScans.csv'],'g_proj.tif');
    end
    
    close all
    %%% Calculate the organization parameters for each worm
    if toCalcH
        if ~exist('lsFile','var')
        end
        currC = calcHWrapper(lsFile,alpha1,alpha2,alpha3,toRateImgs,toUseManualRPeaks,toPreproc,...
            toUseRandRPeaks,roundLevel,projFile,toUseBlurCorr,toUseHalfMTs,distThresh,rPeakTol,rPeakCorr);
        if ~isempty(currC)
            if ~exist('C','var')
                C = cell(length(initFileNames),length(currC));
            end
            C(i,:) = currC;
        end
    end
end

toRemove = cellfun(@isempty,C(:,1));
C(toRemove,:) = [];
usedFileNames = initFileNames;
usedFileNames(toRemove) = [];

%%% Assign group numbers based on directory structure
if toCalcH
    if length(dirList) == 1
        [dirNums,~] = mapFilesToTopDir(dirList{1},usedFileNames);
        if isempty(dirNums)
            dirNums = ones(size(usedFileNames));
        end
    else
        dirInds = cellfun(@(y) find(cellfun(@(x) ~isempty(x),strfind(usedFileNames,y))),dirList,'uniformoutput',false);
        dirNums = zeros(size(usedFileNames));
        for j = 1:length(dirList)
            dirNums(dirInds{j}) = j;
        end
    end
    C(:,3) = num2cell(dirNums);
    varNames = {'Directory','DataFile','DirNum','Rating',...   % 1, 2, 3, 4
        'Max_G',...                                            % 5
        'Avg_G',...                                           % 6
        'Scan_Length',...                               % 7
        'Num_MTs',...                                          % 8
        'Avg_Spacing',...                    % 9
        'Std_Dev_Spacing',...                 %10
        'Single_MT_Brightness',...                             %11
        'Avg_Coverage',...                       %12
        'Std_Dev_Coverage',...                   %13
        'Avg_Length'};                                  %14
    T = cell2table(C,'VariableNames',varNames);
else
    T = [];
end