function runPreprocessing_EV_old (ags,pags,stim_info,indices,stimulusFrame)

parfor ii = 1:length(indices)
    indx = indices(ii);
    preProcessFolder(ags,pags,stim_info,indx,stimulusFrame);
end


function preProcessFolder(ags,pags,stim_info,indx,stimulusFrame)
gg = stim_info.list(indx,2);
aa = stim_info.list(indx,3);
rr = stim_info.list(indx,4);
thisRecording = ags(gg).animals{aa}.eRecordings{rr};
pThisRecording = pags(gg).animals{aa}.eRecordings{rr};
hitrials = thisRecording.hiTrials;
lotrials = thisRecording.loTrials;
notrials = thisRecording.noTrials;
disp('Loading trials');
trials = notrials;
parfor ii = 1:length(trials)
    filenamedfSeq = makeName([trials{ii} '.tif'],thisRecording.root_folder);
    img = readTiff(filenamedfSeq); img = double(img);
    noallImg{ii}.img = img;
end
trials = hitrials;
parfor ii = 1:length(trials)
    filenamedfSeq = makeName([trials{ii} '.tif'],thisRecording.root_folder);
    img = readTiff(filenamedfSeq); img = double(img);
    hiallImg{ii}.img = img;
end
trials = lotrials;
parfor ii = 1:length(trials)
    filenamedfSeq = makeName([trials{ii} '.tif'],thisRecording.root_folder);
    img = readTiff(filenamedfSeq); img = double(img);
    loallImg{ii}.img = img;
end
baseline_from = stimulusFrame - 10;
baseline_to = stimulusFrame - 1;
nFrames = size( loallImg{1}.img,3);
disp('Processing data');
parfor kk = 1:length(trials)
    img_hi = hiallImg{kk}.img;
    img_lo = loallImg{kk}.img;
    img_no = noallImg{kk}.img;
    [img_hi_out,img_lo_out]=trialbaseddff0_original(img_hi,img_lo,img_no,nFrames,baseline_from,baseline_to);
    mallImg{kk}.img = (img_hi_out + img_lo_out)/2;
end
df = mallImg{1}.img;
for kk = 2:length(mallImg)
    df = df + mallImg{kk}.img;
end
df = df/length(trials);

disp('Writing results to disk');
fileName = makeName('mean_hi_lo.mat',pThisRecording.root_folder);
save(fileName,'df','-v7.3');


function dfSeq = readTiff(fileName)
info = imfinfo(fileName);
num_images = numel(info);
dfSeq = zeros(info(1).Width,info(1).Height,num_images,'uint16');
parfor k = 1:num_images
    dfSeq(:,:,k) = imread(fileName,'tif',k);
end
