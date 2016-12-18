% SDMSolve() - Solves for SDM regressor via ridge regression.
%
% (C)opyright 2016, Ashton Fagg

function R = SDMSolve(FFt, DFt, lambda)
    ll = eye(size(FFt)) .* lambda;
    ll(end,end) = 0; % don't regularize the bias term
    R = DFt / (FFt + ll);
end


