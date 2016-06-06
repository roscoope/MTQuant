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
LInd = find(strcmp('Avg_Length',varNames));
SInd = find(strcmp('Avg_Spacing',varNames));
CInd = find(strcmp('Avg_Coverage',varNames));
HInd = find(strcmp('Single_MT_Brightness',varNames));

%%% Perform distribution refinement on each group independently
for i= 1:length(dirsToCompare)
    if nnz(ismember(dirNums,dirsToCompare(i))) > 1
        currDirs = ismember(dirNums,dirsToCompare(i));
        
        Ldirs = currDirs & isfinite(cell2mat(C(:,LInd)));
        oldL = cell2mat(C(Ldirs,LInd));
        
        Sdirs = currDirs & isfinite(cell2mat(C(:,SInd)));
        oldS = cell2mat(C(Sdirs,SInd));
        
        Cdirs = currDirs & isfinite(cell2mat(C(:,CInd)));
        oldC = cell2mat(C(Cdirs,CInd));
        
        Hdirs = currDirs & isfinite(cell2mat(C(:,HInd)));
        oldH = cell2mat(C(Hdirs,HInd));
        
        thresh = 0.01;
        [piL,muL,sigmaL,Ls,newL] = emLoop1Var(oldL,thresh);
        [piS,muS,sigmaS,Ss,newMeanS] = emLoop1Var(oldS,thresh);
        [piH,muH,sigmaH,Hs,newH] = emLoop1Var(oldH,thresh);
        [piC,muC,sigmaC,Cs,newC] = emLoop1Var(oldC,thresh);
        
        dataPointsL = newL;
        emC(Ldirs,LInd) = num2cell(dataPointsL);
        
        dataPointsS = newMeanS;
        emC(Sdirs,SInd) = num2cell(dataPointsS);
        
        dataPointsC = newC;
        emC(Cdirs,CInd) = num2cell(dataPointsC);
        
        dataPointsH = newH;
        emC(Hdirs,HInd) = num2cell(dataPointsH);
    end
end

emT = cell2table(emC,'VariableNames',varNames);
