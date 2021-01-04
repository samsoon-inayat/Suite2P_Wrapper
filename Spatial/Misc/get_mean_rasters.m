function out = get_mean_rasters(pMs_C,paramMs_C,selAnimals_C,ei_C,conditionsAndRasterTypes,selC,cpMs,trials)

if ~exist('trials','var')
    trials = 1:10;
end

all_conds = []; all_rts = [];
for rr = 1:size(pMs_C,1)
    for cc = 1:size(pMs_C,2)
        tcond = conditionsAndRasterTypes(rr,cc);
        nds = dec2base(tcond,10) - '0';
        varNames{rr,cc} = sprintf('C%dR%d',nds(1),nds(2));
        all_conds = [all_conds nds(1)]; all_rts = [all_rts nds(2)];
        xticklabels{cc,rr} = sprintf('%s-%s',paramMs_C.stimMarkers{nds(2)},paramMs_C.rasterTypes{nds(2)}(1));
        for an = 1:length(selAnimals_C)
            tei = ei_C(an); conditionNumber = nds(1); rasterType = paramMs_C.rasterTypes{nds(2)}; 
            stimMarker = paramMs_C.stimMarkers{nds(2)}; maxDistTime = [150 Inf];%paramMs_C.maxDistTime;
            if ischar(cpMs)
                selCells = pMs_C{conditionNumber}.cellSel{an};
            end
            if isstruct(cpMs)
                selCells = cpMs.cellSel{an};
            end
            cns = paramMs_C.all_cns{an};
            [temp_rasters ~] = getParamValues('rasters',tei,selC.plane_number,conditionNumber,stimMarker,rasterType,cns(selCells,2:3),maxDistTime);
            this_mean_rasters = squeeze(nanmean(temp_rasters(trials,:,:),1))';
            mean_rasters_C{an,cc} = this_mean_rasters;
            [temp ~] = getParamValues('',tei,selC.plane_number,conditionNumber,stimMarker,rasterType,cns(selCells,2:3),maxDistTime);
            xs{an,cc} = temp.xs;
        end
    end
end

out.mean_rasters = mean_rasters_C;
out.xs = xs;