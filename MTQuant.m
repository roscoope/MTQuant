%%% MTQuant.m
%%% Top-level function
%%% Example usage:  MTQuant({'../images/'},'output_data.csv','taskList',12);

function MTQuant(varargin)

%%% Add subfolders
addpath('singleMT\');
addpath('redScan\');
addpath('neuronTracing\');
addpath('misc');
addpath('em\');

%%% Parse input arguments
% The first argument must be a cell array of strings, where each string is another directory to analyze
% The second argument must be the base output file to write on
% The remaining arguments are based on <string, value> pairs

nargin = length(varargin);
if nargin < 2
    error('Error:  Not enough input arguments.');
elseif mod(nargin,2) == 1
    error('Error:  Mismatched input arguments.');
end

dirList = varargin{1};
if isempty(dirList) || ~iscellstr(dirList)
    error('Error:  Invalid directory list.');
end
for i = 1:length(dirList)
    currDir = dirList{i};
    if ~strcmp(currDir(end),'\') && ~strcmp(currDir(end),'/')
        currDir = [currDir, '/'];
    end
    dirList(i) = {currDir};
end

dataFileOut = [varargin{2},'.csv'];

%%% Default parameter settings
taskList = 15;
toEM = 1;
alpha1 = [];
alpha2 = [];
alpha3 = [];
indivFileOut = '';
gFileExt = '_w1488-single.TIF';
rFileExt = '_w2561-single.TIF';
verbose = 1;

%%% Internal parameter settings
toRateImgs = 0;
toAvg = 0;
toUseManualRPeaks = 0;
toPreproc = 0;
toUseRandRPeaks = 1;
toUseBlurCorr = 1;
numLineScans = 0;
roundLevel = 0.5;
toUseHalfMTs = 0;
distThresh = 3;
rPeakTol = 0.05;
diPix = 30;
rPeakCorr = 0.1;

for i = 3:2:nargin
    currStr = varargin{i};
    currVal = varargin{i+1};
    if strcmp(currStr,'taskList')
        if currVal > 15 || currVal < 1
            warning('Warning:  invalid "taskList" value, setting to default.')
        else
            taskList = currVal;
        end
    end
    eval([currStr,' = currVal;']);
end

%%% Individual Worm Analysis
T = indivWormAnalysis(dirList,taskList,alpha1,alpha2,alpha3,indivFileOut,gFileExt,rFileExt,...
    toRateImgs,toAvg,toUseManualRPeaks,toPreproc,toUseRandRPeaks,numLineScans,roundLevel,...
    verbose,toUseBlurCorr,toUseHalfMTs,distThresh,rPeakTol,diPix,rPeakCorr);

%%% Consolidate the results if the previous function returned anything
if ~isempty(T)
    %%% If the images are rated, then group them accordingly.
    if toRateImgs
        ratings = T(:,4);
        Tarray = cell(3,1);
        Tarray(1) = {T(ratings==2,:)};
        Tarray(2) = {T(ismember(ratings,[1,2]),:)};
        Tarray(3) = {T};
        writeArray = {'_2';'_12';'_012'};
    else
        Tarray = {T};
        writeArray = {'_2'};
    end
    
    %%% Apply Distribution Refinement
    if toEM
        emT = cellfun(@emLoop,Tarray,'UniformOutput',false);
    else
        emT = T;
    end
    
    %%% Create a grouped file for easy comparison of populations
    groupedT = cellfun(@makeGroupedData,emT,'UniformOutput',false);
    
    %%% Write out the files
    [folder,name,ext] = fileparts(dataFileOut);
    outputFiles = strcat(folder,'\',indivFileOut,name,writeArray,ext);
    cellfun(@writetable,emT,outputFiles);
    cellfun(@writetable,groupedT,strrep(outputFiles,'.csv','_grouped.csv'));
end