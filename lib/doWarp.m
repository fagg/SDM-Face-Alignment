% doWarp() - Warps image to match current esimate.current
%
% (C)opyright 2016, Ashton Fagg

function varargout = doWarp(varargin)
    
    
    if (nargin==4)
        im = varargin{1};       % Current image 
        pts = varargin{2};      % Current point estimate
        refPts = varargin{3};   % Mean shape
        gtPts = varargin{4};    % Ground truth
    elseif (nargin==3)
        im = varargin{1};       % Current image
        pts = varargin{2};      % Current estimate
        refPts = varargin{3};   % Ground truth
        
    else
        error('Input arguments to doWarp do not make sense.');
    end
    
        
    if (nargin==3)
        A = calcSimT(pts, refPts);
    
        wParam = getTform(A);
        [wIm, xData, yData] = imtransform(im, wParam, 'XYScale', 1);
        width = xData(2) - xData(1) + 1;
        height = yData(2) - yData(1) + 1;
        xScale = size(wIm, 2) / width;
        yScale = size(wIm, 1) / height;
    
    
        % Warp to current estimate
        %wPts = tformfwd(wParam, pts);
        wPtsNoise = [pts, ones(numel(pts)/2,1)] * A';
        wPtsImN(:,1) = wPtsNoise(:,1) - xData(1) + 1;
        wPtsImN(:,2) = wPtsNoise(:,2) - yData(1) + 1;
        wPtsImN(:,1) = wPtsImN(:,1) * xScale;
        wPtsImN(:,2) = wPtsImN(:,2) * yScale;
        
        varargout{1} = wIm;
        varargout{2} = wPtsImN;
        varargout{3} = wParam;
        
    elseif (nargin==4)
        A = calcSimT(pts, refPts);
        
        wParam = getTform(A);
        [wIm, xData, yData] = imtransform(im, wParam, 'XYScale', 1);
        width = xData(2) - xData(1) + 1;
        height = yData(2) - yData(1) + 1;
        xScale = size(wIm,2) / width;
        yScale = size(wIm,1) / height;
        
        % Ground truth points
        wPtsGt = [gtPts, ones(numel(pts)/2,1)] * A';
        wPtsGt(:,1) = wPtsGt(:,1) - xData(1) + 1;
        wPtsGt(:,2) = wPtsGt(:,2) - yData(1) + 1;
        wPtsGt(:,1) = wPtsGt(:,1) * xScale;
        wPtsGt(:,2) = wPtsGt(:,2) * yScale;
        
        % "Noisy" points
        wPtsImN = [pts, ones(numel(pts)/2,1)] * A';
        wPtsImN(:,1) = wPtsImN(:,1) - xData(1) + 1;
        wPtsImN(:,2) = wPtsImN(:,2) - yData(1) + 1;
        wPtsImN(:,1) = wPtsImN(:,1) * xScale;
        wPtsImN(:,2) = wPtsImN(:,2) * yScale;
        
              
        % Fix the delta
        delta = wPtsGt - wPtsImN;
        delta = delta(:);
        
        varargout{1} = wIm;
        varargout{2} = wPtsImN;
        varargout{3} = wParam;
        varargout{4} = wPtsGt;
        varargout{5} = delta;
    end
end

function ret = getTform(A)
    ret = maketform('affine', [A(1,1) A(2,1); ...
                               A(1,2) A(1,1); ...
                               A(1,3) A(2,3)]);
end





