%%% findPeaksWide.m
%%% Identify the locations of MT minus-ends assuming they are spaced by a
%%% Poisson random process.
%%%
%%% Input Arguments
%%% rLineScanF = smoothed red line scan
%%% rPeakTol (optional) = tolerance of peak selection.  This value is multiplied
%%%      by the maximum value of rLineScanF.  For a peak to be considered real
%%%      (and not noise), the difference between the peak and the nearest valley
%%%      must be at least tol*max(rLineScanF).  A higher value for tol means
%%%      fewer peaks are identified.  By default, tol = 0.05.
%%% verbose (optional) = if true, displays the rLineScanF and the corresponding
%%%      identified MT minus ends, and allows the user to overwrite the number
%%%      of total peaks identified.  By default, verbose = false.
%%% rImage (optional) = in verbose mode, if rImage exists, it is displayed
%%%      to the user to aid in counting dots.
%%% toUseRand (optional) = if true (default), additional MT minus-ends
%%%      beyond the peaks in the red line scan are chosen randomly for increased
%%%      accuracy.
%%%
%%% Output Arguments
%%% rPeaks = vector of pixel locations of every deteced minus-end in rLineScanF.
%%% numMTs = number of MT minus-ends.  This number is the length of rPeaks except in two cases:
%%%      1.  If the user entered a number of MT minus-ends in verbose mode, then numMTs is
%%%          the number entered by the user
%%%      2.  If toUseRand is FALSE, then numMTs is twice the length of rPeaks as a first
%%%          order approximation of the true number of microtubules

function [rPeaks,numMTs] = findPeaksWide(rLineScanF,tol,verbose,rImage,toUseRand,rPeakCorr)

if ~exist('verbose','var')
    verbose = true;
end
if ~exist('tol','var')
    tol = 0.05;
end
if ~exist('toUseRand','var')
    toUseRand= true;
end
if ~exist('rPeakCorr','var')
    rPeakCorr = 10;
end

%%% Use MATLAB's findpeaks function to identify local maxima in the input signal
[pks,pLocs] = findpeaks(rLineScanF);
maxVal = max(rLineScanF);

%%% Use MATLAB's findpeaks function to identify local minima in the input signal
[~,vLocs] = findpeaks(maxVal-rLineScanF);

realPLocs = [];

%%% For each potential peak, determine whether it is actuall 0, 1, or 2 MT minus-ends
for i = 1:length(pks)
    %%% First calculate the intensity difference between the peak and the
    %%% nearest, shallowest valley on either side
    prevValLoc = vLocs(find(pLocs(i)-vLocs > 0,1,'last'));
    nextValLoc = vLocs(find(pLocs(i)-vLocs < 0,1,'first'));
    if isempty(prevValLoc)
        prevValLoc = 1;
    end
    if isempty(nextValLoc)
        nextValLoc = length(rLineScanF);
    end
    nearestMin1 = rLineScanF(prevValLoc);
    nearestMin2 = rLineScanF(nextValLoc);
    peakDiff = pks(i) - min(nearestMin1,nearestMin2);
    %%% Only consider this peak if it is sufficiently tall
    if peakDiff > maxVal*tol
        %%% How wide is the peak?  How likely is it to be two minus-ends?
        currSeg = rLineScanF(prevValLoc:nextValLoc);
        histVals =(1:length(currSeg))' .* currSeg;
        mu = sum(histVals)/sum(currSeg); %%% weighted average of intensities of rLineScanF around this peak
        currSig = sqrt( sum(currSeg .* ((1:length(currSeg))'-mu).^2)/sum(currSeg)); %%% weighted std dev of intensities of rLineScanF around this peak
        sigProb = sigmf(currSig,[2 3.5]);  %%% Use a sigmoid function to make the width more pronounced
        
        %%% How tall is the peak?  How likely is it to be two minus-ends?
        hProb = pks(i)/maxVal;
        
        %%% Calculate a total probability
        alpha = rPeakCorr;
        beta = rPeakCorr;
        if toUseRand
            probOfTwo = beta*sigProb^2+alpha*hProb^2;
        else
            probOfTwo = 0;
        end
        if probOfTwo < 0
            probOfTwo = 0;
        elseif probOfTwo > 1
            probOfTwo = 1;
        end
        isTwoPks = binornd(1,probOfTwo);
        
        if isTwoPks
            %%% Assume this peak is actually two MT minus-ends.  Then readjust
            %%% the locations to be spread over the highest point of the peak.
            newPkLocs = [max(pLocs(i)-2,1);min(pLocs(i)+2,length(rLineScanF))];
            [~,ind] = max(rLineScanF(newPkLocs));
            newPkLoc = newPkLocs(ind);
            realPLocs = [realPLocs; pLocs(i); newPkLoc];
        else
            realPLocs = [realPLocs; pLocs(i)];
        end
    end
end

rPeaks = sort(realPLocs);

%%% Allow the user to overwrite the number of detected puncta
if verbose
    display(horzcat('Total Patronin Puncta Found:  ',num2str(length(rPeaks))));
    display(' ');
    
    if exist('rImage','var') && ~isempty(rImage)
        figure(5);imshow(linRescale(rImage)*4);
    end
    figure(4);
    plot(rLineScanF)
    hold on;
    stem(rPeaks,rLineScanF(rPeaks),'r','filled','MarkerSize',2);
    hold off;
    title(horzcat('Init Pat Puncta = ',num2str(length(pks)),', End Pat Puncta = ',num2str(length(rPeaks)),', Sig Len = ',num2str(length(rLineScanF))));
    
    s = input('Is this correct? (lowercase "y" for yes) ','s');
    if s=='y'
        numMTs = length(rPeaks);
    else
        numMTs = input('How many petronin puncta do you see? ');
    end
    
    density = numMTs / length(rLineScanF);
    display(horzcat('Patronin Density = ',num2str(density),' dots/pixel'));
    display(horzcat('Signal Length is ',num2str(length(rLineScanF)),' pixels'));
else
    numMTs = length(rPeaks);
end

