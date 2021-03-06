function showCells(ha,ei,pl,selCells,perc)

FS = 8;
micronsPerPixel = ei.thorExp.widthUM/ei.thorExp.pixelX;
xrange = ei.plane{pl}.tP.ops.xrange;
yrange = ei.plane{pl}.tP.ops.yrange;
mimg = ei.plane{pl}.tP.ops.meanImgE;
% mimg = ei.plane{pl}.tP.ops.refImg;
if isempty(ha)
    figure(102);clf;plot(0,0);
    ha = gca;
end
axes(ha);
% imagesc(mimg,[min(mimg(:)) max(mimg(:))]);
maskZ = zeros(size(mimg));
colormap gray;
axis equal;
axis off;
hold on;
allmask = maskZ;
if ~iscell(selCells)
    ccs = selCells;%ei.plane{pl}.tP.areCells(logical(selCells));
    for cc = 1:length(ccs)
        stat =  ei.plane{pl}.tP.stat(ccs(cc));
        mask = maskZ;
        mask(stat{1}.ipix) = 1;
        mask = expandOrCompressMask(mask,stat{1}.footprint);
        mask = mask';
        allmask(mask==1) = 1;
    end
    img3 = cat(3,mimg,mimg,mimg);
    ch = 2;
    rch = img3(:,:,ch);
    rch = rch + max(rch(:))*(perc(1)*allmask);
    img3(:,:,ch) = rch;
    img2 = img3(:,:,setdiff([1 2 3],ch));
    imagesc(img3,[min(img2(:)) 	perc(2)*max(img2(:))]);hold on;
    for cc = 1:length(ccs)
        stat =  ei.plane{pl}.tP.stat(ccs(cc));
        cellX = double(stat{1}.xpix);% + double(min(xrange));
        cellY = double(stat{1}.ypix);% + double(min(yrange));
        mx = min(cellX);
        my = max(cellY);
%         if selCells(cc) == 46
%             text(mx+30,my+0,num2str(selCells(cc)),'color','c','fontsize',FS+2,'FontWeight','Normal');
%         else
%             if selCells(cc) == 22
%                 text(mx-60,my-20,num2str(selCells(cc)),'color','c','fontsize',FS+2,'FontWeight','Normal');  
%             else
                text(mx-10,my+20,num2str(selCells(cc)),'color','c','fontsize',FS,'FontWeight','Bold');  
%             end
%         end
%         scatter(cellX,cellY,'.r');
%         plot(cellX,cellY,'.','color','r');
    end
else
    accs = selCells; clear selCells;
    cColors = {'c','r','g','b','m','y','w'};
%     cColors = {'c','r','g','r','g','y'};
    tcColors = {'c','r','g','b','m','y','w'};
    for ss = 1:length(accs)
        selCells = accs{ss};
        ccs = ei.areCells(selCells);
        for cc = 1:length(ccs)
            cellX = ei.tP.stat(ccs(cc)).xpix + min(xrange);
            cellY = ei.tP.stat(ccs(cc)).ypix + min(yrange);
            mx = min(cellX);
            my = max(cellY);
%             text(mx-5,my,num2str(selCells(cc)),'color',tcColors{ss},'fontsize',FS);
            plot(cellX,cellY,'.','color',cColors{ss});
        end
    end
end

nPixels = round(50/micronsPerPixel);

scaleBarS = xrange(2)- 20 - nPixels; scaleBarE = scaleBarS + nPixels;
scaleBarY = yrange(1) + 30;
plot([scaleBarS,scaleBarE],[scaleBarY,scaleBarY],'c','linewidth',3);

% text(scaleBarS,scaleBarY-20,sprintf('%.0f um',(scaleBarE - scaleBarS)*micronsPerPixel),'color','r','FontSize',14,'FontWeight','Bold');
if iscell(selCells)
    title(tcColors');
else
%     title(ei.recordingFolder)
end
xlim(xrange); ylim(yrange);