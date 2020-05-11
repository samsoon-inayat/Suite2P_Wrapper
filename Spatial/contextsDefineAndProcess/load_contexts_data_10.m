function sei = load_contexts_data_10(sei)
%% load the contexts into ei variable
sei = loadContextsResponses(sei);
disp('Contexts Loaded!!!');

%% find fractal dim
sei = fractalDim(sei,'belt',0);
sei = fractalDim(sei,'air',0);
sei = fractalDim(sei,'airOnsets27',0);
sei = fractalDim(sei,'airOffsets27',0);
sei = fractalDim(sei,'airOnsets010',0);
sei = fractalDim(sei,'airOffsets010',0);

%% do gaussian fit on means (for now on distance rasters and for air trials only)
sei = gaussfitOnMeans(sei,'belt',0);
sei = gaussfitOnMeans(sei,'air',0);
sei = gaussfitOnMeans(sei,'airOnsets27',0);
sei = gaussfitOnMeans(sei,'airOffsets27',0);
sei = gaussfitOnMeans(sei,'airOnsets010',0);
sei = gaussfitOnMeans(sei,'airOffsets010',0);
% sei = gaussfitOnMeansT(sei,'light',0);
disp('Gaussian fitting done!!!');
%% find place cell properties
sei = placeCellProperties(sei,'air',0);
sei = placeCellProperties(sei,'belt',0);
disp('Place cell properties done!!!');
