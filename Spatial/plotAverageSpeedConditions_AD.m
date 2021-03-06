function plotAverageSpeedConditions(b,markers1,markers2,fn)
%%
n = 0;
%%
ei_C = evalin('base','ei10_C');
ei_A = evalin('base','ei10_A');
ei = ei_C;

mData = evalin('base','mData');
out = find_speeds(ei_C)
moas = out.meanSpeedTrialsAnimalsT;
moasi = out.meanSpeedTrialsAnimalsIT;

out = find_speeds(ei_A)
moas_A = out.meanSpeedTrialsAnimalsT;
moasi_A = out.meanSpeedTrialsAnimalsIT;

for ii = 1:size(moas,2)
    varNames{ii} = sprintf('Trials_Cond%d',ii);
end
for ii = 1:size(moasi,2)
    varNamesI{ii} = sprintf('InterTrials_Cond%d',ii);
end
data = [moas moasi];
dataT = table(data(:,1),data(:,5),data(:,2),data(:,6),data(:,3),data(:,7),data(:,4),data(:,8));
dataT.Properties.VariableNames = {varNames{1} varNamesI{1} varNames{2} varNamesI{2} varNames{3} varNamesI{3} varNames{4} varNamesI{4}};
data = [moas_A moasi_A];
dataT_A = table(data(:,1),data(:,5),data(:,2),data(:,6),data(:,3),data(:,7),data(:,4),data(:,8));
dataT_A.Properties.VariableNames = {varNames{1} varNamesI{1} varNames{2} varNamesI{2} varNames{3} varNamesI{3} varNames{4} varNamesI{4}};
within = table([varNames';varNamesI']);
columnText = cell(size(within,1),1);columnText(1:2:end)= varNames';columnText(2:2:end)= varNamesI';
within = table([varNames';varNamesI'],columnText);
within = table([1 1 2 2 3 3 4 4]',[1 2 1 2 1 2 1 2]');
within.Properties.VariableNames = {'Condition','TI'};
within.TI = categorical(within.TI);
within.Condition = categorical(within.Condition);
Group = [ones(length(ei_C),1);(2*ones(length(ei_A),1))];
% writetable(between,'Training_Data.xls');
Group = categorical(Group);
rm = fitrm([table(Group) [dataT;dataT_A]],'Trials_Cond1,InterTrials_Cond1,Trials_Cond2,InterTrials_Cond2,Trials_Cond3,InterTrials_Cond3,Trials_Cond4,InterTrials_Cond4 ~ Group','WithinDesign',within,'WithinModel','Condition*TI');
rtable = ranova(rm,'WithinModel',rm.WithinModel);
mauchlytbl = mauchly(rm);
% multcompare(rm,'Day','ComparisonType','bonferroni')
mcTI = find_sig_mctbl(multcompare(rm,'Group','By','Condition','ComparisonType','bonferroni'),6);
mcConditions = find_sig_mctbl(multcompare(rm,'Condition','By','TI','ComparisonType','lsd'),6);

[mVarT,semVarT] = findMeanAndStandardError(moas);
[mVarIT,semVarIT] = findMeanAndStandardError(moasi);

[mVarT_A,semVarT_A] = findMeanAndStandardError(moas_A);
[mVarIT_A,semVarIT_A] = findMeanAndStandardError(moasi_A);

mVar = NaN(1,2*(length(mVarT)+length(mVarIT)));
semVar = mVar;
mVar(1:2:8) = mVarT;semVar(1:2:8) = semVarT;
mVar(2:2:8) = mVarIT;semVar(2:2:8) = semVarIT;
mVar(9:2:16) = mVarT_A;semVar(9:2:16) = semVarT_A;
mVar(10:2:16) = mVarIT_A;semVar(10:2:16) = semVarIT_A;
combs = nchoosek(1:16,2); p = ones(size(combs,1),1); h = logical(zeros(size(combs,1),1));
% row = [7 8]; ii = ismember(combs,row,'rows'); p(ii) = mcTI{1,6}; h(ii) = 1; 
% row = [5 6]; ii = ismember(combs,row,'rows'); p(ii) = mcTI{2,6}; h(ii) = 1; 
% row = [3 4]; ii = ismember(combs,row,'rows'); p(ii) = mcTI{3,6}; h(ii) = 1; 

xdata = [1 2 4 5 7 8 10 11 [13 14 16 17 19 20 22 23]+2]; maxY = 22;
colors = mData.colors;
hf = figure(5);clf;set(gcf,'Units','Inches');set(gcf,'Position',[5 7 2.25 1],'color','w');
hold on;
tcolors = {colors{1};colors{1};colors{2};colors{2};colors{3};colors{3};colors{4};colors{4};colors{1};colors{1};colors{2};colors{2};colors{3};colors{3};colors{4};colors{4}};
hbs = plotBarsWithSigLines(mVar,semVar,combs,[h p],'colors',tcolors,'sigColor','k',...
    'maxY',maxY,'ySpacing',1,'sigTestName','','sigLineWidth',0.25,'BaseValue',0.1,...
    'xdata',xdata,'sigFontSize',7,'sigAsteriskFontSize',10,'barWidth',0.7,'sigLinesStartYFactor',-0.1);
for ii = 2:2:length(hbs)
    set(hbs(ii),'facecolor','none','edgecolor',tcolors{ii});
end
% plot([0.5 11],[-0.5 0.5],'linewidth',1.5)
set(gca,'xlim',[0.25 xdata(end)+0.75],'ylim',[0 maxY+1],'FontSize',6,'FontWeight','Bold','TickDir','out');
% xticks = [1.5 4.5 7.5 10.5]; xticklabels = {'C1','C2','C3','C4'};
xticks = xdata(1:2:end)+0.5; xticklabels = {'C1','C2','C3','C4','C1','C2','C3','C4'};
set(gca,'xtick',xticks,'xticklabels',xticklabels);
changePosition(gca,[0.02 0.03 0.02 -0.11]);
put_axes_labels(gca,{[],[0 0 0]},{'Avg. Speed (cm/sec)',[0 0 0]});
rectangle(gca,'Position',[0.75 21 1 2],'edgecolor','k','facecolor','k');
text(1.85,22,'Trials','FontSize',5);
rectangle(gca,'Position',[6 21 1 2],'edgecolor','k');
text(7.2,22,'Inter-Trials','FontSize',5);
text(3.5,18,'Control','FontSize',7);
text(18.5,18,'APP','FontSize',7);
% applyhatch_plusC(gcf
save_pdf(hf,mData.pdf_folder,'AverageSpeedConditions',600);

function out = find_speeds(ei)
for an = 1:length(ei)
    for cc = 1:4
        thisspeed = ei{an}.plane{1}.contexts(cc).rasters.airT.speed;
        meanSpeedTrials(:,cc) = nanmean(thisspeed,2);
        thisspeed = ei{an}.plane{1}.contexts(cc).rasters.airIT.speed;
        meanSpeedTrialsI(:,cc) = nanmean(thisspeed,2);
    end
    
    meanSpeedTrialsAnimalsT(an,:) = mean(meanSpeedTrials);
    meanSpeedTrialsAnimalsIT(an,:) = mean(meanSpeedTrialsI);
end
out.meanSpeedTrialsAnimalsT = meanSpeedTrialsAnimalsT;
out.meanSpeedTrialsAnimalsIT = meanSpeedTrialsAnimalsIT;