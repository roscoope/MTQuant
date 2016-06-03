%%% indivWormAnalysis.m
%%% Calculate the organization parameters for all indivdiual worm images in a set
%%% of directories.
%%%
%%% Input arguments
%%% lsFile = name of CSV file with line scans
%%% alpha1 = weight on MSE cost
%%% alpha2 = weight on cost of mislocalized MT starts
%%% alpha3 = weight on cost of difference in number of MT starts
%%% toRateImgs = if true, and if taskList includes calculating the org
%%%      params, then for every image, user will be asked to rate the image as
%%%      good (2), ok (1), or bad (0).
%%% toUseManualRPeaks = if true, displays the rLineScanF and the corresponding
%%%      identified MT minus ends, and allows the user to overwrite the number
%%%      of total peaks identified.  By default, verbose = false.%%% toPreproc
%%% toPreproc = if true, smooth and sharpen the green line scan before
%%%      analysis. 
%%% toUseRandRPeaks = if true (default), additional MT minus-ends
%%%      beyond the peaks in the red line scan are chosen randomly for increased
%%%      accuracy.
%%% roundLevel = level at which to round the green line scan up or down
%%%      (default is 0.5, i.e. normal rounding) when calculating the quantized
%%%      signal for cost calculations
%%% projFile = name of green maximum projection image file
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
%%%
%%% Output argument
%%% C = Cell array of org parameters for each worm.  This array becomes a row in 
%%%      the output table.  See documentation for details.

function C = calcHWrapper(lsFile,alpha1,alpha2,alpha3,toRateImgs,toUseManualRPeaks,toPreproc,...
    toUseRandRPeaks,roundLevel,projFile,toUseBlurCorr,toUseHalfMTs,distThresh,rPeakTol,rPeakCorr)

if ~exist('alpha1','var')
    alpha1 = [];
end
if ~exist('alpha2','var')
    alpha2 = [];
end
if ~exist('alpha3','var')
    alpha3 = [];
end
if ~exist('toUseBlurCorr','var')
    toUseBlurCorr = true;
end

[folder,name,ext]=fileparts(lsFile);
allLS = getInfNestedFileNames({[folder,'\']},[name,ext]);
C = [];
for i = 1:length(allLS)
    currLS = allLS{i};
    scansIn = csvread(currLS);
    gLineScan = scansIn(:,1);
    rLineScan = scansIn(:,2);
    rLineScanF = conv(rLineScan,ones(1,3)/3,'same');
    
    if toPreproc
        gLineScanF = conv(gLineScan,ones(1,5)/5,'same');
        gHF = fitModelGaussian(gLineScanF);
    else
        gHF = gLineScan;
    end
    gHF(gHF<0) = 0;
    
    rFileIn = strrep(projFile,'_g_','_r_');
    if toUseManualRPeaks
        maskFile = strrep(currLS,'LineScans.csv','Mask.tif');
        figure(3);imshow(maskFile)
        if exist(rFileIn,'file')
            rImage = imread(rFileIn);
        else
            rImage = [];
        end
        figure(4);imshow(linRescale(rImage)*8);
        [rPeaks,numMTs] = findPeaksWide(rLineScanF,rPeakTol,true,rImage,toUseRandRPeaks,rPeakCorr);
    else
        [rPeaks,numMTs] = findPeaksWide(rLineScanF,rPeakTol,false,[],toUseRandRPeaks,rPeakCorr);
    end
    
    if toRateImgs
        if exist(projFile,'file')
            figure(1);imshow(linRescale(imread(projFile))*2)
        end
        if exist(rFileIn,'file')
            figure(2);imshow(linRescale(imread(rFileIn))*8);
        end
        figure(3);subplot(2,1,1);plot(gLineScan);title('Green Line Scan');
        figure(3);subplot(2,1,2);plot(rLineScan);hold on;plot(rPeaks,rLineScan(rPeaks),'r*');hold off;title(['Red Line Scan, num red peaks = ',num2str(numMTs)]);
        rating = input('How would you rate this image?  (2 = good, 1 = ok, 0 = bad) ');
    else
        rating = 2;
    end
    
    stepArray = (linspace(max(gLineScan)/20,max(gLineScan),1000))';
    h = sweepHRange(stepArray,gHF,rPeaks,distThresh,alpha1,alpha2,alpha3,1,numMTs,roundLevel,toUseBlurCorr);
    [meanArrTime,stdArrTime,meanCvg,stdCvg,meanLen] = calcStats(gHF,rPeaks,h,toUseHalfMTs,numMTs);
    
    currStats = [rating,...
        round(max(gLineScan)),...
        round(mean(gLineScan)),...
        length(gLineScan),...
        numMTs,...
        roundToDec(meanArrTime,4),...
        roundToDec(stdArrTime,4),...
        round(h),...
        roundToDec(meanCvg,4),...
        roundToDec(stdCvg,4),...
        roundToDec(meanLen,4)];
    
    if i==1
        C = cell(length(allLS),length(currStats)+3);
    end
    
    [folder,name,ext] = fileparts(currLS);
    C(i,1) = {folder};
    C(i,2) = {[name,ext]};
    C(i,3) = {'unassigned'}; % placeholder for directory number; needs to be assigned outside of this loop
    C(i,4:end) = num2cell(currStats);
    
end
