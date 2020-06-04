function figure1_number_of_PCs

ei = evalin('base','ei10');
mData = evalin('base','mData');
selAnimals = [1:9];

colors = mData.colors;
sigColor = mData.sigColor;
axes_font_size = mData.axes_font_size;

% in the following variable all the measurements are in the matrices form
% for each variable colums indicate raster and stim marker types specified 
% the rows indicate condition numbers.
owr = 0;
paramMs = get_parameters_matrices(ei,[1:9],owr);
% after getting all matrics, we can apply selection criteria to select a
% subgroup of cells
% here is the selection criteria in make_selC_structure function

cellsOrNot = NaN; planeNumber = NaN; zMI_Th = 3; fwids = [0 140]; fcens = [0 140]; rs_th = 0.4;
% cellsOrNot = NaN; planeNumber = NaN; zMI_Th = 3; fwids = NaN; fcens = NaN; rs_th = NaN;
conditionsAndRasterTypes = [11 12 13 14 21 22 23 24 31 32 33 34 41 42 43 44]; selC = make_selC_struct(cellsOrNot,planeNumber,conditionsAndRasterTypes,zMI_Th,fwids,fcens,rs_th);
[cpMs pMs] = get_parameters_matrices(paramMs,selC);


for rr = 1:size(pMs,1)
    for cc = 1:size(pMs,2)
        for ani = 1:length(selAnimals)
            an = selAnimals(ani);
            Perc_an(ani,rr,cc) = pMs{rr,cc}.perc(an);
            Num_an(ani,rr,cc) = pMs{rr,cc}.numCells(an);
        end
        tcond = conditionsAndRasterTypes(rr,cc);
        nds = dec2base(tcond,10) - '0';
        varNames{rr,cc} = sprintf('C%dR%d',nds(1),nds(2));
    end
end
perc_cells = squeeze(Perc_an)
num_cells = squeeze(Num_an)
%%
runthis = 1;
if runthis
    data = perc_cells;
    cmdTxt = sprintf('dataT = table(');
    for ii = 1:(size(data,2)-1)
        cmdTxt = sprintf('%sdata(:,%d),',cmdTxt,ii);
    end
    cmdTxt = sprintf('%sdata(:,16));',cmdTxt);
    eval(cmdTxt);
    dataT.Properties.VariableNames = varNames;
    within = table([1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4]',[1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4]');
    cnRT = [[1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4]',[1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4]'];
    within.Properties.VariableNames = {'Condition','Raster_Type'};
    within.Condition = categorical(within.Condition);
    within.Raster_Type = categorical(within.Raster_Type);
    cmdTxt = sprintf('rm = fitrm(dataT,''');
    for ii = 1:(length(varNames)-1)
        cmdTxt = sprintf('%s%s,',cmdTxt,varNames{ii});
    end
    cmdTxt = sprintf('%s%s~1'');',cmdTxt,varNames{16});
    eval(cmdTxt);
    rm.WithinDesign = within;
    rm.WithinModel = 'Condition+Raster_Type';
    rtable = ranova(rm,'WithinModel',rm.WithinModel);
    mauchlytbl = mauchly(rm);
    % multcompare(rm,'Day','ComparisonType','bonferroni')
    mcTI = find_sig_mctbl(multcompare(rm,'Raster_Type','By','Condition','ComparisonType','bonferroni'),6);
    mcDays = find_sig_mctbl(multcompare(rm,'Condition','By','Raster_Type','ComparisonType','bonferroni'),6);
    [mVar semVar] = findMeanAndStandardError(data);
    combs = nchoosek(1:size(data,2),2); p = ones(size(combs,1),1); h = logical(zeros(size(combs,1),1));
    for rr = 1:size(mcTI,1)
        thisRow = mcTI(rr,:);
        conditionN =  thisRow{1,1}; Rtype1 = thisRow{1,2}; Rtype2 = thisRow{1,3};
        Num1 = find(ismember(within{:,:},[conditionN Rtype1],'rows'));
        Num2 = find(ismember(within{:,:},[conditionN Rtype2],'rows'));
        row = [Num1 Num2]; ii = ismember(combs,row,'rows'); p(ii) = mcTI{1,6}; h(ii) = 1;
    end
    for rr = 1:size(mcDays,1)
        thisRow = mcDays(rr,:);
        Rtype =  thisRow{1,1}; Condition1 = thisRow{1,2}; Condition2 = thisRow{1,3};
        Num1 = find(ismember(within{:,:},[Condition1 Rtype],'rows'));
        Num2 = find(ismember(within{:,:},[Condition2 Rtype],'rows'));
        row = [Num1 Num2]; ii = ismember(combs,row,'rows'); p(ii) = mcDays{1,6}; h(ii) = 1;
    end
    xdata = [1:1.5:(10*size(data,2))]; xdata = xdata(1:size(data,2)); maxY = 130;
    hf = figure(15);clf;set(gcf,'Units','Inches');set(gcf,'Position',[3 3 4 1.5],'color','w');
    hold on;
    ind = 1;
    for ii = 1:4
        for jj = 1:4
            tcolors{ind} = colors{ii};
            ind = ind + 1;
        end
    end
    hbs = plotBarsWithSigLines(mVar,semVar,combs,[h p],'colors',tcolors,'sigColor','k',...
        'maxY',maxY,'ySpacing',10,'sigTestName','','sigLineWidth',0.25,'BaseValue',0.1,...
        'xdata',xdata,'sigFontSize',7,'sigAsteriskFontSize',8,'barWidth',0.7,'sigLinesStartYFactor',0.5);
    set(gca,'xlim',[0.25 max(xdata)+.75],'ylim',[0 maxY],'FontSize',6,'FontWeight','Bold','TickDir','out');
    xticks = xdata; 
    xticklabels = {'AirD','AirT','BeltD','AirIT'};xticklabels = repmat(xticklabels,1,4);
    set(gca,'xtick',xticks,'xticklabels',xticklabels);
    xtickangle(30);
    changePosition(gca,[0.1 0.02 -0.03 -0.011])
    put_axes_labels(gca,{[],[0 0 0]},{{'Percentage of PCs'},[0 0 0]});
    save_pdf(hf,mData.pdf_folder,sprintf('Percentage of PCs'),600);
return;
end


%%
runthis = 1;
if runthis
hf = figure(1002);clf;set(gcf,'Units','Inches');set(gcf,'Position',[10 5 6 2.5],'color','w');
hold on;
barVar = [numCells upcs upcs4 upcs5];
hb = bar(barVar);
xlabel('Animal Number'); ylabel('Number of Cells');
hleg = legend(...
    sprintf('All Cells (N = %d)',sum(numCells)),...
    sprintf('Place Cells (zMI>3, N = %d - %.0f%%)',sum(upcs),100*sum(upcs)/sum(numCells)),...
    sprintf('Place Cells (zMI>4, N = %d - %.0f%%)',sum(upcs4),100*sum(upcs4)/sum(numCells)),...
    sprintf('Place Cells (zMI>5, N = %d - %.0f%%)',sum(upcs5),100*sum(upcs5)/sum(numCells)));
    changePosition(hleg,[0.07 0.08 0 0]);
legend boxoff
for ii = 1:4
    set(hb(ii),'FaceColor',colors{ii},'EdgeColor',colors{ii});
end
for ii = 1:size(numCells,1)
    text(ii,upcs(ii)+50,sprintf('%.0f%%',100*upcs5(ii)/numCells(ii)),'Color',colors{4});
end
set(gca,'XTick',[1:8],'XTickLabel',{'1','2','3','4','5','6','7','8'});
set(gca,'FontSize',mData.axes_font_size,'FontWeight','Bold','TickDir','out');changePosition(gca,[-0.02 0.01 0.1 -0.05]);
save_pdf(hf,mData.pdf_folder,'Number Of Place Cells',600);
return
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