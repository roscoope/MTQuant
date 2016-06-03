%%% emLoop.m
%%% Wrapper for distribution refinement block.  Independently refines the
%%% distributions of each organization parameter and the single MT
%%% brightness in input table T, and returns an updated table.

function emT = emLoop(T)

C = table2cell(T);
emC = C;

%%% Identify each animal's corresponding group
dirNums = cell2mat(C(:,3));
dirsToCompare = unique(dirNums);

%%% Determine which column each organization parameter is stored in
varNames = T.Properties.VariableNames;
LInd = find(strcmp('Avg_Length_Pixels',varNames));
SInd = find(strcmp('Mean_Spacing_Pixels_btwn_Dots',varNames));
CInd = find(strcmp('Avg_Coverage_MTs_per_Pixel',varNames));
HInd = find(strcmp('Single_MT_Brightness',varNames));

%%% Perform distribution refinement on each group independently
for i= 1:length(dirsToCompare)
    if nnz(ismember(dirNums,dirsToCompare(i))) > 1
        oldL = cell2mat(C(ismember(dirNums,dirsToCompare(i)),LInd));
        oldS = cell2mat(C(ismember(dirNums,dirsToCompare(i)),SInd));
        oldC = cell2mat(C(ismember(dirNums,dirsToCompare(i)),CInd));
        oldH = cell2mat(C(ismember(dirNums,dirsToCompare(i)),HInd));

        thresh = 0.001;
        [piL,muL,sigmaL,Ls,newL] = emLoop1Var(oldL,thresh);
        [piS,muS,sigmaS,Ss,newMeanS] = emLoop1Var(oldS,thresh);
        [piH,muH,sigmaH,Hs,newH] = emLoop1Var(oldH,thresh);
        [piC,muC,sigmaC,Cs,newC] = emLoop1Var(oldC,thresh);
        
        dataPointsL = newL;
        emC(ismember(dirNums,dirsToCompare(i)),LInd) = num2cell(dataPointsL);
        
        dataPointsS = newMeanS;
        emC(ismember(dirNums,dirsToCompare(i)),SInd) = num2cell(dataPointsS);
        
        dataPointsC = newC;
        emC(ismember(dirNums,dirsToCompare(i)),CInd) = num2cell(dataPointsC);
        
        dataPointsH = newH;
        emC(ismember(dirNums,dirsToCompare(i)),HInd) = num2cell(dataPointsH);
    end
end

emT = cell2table(emC,'VariableNames',varNames);
