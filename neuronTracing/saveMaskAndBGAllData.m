%%% saveMaskAndBGAllData.m
%%% Writes a mask csv file
%%% 
%%% Input arguments
%%% maskFile = file name to create (must end in ".csv")
%%% axonMask = mask image
%%% antEP = (x,y) end point referring to the end of the mask where MT minus-ends point
%%% gBackground, rBackground = green/red image background
%%% 
%%% Output files
%%% maskFile

function saveMaskAndBGAllData(maskFile,axonMask,antEP,gBackground,rBackground)

fileID = fopen(maskFile,'w');
if fileID == -1, return; end
fprintf(fileID,'%d \n',gBackground);
fprintf(fileID,'%d \n',rBackground);
fprintf(fileID,'%d %d \n',[antEP(2),antEP(1)]);

sa = size(axonMask);
fprintf(fileID,[repmat('%g,',1,sa(2)-1) '%g\n'],axonMask.');

fclose(fileID);