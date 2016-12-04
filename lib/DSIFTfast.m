% DSIFTFast.m - Extracts DSIFT features.
%
% Based on code by originally written by Chen-Hsuan Lin.
%
%
% (C)opyright Ashton Fagg, 2016

function dsift= DSIFTfast(patch)

    assert(size(patch,1)==size(patch,2),'patch shape should be square (for now)');
    patchSize=size(patch,1);
    patch=double(patch);
    numBinXY=4;
    numBinT=8;
    binSize=patchSize/numBinXY;
    windowSize=2;
    dsift=zeros(numBinXY*numBinXY*numBinT,1);

    
    % compute x and y derivatives
    gradY=zeros(size(patch));
    gradY(1,:)=patch(2,:)-patch(1,:);
    gradY(2:end-1,:)=(patch(3:end,:)-patch(1:end-2,:))/2;
    gradY(end,:)=patch(end,:)-patch(end-1,:);
    gradX=zeros(size(patch));
    gradX(:,1)=patch(:,2)-patch(:,1);
    gradX(:,2:end-1)=(patch(:,3:end)-patch(:,1:end-2))/2;
    gradX(:,end)=patch(:,end)-patch(:,end-1);

    
    %angle and modulus
    angle=atan2(gradY,gradX);
    angleMod2PI=mod(angle,2*pi);
    modulus=sqrt(gradX.^2+gradY.^2);

    
    % quantize angle
    nt=angleMod2PI*numBinT/(2*pi);
    bint=floor(nt);
    rbint=nt-bint;
    
    
    % write to gradient
    modVec=modulus(:);
    bintVec=bint(:);
    rbintVec=rbint(:);
    gradient=cell(numBinT,1);
    [gradient{:}]=deal(zeros(patchSize*patchSize,1));
    for bt=1:numBinT
	gradient{bt}(bintVec+1==bt)=modVec(bintVec+1==bt).*(1-rbintVec(bintVec+1==bt));
	if(bt==numBinT)
		gradient{1}(bintVec+1==bt)=modVec(bintVec+1==bt).*rbintVec(bintVec+1==bt);
	else
		gradient{bt+1}(bintVec+1==bt)=modVec(bintVec+1==bt).*rbintVec(bintVec+1==bt);
	end
    end
    
    gradient=cellfun(@(grad) reshape(grad,[patchSize,patchSize]),gradient,'uniformoutput',false);

    
    % flat window
    triangleWindow=[1:binSize,binSize-1:-1:1]'/binSize^2;
    triangleKernel=triangleWindow*triangleWindow';
    % get mean of windows (weighting)
    w=getBinWindowMean(numBinXY,binSize,windowSize);
    for bt=1:numBinT
	% conv2 (only on the 4x4 bin centers)
        padGradient=myPadArray(gradient{bt},binSize/2);
        gradientSum=zeros(numBinXY,numBinXY);
        for bx=1:numBinXY
            for by=1:numBinXY
                gradientBin=padGradient((by-1)*binSize+1+[1:2*binSize-1],(bx-1)*binSize+1+[1:2*binSize-1]);
                gradientSum(by,bx)=sum(sum(gradientBin.*triangleKernel));
            end
        end
        dsiftSegmentMtrx=w.*gradientSum;
        dsift((bt-1)*numBinXY*numBinXY+[1:numBinXY*numBinXY])=dsiftSegmentMtrx(:);
    end

    % normalization
    dsift=dsift/(norm(dsift)+eps);
    dsift(dsift>0.2)=0.2;
    dsift=dsift/(norm(dsift)+eps);
end
% ===================================================

function padPatch=myPadArray(patch,padSize)

patchSize=size(patch,1);
padPatch=zeros(patchSize+2*padSize);
padPatch(1:padSize,1:padSize)=patch(1,1);
padPatch(1:padSize,padSize+[1:patchSize])=repmat(patch(1,:),[padSize,1]);
padPatch(1:padSize,padSize+patchSize+[1:padSize])=patch(1,end);
padPatch(padSize+[1:patchSize],1:padSize)=repmat(patch(:,1),[1,padSize]);
padPatch(padSize+[1:patchSize],padSize+[1:patchSize])=patch;
padPatch(padSize+[1:patchSize],padSize+patchSize+[1:padSize])=repmat(patch(:,end),[1,padSize]);
padPatch(padSize+patchSize+[1:padSize],1:padSize)=patch(end,1);
padPatch(padSize+patchSize+[1:padSize],padSize+[1:patchSize])=repmat(patch(end,:),[padSize,1]);
padPatch(padSize+patchSize+[1:padSize],padSize+patchSize+[1:padSize])=patch(end,end);
end
% ===================================================

function windowMean=getBinWindowMean(numBinXY,binSize,windowSize)

binIdx=[1:numBinXY]';
delta=binSize*(binIdx-1-0.5*(numBinXY-1));
sigma=binSize*windowSize;
x=[-binSize+1:binSize-1];
z=bsxfun(@minus,x,delta)/sigma;
acc=sum(exp(-0.5.*z.*z),2);
binMean=acc/(2*binSize-1)*binSize;
windowMean=binMean*binMean';
end
