function allContexts = contextDefinitions

allContexts.names = {
    'Light - Brake';
    'Air - Brake';
    'Air - No Cues - No Brake';
    'Air - Light - No Brake';
    'Air - Cues - No Brake';
    'Air - Cues - Brake';
    'Air - No Cues - Brake';
    'Air - Tone - Brake';
    'Air - Light - Brake';
    'Tone - Brake';
    };


allContexts.ids = (1:length(allContexts.names))';

% display the following table to fill the variable contextIDs
% such that you are letting the program know the sequence of contexts the 
% mouse was exposed to
table(allContexts.ids,allContexts.names);

allContexts.typesOfMarkers = {'air';'belt';'motionOnsetsOffsets';'airOnsets22';'airOffsets22';'motionI';'motionOnsets22';'motionOffsets22';...
    'airI';'motionOffsetAirOnset';'light';'tone';'airOnsets27';'airOffsets27';'airOnsets11';'airOffsets11';'airOnsets010';'airOffsets010';...
    'airOnsets01';'airOffsets01'};

allContexts.typesOfRasters = {{'dist';'time'};'dist';{'dist';'time'};'time';'time';'time';'time';'time';...
    {'dist';'time'};'time';'time';'time';'time';'time';'time';'time';'time';'time';...
    'time';'time'};

allContexts.rasterFunctions = {'find_MI';'getFits_myGaussFit';'fractalDim'};
allContexts.varNames = {'info_metrics';'gauss_fit_on_mean';'fractal_dim'};



