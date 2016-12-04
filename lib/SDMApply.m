% SDMApply.m - Applies all regressors in succession.
%
%
% (C)opyright Ashton Fagg, 2016

function [pts, feats] = SDMApply(im, pts, model)
    
    refPts = reshape(model.mu, [numel(model.mu)/2 2]);
    nPts = size(refPts, 1);
    
    minX = min(refPts(:,1)) + 1.0;
    minY = min(refPts(:,2)) + 1.0;
    
    refPts = refPts + repmat([minX minY], nPts, 1);

    for layer = 1:model.nLayers
        A = calcSimT(pts, refPts);
        wPts = [pts, ones(numel(model.mu)/2, 1)] * A';
        % warp the current point estimate into the template
        [wIm, wPtsIm, wParam] = doWarp(im, pts, refPts);
        
        % Extract features from the image and apply the regressor
        feats = featureExtractDSIFT(wIm, wPtsIm);
        feats = [feats(:); 1]; % add bias
        delta = model.regressors{layer} * feats;
    
        % Update the point estimate inside the template and warp it back out
        pts = [wPts + reshape(delta,[], 2), ones(numel(model.mu)/2,  1)]*invSimT(A)';
    end
    
end
