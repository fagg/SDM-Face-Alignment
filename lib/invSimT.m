% invSimT.m - Calculates inverse similarity transform
%
% (C)opyright 2016, Ashton Fagg
%
% Originally written by Chen-Hsuan Lin

function invA=invSimT(A)
    iM=inv(A(:,1:2));
    a=iM(1,1);
    b=iM(2,1);
    t=-iM*A(:,3);
    invA=[[a,-b;b,a],t];
end
