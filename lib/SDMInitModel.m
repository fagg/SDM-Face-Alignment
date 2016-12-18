% Initializes new SDM model
%
% (C)opyright 2016, Ashton Fagg

function model = SDMInitModel(name)
model = struct();
model.name = name;
model.nLayers = 0;
model.mu = [];
model.regParams = [];
model.regressors = {};
end
