% SDMFinalizeLayer() - Finalizes SDM layer.
%
% (C)opyright 2016, Ashton Fagg
function model = SDMFinalizeLayer(model, R, finalParam)
model.regressors = [model.regressors; {R}];
model.nLayers = model.nLayers + 1;
model.regParams = [model.regParams; finalParam];
end
