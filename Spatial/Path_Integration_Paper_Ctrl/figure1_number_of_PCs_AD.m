function figure1_number_of_PCs

protocol_C = '10_C';
protocol_A = '10_A';
ei_C = evalin('base','ei10_C');
ei_A = evalin('base','ei10_A');
mData = evalin('base','mData'); colors = mData.colors; sigColor = mData.sigColor; axes_font_size = mData.axes_font_size;
ET_C = evalin('base',sprintf('ET%s','10_CD'));
ET_A = evalin('base',sprintf('ET%s','10_CC'));
selAnimals_C = 1:length(ei_C)
selAnimals_A = 1:length(ei_A)

ei = ei_C;
for ii = 1:length(ei)
    tei = ei{ii};
    nPlanes_C(ii) = length(tei.plane);
end

ei = ei_A;
for ii = 1:length(ei)
    tei = ei{ii};
    nPlanes_A(ii) = length(tei.plane);
end

% in the following variable all the measurements are in the matrices form
% for each variable colums indicate raster and stim marker types specified 
% the rows indicate condition numbers.
paramMs_C = parameter_matrices('get','10_CD_ctrl');
paramMs_A = parameter_matrices('get','10_CC_ctrl');
% after getting all matrics, we can apply selection criteria to select a
% subgroup of cells
% here is the selection criteria in make_selC_structure function
cellsOrNot = 1; planeNumber = NaN; zMI_Th = 3; fwids = [1 120]; fcens = [0 140]; rs_th = 0.4;
% cellsOrNot = 1; planeNumber = NaN; zMI_Th = NaN; fwids = NaN; fcens = NaN; rs_th = NaN;
% cellsOrNot = NaN; planeNumber = NaN; zMI_Th = NaN; fwids = NaN; fcens = NaN; rs_th = NaN;
% cellsOrNot = 1; planeNumber = NaN; zMI_Th = 3; fwids = [1 120]; fcens = [0 140]; rs_th = 0.4;
% cellsOrNot = NaN; planeNumber = NaN; zMI_Th = 3; fwids = NaN; fcens = NaN; rs_th = 0.4;
% conditionsAndRasterTypes = [11 13 21 23 31 33 41 43]';
conditionsAndRasterTypes = [11 13 21 23 31 33 41 43];
conditionsAndRasterTypes = [11 21 31 41];
selC = make_selC_struct(cellsOrNot,planeNumber,conditionsAndRasterTypes,zMI_Th,fwids,fcens,rs_th,NaN,NaN);
[cpMs_C,pMs_C] = parameter_matrices_ctrl('select','10_C',{paramMs_C,selC});
[cpMs_A,pMs_A] = parameter_matrices_ctrl('select','10_A',{paramMs_A,selC});
perc_cells_C = parameter_matrices_ctrl('print','10_C',{cpMs_C,pMs_C,ET_C,selAnimals_C});
perc_cells_A = parameter_matrices_ctrl('print','10_A',{cpMs_A,pMs_A,ET_A,selAnimals_A});

perc_cells_C_n = parameter_matrices_ctrl('print numbers','10_C',{cpMs_C,pMs_C,ET_C,selAnimals_C});
perc_cells_A_n = parameter_matrices_ctrl('print numbers','10_A',{cpMs_A,pMs_A,ET_A,selAnimals_A});

all_conds = []; all_rts = [];
for rr = 1:size(pMs_C,1)
    for cc = 1:size(pMs_C,2)
        tcond = conditionsAndRasterTypes(rr,cc);
        nds = dec2base(tcond,10) - '0';
        varNames{rr,cc} = sprintf('C%dR%d',nds(1),nds(2));
        all_conds = [all_conds nds(1)]; all_rts = [all_rts nds(2)];
        xticklabels{cc,rr} = sprintf('%s-%s',paramMs_C.stimMarkers{nds(2)},paramMs_C.rasterTypes{nds(2)}(1));
    end
end
all_conds = unique(all_conds); all_rts = unique(all_rts);
n = 0;
%%
runthis = 1;
if runthis
    numCols = length(all_rts);
    data = perc_cells_C;
    cmdTxt = sprintf('dataT_C = table(');
    for ii = 1:(size(data,2)-1)
        cmdTxt = sprintf('%sdata(:,%d),',cmdTxt,ii);
    end
    cmdTxt = sprintf('%sdata(:,size(data,2)));',cmdTxt);
    eval(cmdTxt);
    data = perc_cells_A;
    cmdTxt = sprintf('dataT_A = table(');
    for ii = 1:(size(data,2)-1)
        cmdTxt = sprintf('%sdata(:,%d),',cmdTxt,ii);
    end
    cmdTxt = sprintf('%sdata(:,size(data,2)));',cmdTxt);
    eval(cmdTxt);
    dataT = [dataT_C;dataT_A]
    dataT.Properties.VariableNames = varNames;
    dataT = [table([ones(length(ei_C),1);2*ones(length(ei_A),1)]) dataT];
    dataT.Properties.VariableNames{1} = 'Group';
    dataT.Group = categorical(dataT.Group)
    
    colVar1 = [ones(1,numCols) 2*ones(1,numCols) 3*ones(1,numCols) 4*ones(1,numCols)];    colVar2 = [1:numCols 1:numCols 1:numCols 1:numCols];
%     colVar1 = [1 2 3 4];
    within = table(colVar1');
%     within = table(colVar1',colVar2');
    within.Properties.VariableNames = {'Condition'};
%     within.Properties.VariableNames = {'Condition','Raster'};
    within.Condition = categorical(within.Condition);
%     within.Raster = categorical(within.Raster);
    ra = repeatedMeasuresAnova(dataT,within);

    mVar = ra.est_marginal_means.Mean;semVar = ra.est_marginal_means.Formula_StdErr;
    combs = ra.mcs.combs; p = ra.mcs.p; h = ra.mcs.p < 0.05;
    xdata = [1:8];
%     xdata = [1 2 3 4];
    colors = mData.colors;
    hf = figure(5);clf;set(gcf,'Units','Inches');set(gcf,'Position',[5 7 3.25 1],'color','w');
    hold on;
    tcolors ={colors{1};colors{1};colors{2};colors{2};colors{3};colors{3};colors{4};colors{4}};
    [hbs,maxY] = plotBarsWithSigLines(mVar,semVar,combs,[h p],'colors',tcolors,'sigColor','k',...
        'ySpacing',2.5,'sigTestName','','sigLineWidth',0.25,'BaseValue',0.1,...
        'xdata',xdata,'sigFontSize',7,'sigAsteriskFontSize',10,'barWidth',0.7,'sigLinesStartYFactor',0.1);
    for ii = 1:length(hbs)
        set(hbs(ii),'facecolor',tcolors{ii},'edgecolor',tcolors{ii});
    end
    for ii = 2:2:length(hbs)
        set(hbs(ii),'facecolor','none','edgecolor',tcolors{ii});
    end
    % plot([0.5 11],[-0.5 0.5],'linewidth',1.5)
    set(gca,'xlim',[0.25 xdata(end)+0.75],'ylim',[0 maxY+1],'FontSize',6,'FontWeight','Bold','TickDir','out');
    xticks = xdata(1:end)+0; xticklabels = {'C1-AD','C1-BD','C2-AD','C2-BD','C3-AD','C3-BD','C4-AD','C4-BD'};
    set(gca,'xtick',xticks,'xticklabels',xticklabels);
    xtickangle(30);
    changePosition(gca,[0.04 0.03 0.02 -0.11]);
    put_axes_labels(gca,{[],[0 0 0]},{{'Spatially Tuned','Cells (%)'},[0 0 0]});
    
    save_pdf(hf,mData.pdf_folder,sprintf('Percentage of PCs'),600);
return;
end


%%
runthis = 0;
if runthis
pcsC = [];
for kk = 1:4
    for jj = 1:length(selAnimals)
        pcsC(jj,kk) = 100*sum(distD{jj,kk})/length(distD{jj,kk});
    end
end

sigR = significanceTesting(pcsC);

hf = figure(10030);clf;set(gcf,'Units','Inches');set(gcf,'Position',[10 5 5 3.5],'color','w');
hold on;
xdatas = {[1 2 3 4],[5 6 7]};
hs = sigR.anova.multcompare.h; ps = sigR.anova.multcompare.p;
plotBarsWithSigLines(sigR.means,sigR.sems,sigR.combs,[hs ps],'colors',colors,'sigColor',sigColor,...
    'maxY',30,'ySpacing',1.5,'sigTestName','ANOVA','sigLineWidth',0.25,'BaseValue',0.001,...
    'xdata',xdatas{1},'sigFontSize',12,'sigAsteriskFontSize',17);
xlabel('Condition'); ylabel('Percentage of Cells');
% legs = {'Context 1','Context 2','Context 3',[11 0.25 0.27 0.025]};
% putLegend(gca,legs,'colors',colors,'sigR',{[],'ks',sigColor,10});
set(gca,'XTick',[1:4]);
set(gca,'FontSize',mData.axes_font_size+4,'FontWeight','Bold','TickDir','out');changePosition(gca,[-0.01 0.01 0.06 -0.01]);
% text(1,0.29,'Light Responsive and Place Cells','FontSize',mData.axes_font_size,'FontWeight','Bold');
save_pdf(hf,mData.pdf_folder,'Perc Of Place Cells_contexts_10',600);
return;
end

%%
runthis = 0;
if runthis
theData = [];
for jj = 1:3
    theData{jj} = remained(:,jj+1);
end
sigR = significanceTesting(theData);
hf = figure(1005);clf;set(gcf,'Units','Inches');set(gcf,'Position',[10 5 1.5 2.5],'color','w');
hold on;
xdatas = {[1 2 3],[5 6 7]};
hs = sigR.anova.multcompare.h; ps = sigR.anova.multcompare.p;
plotBarsWithSigLines(sigR.means,sigR.sems,sigR.combs,[hs ps],'colors',colors,'sigColor',sigColor,...
    'maxY',120,'ySpacing',1.5,'sigTestName','ANOVA','sigLineWidth',0.25,'BaseValue',0.001,...
    'xdata',xdatas{1},'sigFontSize',9,'sigAsteriskFontSize',15);
xlabel('Contexts'); ylabel('Percentage of Cells');
% legs = {'Context 1','Context 2','Context 3',[11 0.25 0.27 0.025]};
% putLegend(gca,legs,'colors',colors,'sigR',{[],'ks',sigColor,10});
set(gca,'XTick',[1:4]);xlim([0 5]);
set(gca,'FontSize',mData.axes_font_size,'FontWeight','Bold','TickDir','out');changePosition(gca,[-0.01 0.01 0.06 -0.01]);
% text(1,0.29,'Light Responsive and Place Cells','FontSize',mData.axes_font_size,'FontWeight','Bold');
save_pdf(hf,mData.pdf_folder,'Perc Of Place Cells_Remained_contexts_10',600);
return;
end

%%
runthis = 0;
if runthis
theData = [];
for jj = 1:3
    theData{jj} = disrupted(:,jj+1);
end
sigR = significanceTesting(theData);
hf = figure(1006);clf;set(gcf,'Units','Inches');set(gcf,'Position',[10 5 1.5 2.5],'color','w');
hold on;
xdatas = {[1 2 3],[5 6 7]};
hs = sigR.anova.multcompare.h; ps = sigR.anova.multcompare.p;
plotBarsWithSigLines(sigR.means,sigR.sems,sigR.combs,[hs ps],'colors',colors,'sigColor',sigColor,...
    'maxY',120,'ySpacing',1.5,'sigTestName','ANOVA','sigLineWidth',0.25,'BaseValue',0.001,...
    'xdata',xdatas{1},'sigFontSize',9,'sigAsteriskFontSize',15);
xlabel('Contexts'); ylabel('Percentage of Cells');
% legs = {'Context 1','Context 2','Context 3',[11 0.25 0.27 0.025]};
% putLegend(gca,legs,'colors',colors,'sigR',{[],'ks',sigColor,10});
set(gca,'XTick',[1:4]);xlim([0 5])
set(gca,'FontSize',mData.axes_font_size,'FontWeight','Bold','TickDir','out');changePosition(gca,[-0.01 0.01 0.06 -0.01]);
% text(1,0.29,'Light Responsive and Place Cells','FontSize',mData.axes_font_size,'FontWeight','Bold');
save_pdf(hf,mData.pdf_folder,'Perc Of Place Cells_Disrupted_contexts_10',600);
return;
end

%%
runthis = 1;
if runthis
theData = [];
for jj = 1:3
    theData{jj} = newones(:,jj+1);
end
sigR = significanceTesting(theData);
hf = figure(1007);clf;set(gcf,'Units','Inches');set(gcf,'Position',[10 5 1.5 2.5],'color','w');
hold on;
xdatas = {[2 3 4],[5 6 7]};
hs = sigR.anova.multcompare.h; ps = sigR.anova.multcompare.p;
plotBarsWithSigLines(sigR.means,sigR.sems,sigR.combs,[hs ps],'colors',colors(2:end),'sigColor',sigColor,...
    'maxY',120,'ySpacing',1.5,'sigTestName','ANOVA','sigLineWidth',0.25,'BaseValue',0.001,...
    'xdata',xdatas{1},'sigFontSize',9,'sigAsteriskFontSize',15);
xlabel('Contexts'); ylabel('Percentage of Cells');
% legs = {'Context 1','Context 2','Context 3',[11 0.25 0.27 0.025]};
% putLegend(gca,legs,'colors',colors,'sigR',{[],'ks',sigColor,10});
set(gca,'XTick',[1:4],'XTickLabel',num2cell(1:4'));
set(gca,'FontSize',mData.axes_font_size,'FontWeight','Bold','TickDir','out');changePosition(gca,[-0.01 0.01 0.06 -0.01]);
% text(1,0.29,'Light Responsive and Place Cells','FontSize',mData.axes_font_size,'FontWeight','Bold');
save_pdf(hf,mData.pdf_folder,'Perc Of Place Cells_NewOnes_contexts_10',600);
return;
end