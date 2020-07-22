function add_to_path
currentDir = pwd;
cd('..');
interDir = pwd;
cd('..');
mainDir = pwd;
% if ~exist(fullfile(mainDir,'Downloaded'),'dir')
    mainDir = '\\mohajerani-nas.uleth.ca\storage2\homes\samsoon.inayat\ForBrendan';
% end
cd(currentDir);
% addpath(scriptPath);

temp = fullfile(interDir,'MatlabCode');addpath(temp);
temp = fullfile(interDir,'MatlabCode','Common');addpath(temp);
temp = fullfile(mainDir,'Downloaded','append_pdfs');addpath(temp);
temp = fullfile(interDir,'MatlabCode','Thor2P');addpath(temp);
temp = fullfile(interDir,'MatlabCode','FigureFunctions');addpath(temp);
temp = fullfile(mainDir,'Downloaded','spatial-information-metrics');addpath(temp);
temp = fullfile(interDir,'MatlabCode','Fitting');addpath(temp);
temp = fullfile(mainDir,'Downloaded','npy-matlab');addpath(temp);
temp = fullfile(mainDir,'Downloaded');addpath(temp);
temp = fullfile(mainDir,'Downloaded','CNMF_E');p = genpath(temp);addpath(p);

temp = fullfile(mainDir,'Downloaded','Suite2P');p = genpath(temp);addpath(p);

temp = pwd; p = genpath(temp);addpath(p);
remove_from_path



