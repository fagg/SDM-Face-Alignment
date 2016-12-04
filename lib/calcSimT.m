% calcSimT.m - Calculates similarity transform between srcPts and dstPts
%
%
% (C)opyright Ashton Fagg, 2016
%
% Originally written by Chen-Hsuan Lin

function A = calcSimT(srcPts,dstPts)

    assert(size(srcPts,1)==size(dstPts,1),'Number of srcPts and dstPts should be consistent');
    ptsN=size(srcPts,1);
    H=zeros(4,4);
    g=zeros(4,1);
    
    % set up linear systems
    H(1,1)=sum(srcPts(:).^2);
    H(1,3)=sum(srcPts(:,1));
    H(1,4)=sum(srcPts(:,2));
    H(2,2)=sum(srcPts(:).^2);
    H(2,3)=-sum(srcPts(:,2));
    H(2,4)=sum(srcPts(:,1));
    H(3,1)=sum(srcPts(:,1));
    H(3,2)=-sum(srcPts(:,2));
    H(3,3)=ptsN;
    H(4,1)=sum(srcPts(:,2));
    H(4,2)=sum(srcPts(:,1));
    H(4,4)=ptsN;
    g(1)=sum(srcPts(:).*dstPts(:));
    g(2)=sum(srcPts(:,1).*dstPts(:,2)-srcPts(:,2).*dstPts(:,1));
    g(3)=sum(dstPts(:,1));
    g(4)=sum(dstPts(:,2));
   
    % solve the linear system
    p=H\g;
    
    % create the affine transformation matrix
    a=p(1);
    b=p(2);
    tx=p(3);
    ty=p(4);
    A=[a,-b,tx;b,a,ty];
end
