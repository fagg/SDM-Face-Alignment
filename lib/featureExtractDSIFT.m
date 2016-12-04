% featureExtractDSIFT.m - This performs patch interpolation and
% extracts features.
%
%
% (C)opyright Ashton Fagg, 2016

function feats = featureExtractDSIFT(im, pts)
    patchSize = 16;
    binSize = patchSize / 4;
    nPts = numel(pts)/2;
    feats = zeros(128, nPts);
    [R, C] = size(im);

    for pt = 1:nPts
        xCenter = pts(pt,1);
        yCenter = pts(pt,2);
        
        xCenterFloor=floor(xCenter);
        yCenterFloor=floor(yCenter);
        xRatio=xCenter-xCenterFloor;
        yRatio=yCenter-yCenterFloor;
        
        idx1R = yCenterFloor + [-patchSize/2:patchSize/2-1];
        idx1C = xCenterFloor + [-patchSize/2:patchSize/2-1];
        
        idx2R = yCenterFloor + [-patchSize/2:patchSize/2-1];
        idx2C = xCenterFloor + 1 + [-patchSize/2:patchSize/2-1];
        
        idx3R = yCenterFloor + 1 + [-patchSize/2:patchSize/2-1];
        idx3C = xCenterFloor + [-patchSize/2:patchSize/2-1];
        
        idx4R = yCenterFloor + 1 + [-patchSize/2:patchSize/2-1];
        idx4C = xCenterFloor + 1 + [-patchSize/2:patchSize/2-1]; 
        


        patch = im(fixBounds(idx1R, R), fixBounds(idx1C, C))*(1-xRatio)*(1-yRatio);
        patch = patch + im(fixBounds(idx2R, R), fixBounds(idx2C, C))*(xRatio)*(1-yRatio);
        patch = patch + im(fixBounds(idx3R, R), fixBounds(idx3C, C))*(1-xRatio)*(yRatio);
        patch = patch + im(fixBounds(idx4R, R), fixBounds(idx4C, C))*(xRatio)*(yRatio);
    
        ptFeats=DSIFTfast(patch);
        
        feats(:, pt) = ptFeats;
    end

end

function idx = fixBounds(x, upper)
    for i = 1:numel(x)
        if (x(i) < 1)
            idx(i) = 1;
        elseif (x(i) > upper)
            idx(i) = upper;
        else
            idx(i) = x(i);
        end
    end
    
end


