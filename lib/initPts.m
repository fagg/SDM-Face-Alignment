% initPts.m - Given a bounding box, use the mean shape to produce
% an initialization.
%
% (C)opyright Ashton Fagg, 2016

function iPts = initPts(model, bbox, scale)    
    iPts = reshape(model.mu, [], 2);
        
    minX = min(iPts(:,1));
    maxX = max(iPts(:,1));
    minY = min(iPts(:,2));
    maxY = max(iPts(:,2));
    
    faceSzX = maxX-minX;
    faceSzY = maxY-minY;
    scaleX = scale/(faceSzX/bbox(3));
    scaleY = scale/(faceSzY/bbox(4));        
    iPts(:,1) = scaleX * (iPts(:,1));
    iPts(:,2) = scaleY * (iPts(:,2));
    
    boxCen = [bbox(1)+bbox(3)/2 bbox(2)+bbox(4)/2];
            
    iPts(:,1) = iPts(:,1) + boxCen(1);
    iPts(:,2) = iPts(:,2) + boxCen(2);
end