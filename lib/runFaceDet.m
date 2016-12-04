% runFaceDet.m - Runs face detector on image.
%
% (C)opyright Ashton Fagg, 2016

function bbox = runFaceDet(im)
    fDet = vision.CascadeObjectDetector();
    boxes = step(fDet, im);
    
    if (isempty(boxes))
        bbox = [];
    else
        % select the biggest box
        nBoxes = size(boxes,1);
        boxSz = zeros(nBoxes, 1);
        for i = 1:nBoxes
            boxSz(i) = boxes(i,3)*boxes(i,4);
        end
        
        [~, bigIdx] = max(boxSz);
        bigIdx = bigIdx(1);
        bbox = boxes(bigIdx, :);
    end
    
end