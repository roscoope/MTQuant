%%% makeMaskLoop.m
%%% Ask for user input and trace the mask
%%%
%%% Inupt argument
%%% gIn = green input imate
%%% rIn = red input image
%%% diPix = number of pixels by which to dilate the line traced by the user
%%%      to ensure we cover the whole neuron
%%% maskFile = name of the file to save the mask.  Must be either ".tif" or ".csv"
%%% gBackground (optional) = green image background
%%% rBackground (optional) = red image background
%%% numLineScans = number of line scans to collect.  This parameter was hardly used 
%%%      and hence not thoroughly tested
%%%
%%% Output argument
%%% gBackground = green image background
%%% rBackground = red image background
%%%
%%% Output files
%%% *_Mask.csv = mask csv file (include mask, green/red background, etc)
%%% *_Mask.tif = mask image file

function [gBackground,rBackground] = makeMaskLoop(gIn,rIn,diPix,maskFile,gBackground,rBackground,numLineScans)

keepTrying = true;
while keepTrying
    [dendriteMask,postEP,imToShow] = findAxonLine(gIn,diPix,numLineScans);
    if ~iscell(dendriteMask)
        dendriteMask = {dendriteMask};
    end
    s2 = input('Are you happy with this trace?  (lowercase "n" for no) ','s');
    if s2 ~= 'n'
        keepTrying = false;
    end
end
keepTrying = true;
while keepTrying
    figure(1);imshow(imToShow);hold on;plot(postEP(2),postEP(1),'gp','MarkerSize',14,'MarkerFaceColor','g');hold off;
    title('The green star marks the MINUS END of the patronin.  Posterior end for the axon, Anterior end for the dendrite.');
    xlabel('If the green star is correct, hit ENTER.  If not, click on the appropriate end of the neurite and then hit ENTER.')
    display('The green star marks the MINUS END of the patronin.  Posterior end for the axon, Anterior end for the dendrite.');
    display('If the green star is correct, hit ENTER.  If not, click on the appropriate end of the neurite and then hit ENTER.')
    [newX,newY] = ginput(1);
    if ~isempty(newX)
        postEP = [newY(1);newX(1)];
    else
        keepTrying = false;
    end
end
if ~exist('gBackground','var') || isempty(gBackground)
    display('Select the green background.');
    [gBackground,bboxOut] = getBackground(gIn);
    if ~isempty(rIn)
        display('Select the red background.');
        rBackground = getBackground(rIn,bboxOut,true);
    else
        rBackground = [];
    end
end

for i = 1:length(dendriteMask)
    currDM = dendriteMask{i};
    if numLineScans > 1
        currMF = strrep(maskFile,'Mask',[num2str(i),'Mask']);
    else
        currMF = maskFile;
    end
    
    if strcmp(currMF(end-3:end),'.csv')
        imwrite(double(currDM),strcat(currMF(1:end-4),'.tif'));
        saveMaskAndBGAllData(currMF,currDM,postEP,gBackground,rBackground);
    else
        imwrite(double(currDM),currMF);
        saveMaskAndBGAllData(strcat(currMF(1:end-4),'.csv'),currDM,postEP,gBackground,rBackground);
    end
end