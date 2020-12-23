function figure_place_field_properties(fn,allRs,ccs)

protocol = '10';
% protocol = '15';
ei = evalin('base',sprintf('ei%s',protocol));
mData = evalin('base','mData'); colors = mData.colors; sigColor = mData.sigColor; axes_font_size = mData.axes_font_size;
ET = evalin('base',sprintf('ET%s',protocol));
selAnimals = eval(sprintf('mData.selAnimals%s',protocol));

% in the following variable all the measurements are in the matrices form
% for each variable colums indicate raster and stim marker types specified 
% the rows indicate condition numbers.
paramMs = parameter_matrices('get',protocol);
% after getting all matrics, we can apply selection criteria to select a
% subgroup of cells
% here is the selection criteria in make_selC_structure function
% cellsOrNot = NaN; planeNumber = NaN; zMI_Th = 3; fwids = [1 120]; fcens = [0 140]; rs_th = 0.4;
cellsOrNot = NaN; planeNumber = NaN; zMI_Th = 3; fwids = [1 120]; fcens = [0 140]; rs_th = 0.4; HaFD_th = NaN; HiFD_th = NaN;
% cellsOrNot = NaN; planeNumber = NaN; zMI_Th = 3; fwids = NaN; fcens = NaN; rs_th = 0.4; HaFD_th = NaN; HiFD_th = NaN;
conditionsAndRasterTypes = [11 21 31 41];
selC = make_selC_struct(cellsOrNot,planeNumber,conditionsAndRasterTypes,zMI_Th,fwids,fcens,rs_th,HaFD_th,HiFD_th);
[cpMs,pMs] = parameter_matrices('select',protocol,{paramMs,selC});
perc_cells = parameter_matrices('print',protocol,{cpMs,pMs,ET,selAnimals});

for rr = 1:size(pMs,1)
    for cc = 1:size(pMs,2)
        tcond = conditionsAndRasterTypes(rr,cc);
        nds = dec2base(tcond,10) - '0';
        varNames{rr,cc} = sprintf('C%dR%d',nds(1),nds(2));
        for an = 1:length(selAnimals)
            f_centers{an,rr,cc} = squeeze(pMs{rr,cc}.all_fcenters{selAnimals(an)}(nds(1),nds(2),:));
        end
    end
end

bins = 0:37:155;
for an = 1:length(selAnimals)
    for cc = 1:length(conditionsAndRasterTypes)
        theseCenters = f_centers{an,1,cc};
        [temp,E,B] = histcounts(theseCenters,bins);
        all_data(cc,:,an) = temp/sum(temp);
    end
end
n=0;

%%
% perform repeated measures anova
    numCols = size(all_data,2);    numRows = size(all_data,1);
    ind = 1;
    varNames = [];
    for ii = 1:numRows
        for jj = 1:numCols
            varNames{ind} = sprintf('C%dBin%d',ii,jj);
            ind = ind + 1;
        end
    end
    data = [];
    for ii = 1:size(all_data,3)
        thisd = all_data(:,:,ii);
        data(ii,:) = reshape(thisd',1,numRows*numCols);
    end
    colVar1 = []; colVar2 = [];
    for ii = 1:length(conditionsAndRasterTypes)
        colVar1 = [colVar1 ii * ones(1,numCols)];
        colVar2 = [colVar2 1:numCols];
    end
%     colVar2 = [1:numCols 1:numCols 1:numCols 1:numCols];
    within = table(colVar1',colVar2'); within.Properties.VariableNames = {'Condition','Bin'};
    ra = repeatedMeasuresAnova(data,varNames,within);
%%
    n = 0;
    axdata = [1:1.5:(10*size(data,2))]; axdata = axdata(1:numCols); maxY = 1;
    xdata = []; ixdata = []; offset = 2;
    for ii = 1:numRows
        if ii == 1
            xdata = axdata;
        else
            ixdata(ii-1) = xdata(end) + ((axdata(1) + xdata(end) + offset) - xdata(end))/2;
            xdata = [xdata (axdata + xdata(end) + offset)];
        end
    end
    hf = figure(15);clf;set(gcf,'Units','Inches');set(gcf,'Position',[3 3 4 1.5],'color','w');
    hold on;
    ind = 1;
    for ii = 1:numRows
        for jj = 1:numCols
            tcolors{ind} = colors{ii};
            ind = ind + 1;
        end
    end
    hbs = plotBarsWithSigLines(mVar,semVar,combs,[h p],'colors',tcolors,'sigColor','k',...
        'maxY',maxY,'ySpacing',0.05,'sigTestName','','sigLineWidth',0.25,'BaseValue',0,...
        'xdata',xdata,'sigFontSize',7,'sigAsteriskFontSize',8,'barWidth',0.7,'sigLinesStartYFactor',0);
    set(gca,'xlim',[0.25 max(xdata)+.75],'FontSize',6,'FontWeight','Bold','TickDir','out');
    xticks = xdata;
    for ii = 1:(length(bins)-1)
        xticklabels{ii} = sprintf('Bin%d',ii);
    end
    xticklabels = repmat(xticklabels,1,4);
    set(gca,'xtick',xticks,'xticklabels',xticklabels);
    xtickangle(30);
%     hbis = bar(ixdata,int_env.avg,'barWidth',0.05,'BaseValue',0.1,'ShowBaseline','off');
%     set(hbis,'FaceColor','m','EdgeColor','m');
%     errorbar(ixdata,int_env.avg,int_env.sem,'linestyle', 'none','CapSize',3);
    changePosition(gca,[0.1 0.067 -0.03 -0.05])
    put_axes_labels(gca,{'PF Center Bins',[0 0 0]},{{'Percent Place Cells'},[0 0 0]});
    save_pdf(hf,mData.pdf_folder,sprintf('cell_seq'),600);
    


%% scatter place field widths vs centers
runThis = 0;
if runThis
hf = figure(1000);clf;set(gcf,'Units','Inches');set(gcf,'Position',[10 4 6 2.5],'color','w');hold on;
ya = []; xa = []; gr = [];
for ii = 1:2%length(all_pws_c)
    pwidths = all_pws_c{ii};
    pcenters = all_cs_c{ii};
    scatter(pcenters,pwidths,20,'.','MarkerEdgeColor',colors{ii},'MarkerFaceColor','none');
    ft = fittype('poly1');
    [ftc,gof,output] = fit(pcenters,pwidths,ft);    rsq(ii) = gof.rsquare;
    co = coeffvalues(ftc);
    pwf = ft(co(1),co(2),pcenters);
    hold on;plot(pcenters,pwf,'color',colors{ii},'LineWidth',1)
    xa = [xa;pcenters]; ya = [ya;pwidths]; gr = [gr;ones(size(pcenters))*ii];
end
sigR = do_ancova(xa,ya,gr);
ylim([0 100]);
set(gca,'TickDir','out','FontSize',mData.axes_font_size,'FontWeight','Bold');
hx = xlabel('Place Field Center (cm)');changePosition(hx,[0 0.0 0]);
hy = ylabel('Place Field Width (cm)');changePosition(hy,[2.2 -3.0 0]);
for ii = 1:length(all_pws_c)
    legs{ii} = sprintf('C %d',ii);%{'Context 1','Context 2','Context 3','Context 4',[30 3 35 3]};
end
legs{ii+1} = [35 5 93 7];putLegend(gca,legs,'colors',colors,'sigR',{sigR,'ancovas',sigColor,9}); text(30,100,'Slope','FontWeight','Bold');
legs{ii+1} = [100 5 93 7];putLegend(gca,legs,'colors',colors,'sigR',{sigR,'ancovai',sigColor,9}); text(95,100,'Intercept','FontWeight','Bold');
changePosition(gca,[-0.03 0.09 0.09 -0.06]);
save_pdf(hf,mData.pdf_folder,'figure_scatter_centers_widths.pdf',600);
return;
end

%% scatter zMI vs centers
runThis = 0;
if runThis
hf = figure(1000);clf;set(gcf,'Units','Inches');set(gcf,'Position',[10 4 6 2.5],'color','w');hold on;
ya = []; xa = []; gr = [];
for ii = 1:length(pw)
    SIs = SI{ii}(find(pcs5{ii}))';
    pcenters = pc{ii}(find(pcs5{ii}))';
    scatter(pcenters,SIs,20,'.','MarkerEdgeColor',colors{ii},'MarkerFaceColor','none');
    ft = fittype('poly1');
    [ftc,gof,output] = fit(pcenters,SIs,ft);  rsq(ii) = gof.rsquare;
    co = coeffvalues(ftc);
    pwf = ft(co(1),co(2),pcenters);
    hold on;plot(pcenters,pwf,'color',colors{ii},'LineWidth',1)
    xa = [xa;pcenters]; ya = [ya;SIs]; gr = [gr;ones(size(pcenters))*ii];
end
sigR = do_ancova(xa,ya,gr);
ylim([0 35]);
set(gca,'TickDir','out','FontSize',mData.axes_font_size,'FontWeight','Bold');
hx = xlabel('Place Field Center (cm)');changePosition(hx,[0 0.0 0]);
hy = ylabel('Mutual Info. (Z Score)');changePosition(hy,[0 0.0 0]);
for ii = 1:length(pw)
    legs{ii} = sprintf('C %d',ii);%{'Context 1','Context 2','Context 3','Context 4',[30 3 35 3]};
end
legs{ii+1} = [130 5 33 2];putLegend(gca,legs,'colors',colors,'sigR',{sigR,'ancovai',sigColor,9}); text(125,36,'Intercept','FontWeight','Bold'); 
legs{end} = [70 5 33 2];putLegend(gca,legs,'colors',colors,'sigR',{sigR,'ancovas',sigColor,9}); text(65,36,'Slope','FontWeight','Bold');

changePosition(gca,[-0.03 0.09 0.09 -0.06]);
save_pdf(hf,mData.pdf_folder,'figure_scatter_centers_zMI.pdf',600);
return;
end

