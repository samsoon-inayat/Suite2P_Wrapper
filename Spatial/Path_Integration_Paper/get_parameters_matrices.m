function [out,all_out] = get_parameters_matrices(aei,selAnimals)

fileName = fullfile(pwd,'matFiles','parameters_matrics.mat');

if nargin == 0
    out = load(fileName);
    return
end
% 
% if ~exist('aei','var')
%     aei = evalin('base','ei10');
%     selAnimals = [1,2];
% %     owr = 1;
% end

varNames = {'info_metrics.ShannonMI_Zsh','place_field_properties.amp','place_field_properties.pws','place_field_properties.centers','place_field_properties.rs'};
varNamesDH = {'zMIs','fFR','fwidths','fcenters','frs'};

if iscell(aei)
selAnimals = 1:length(aei);
fileName = fullfile(pwd,'matFiles','parameters_matrics.mat');

% if owr == 0
%     out = load(fileName);
%     return
% end
% % 

selCells = 'All';
planeNumbers = 'All';
maxDistTime = [142 15];


stimMarkers = {'air','air','belt','airI'};
rasterTypes = {'dist','time','dist','time'};
contextNumbers = [1 2 3 4];


for an = 1:length(selAnimals)
    tei = aei(selAnimals(an));
    if isempty(tei{1})
        continue;
    end
    rFs{an} = tei{1}.recordingFolder;
    for vi = 1:length(varNames)
        thisVarDH = varNamesDH{vi};
        cmdTxt = sprintf('%s_c = [];',thisVarDH);
        eval(cmdTxt);
    end
    for ci = 1:length(contextNumbers)
        contextNumber = contextNumbers(ci);
        for si = 1:length(stimMarkers)
            disp([an ci si]);
            stimMarker = stimMarkers{si};
            rasterType = rasterTypes{si};
            for vi = 1:length(varNames)
                thisVarDH = varNamesDH{vi};
                cmdTxt = sprintf('%s = [];',thisVarDH);
                eval(cmdTxt);
            end
            for vi = 1:length(varNames)
                thisVar = varNames{vi};
                thisVarDH = varNamesDH{vi};
                cmdTxt = sprintf('[%s cns areCells] = getParamValues(''%s'',tei,planeNumbers,contextNumber,stimMarker,rasterType,selCells,maxDistTime);',thisVarDH,thisVar);
                eval(cmdTxt);
                cmdTxt = sprintf('%s_c(ci,si,:) = %s;',thisVarDH,thisVarDH);
                eval(cmdTxt);
            end
        end
    end
    out.all_areCells{an} = areCells;
    out.all_cns{an} = cns;
    for vi = 1:length(varNames)
        thisVar = varNames{vi};
        thisVarDH = varNamesDH{vi};
        cmdTxt = sprintf('out.all_%s{an} = %s_c;',thisVarDH,thisVarDH);
        eval(cmdTxt);
    end
end
out.recordingFolders = rFs;
out.selCells = selCells;
out.planeNumbers = planeNumbers;
out.maxDistTime = maxDistTime;
out.stimMarkers = stimMarkers;
out.rasterTypes = rasterTypes;
out.contextNumbers = contextNumbers;

save(fileName,'-struct','out');
return;
end

if isstruct(aei) & isstruct(selAnimals)
    paraMs = aei; clear aei;
    selC = selAnimals; clear selAnimals;
    CsRTs = selC.conditionsAndRasterTypes;
    [rows,cols] = size(CsRTs);
    cellListsRows = [];
    for rr = 1:rows
        cellListsCols = [];
        for cc = 1:cols
            tcond = CsRTs(rr,cc);
            if tcond < 0
                tcond = abs(tcond);
                neg = 1;
            else
                neg = 0;
            end
            Ndigits = dec2base(tcond,10) - '0';
            cellListsCols{cc} = getCellList(paraMs,selC,varNamesDH,Ndigits(1),Ndigits(2));
            if neg
                cellListsCols{cc} = notCellList(cellListsCols{cc});
            end
            all_out{rr,cc} = getVals(paraMs,cellListsCols{cc},varNamesDH);
        end
        cellListsRows{rr} = andCellLists(cellListsCols);
    end
    cellList = orCellLists(cellListsRows);
    out = getVals(paraMs,cellList,varNamesDH);
    return;
end

if isstruct(aei) & isnumeric(selAnimals)
    paraMs = aei; clear aei;
    selC = selAnimals; clear selAnimals;

end

function cellList = notCellList(cellList)
for an = 1:length(cellList)
    cellList{an} = ~cellList{an};
end

function cellList = orCellLists(cellLists)
for an = 1:length(cellLists{1})
    cellSel0s = logical(zeros(size(cellLists{1}{an})));
    for clsi = 1:length(cellLists)
        cellSel0s = cellSel0s | cellLists{clsi}{an};
    end
    cellList{an} = cellSel0s;
end

function cellList = andCellLists(cellLists)
for an = 1:length(cellLists{1})
    cellSel0s = logical(ones(size(cellLists{1}{an})));
    for clsi = 1:length(cellLists)
        cellSel0s = cellSel0s & cellLists{clsi}{an};
    end
    cellList{an} = cellSel0s;
end

function cellList = getCellList(paraMs,selC,varNamesDH,conditionNumber,rasterType)
thresholdVars = {'zMI_threshold','','fwidth_limits','fcenter_limits','frs_threshold'};
for an = 1:length(paraMs.all_areCells)
        cellSel1s = logical(ones(size(paraMs.all_areCells{an})));
        if isempty(cellSel1s)
            continue;
        end
%         cellSel0s = logical(zeros(size(paraMs.all_areCells{an})));
        cellSel = cellSel1s;
        if ~isnan(selC.areCells)
            if selC.areCells == 1
                cellSel = cellSel & paraMs.all_areCells{an};
            else
                cellSel = cellSel & ~paraMs.all_areCells{an};
            end
        end
        if ~isnan(selC.plane_number)
            cns = paraMs.all_cns{an};
            cellSel = cellSel & cns(:,2) == selC.plane_number;
        end
        for vi = 1:length(varNamesDH)
            if isempty(thresholdVars{vi})
                continue;
            end
            cmdTxt = sprintf('thisThreshold = selC.%s;',thresholdVars{vi});
            eval(cmdTxt);
            if isnan(thisThreshold)
                continue;
            end
            cmdTxt = sprintf('tempR = squeeze(paraMs.all_%s{an}(conditionNumber,rasterType,:));',varNamesDH{vi});
            eval(cmdTxt);
            if length(thisThreshold) == 1
                tempCR = tempR > thisThreshold;
            else
                tempCR = (tempR > thisThreshold(1) & tempR < thisThreshold(2));
            end
            cellSel = cellSel & tempCR;
        end
        cellList{an} = cellSel;
end
    
function out = getVals(paraMs,cellList,varNamesDH)
for an = 1:length(paraMs.all_areCells)
    for vi = 1:length(varNamesDH)
        thisVarDH = varNamesDH{vi};
        cmdTxt = sprintf('out.all_%s{an} = paraMs.all_%s{an}(:,:,cellList{an});',thisVarDH,thisVarDH);
        eval(cmdTxt);
    end
    out.numCells(an) = sum(cellList{an});
    out.perc(an) = 100*sum(cellList{an})/length(cellList{an});
    out.numROIs(an) = length(cellList{an});
    out.areCells(an) = sum(paraMs.all_areCells{an});
end
out.cellSel = cellList;