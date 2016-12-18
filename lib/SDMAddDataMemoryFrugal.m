% SDMAddDataMemoryFrugal() - Adds data for SDM training
%
% (C)opyright 2016, Ashton Fagg

function data = SDMAddDataMemoryFrugal(imageList, landmarkList, nSynth, model)

images = getListOfFiles(imageList);
landmarks = getListOfFiles(landmarkList);
    
    
assert(numel(images) == numel(landmarks));
nFrames = numel(images);

FFt = 0;
DFt = 0;
DDt = 0;

% Fire up worker threads
p = gcp('nocreate');
if (isempty(p))
    p = parpool(4);
end


nChunks = p.NumWorkers;
chunkStats = cell(nChunks, 1);
chunkIndices = generateChunkIndices(nFrames, nChunks);

parfor c = 1:nChunks
    rng(randSeedVal);
    cIdx = find(chunkIndices==c);
    cImages = images(cIdx);
    cLandmarks = landmarks(cIdx);
    chunkStats{c} = doChunk(model, nSynth, cImages, cLandmarks, c);
end


data = struct();
data.nExamples = chunkStats{1}.nExamples;

data.FFt = chunkStats{1}.FFt;
data.DFt = chunkStats{1}.DFt;
data.DDt = chunkStats{1}.DDt;

for c = 2:numel(chunkStats)
    data.FFt = data.FFt+chunkStats{c}.FFt;
    data.DFt = data.DFt+chunkStats{c}.DFt;
    data.DDt = data.DDt+chunkStats{c}.DDt;
    data.nExamples = chunkStats{c}.nExamples + data.nExamples;
end


end

function idx = generateChunkIndices(nExamples, nChunks)
    idx = zeros(nExamples, 1);
    for i = 1:numel(idx)
        idx(i) = randi([1 nChunks], 1, 1);
    end
    
end


function chunkData = doChunk(model, nSynth, images, landmarks, chunkID)
    fprintf('Starting chunk %d\n', chunkID);
    chunkData = struct();
    chunkData.FFt = [];
    chunkData.DFt = [];
    chunkData.DDt = [];
    chunkData.nExamples = 0;
    
    nPts = numel(model.mu)/2;
    if (nPts == 49)
        loadPts = @(x) loadPts49(x);
    else
        loadPts = @(x) loadPtsAll(x);
    end
    

    for i = 1:numel(images)
        fprintf('Chunk %d, collecting stats from frame %d of %d -> %d pertubations.\n', chunkID, i, numel(images), nSynth);
        
        
        [df, ff] =  addFrame(loadIm(images{i}), loadPts(landmarks{i}), ...
                             model, nSynth, ...
                             numel(model.regressors)+1);

        
        if (i==1)
            fDim = size(ff,1);
            dDim = size(df,1);
            chunkData.FFt = zeros(fDim, fDim);
            chunkData.DFt = zeros(dDim, fDim);
            chunkData.DDt = zeros(dDim, dDim);
        end
        
        
        chunkData.FFt = chunkData.FFt + (ff*ff');
        chunkData.DFt = chunkData.DFt + (df*ff');
        chunkData.DDt = chunkData.DDt + (df*df');
        chunkData.nExamples = chunkData.nExamples + nSynth;
        
    end
    

    
    
end



function [deltaFrame, featFrame] = addFrame(im, pts, model, nSynth, layer)
    deltaFrame = [];
    featFrame = [];
    refPts = reshape(model.mu, [], 2);
    nPts = size(refPts, 1);
    
    minX = min(refPts(:,1)) + 1.0;
    minY = min(refPts(:,2)) + 1.0;
    
    refPts = refPts + repmat([minX minY], nPts, 1);
    
    for example = 1:nSynth
        ptsNoise = addSimTNoise(pts, model.mu);
        ptsNoise = SDMApply(im, ptsNoise, model);
        
        [wIm, wPtsIm, wParam, wGt, delta] = doWarp(im, ptsNoise, refPts, pts);
        
        feats = featureExtractDSIFT(wIm, wPtsIm);
        feats = [feats(:); 1];
        feats = double(feats);
        
        deltaFrame = [deltaFrame delta(:)];
        featFrame = [featFrame feats(:)];
    end

end

function list = getListOfFiles(fileList)
    fd = fopen(fileList);
    list = textscan(fd, '%s');
    list = list{1};
    fclose(fd);
end

function currIm = loadIm(imageFile)
    currIm = imread(imageFile);
    if (size(currIm,3) == 3)
        currIm = rgb2gray(currIm);
    end
end

function currPts = loadPts49(ptsFile)
    try
        currPts = load(ptsFile);
    catch
        ff = fopen(ptsFile);
        shape = textscan(ff, '%f %f', 'HeaderLines', 3, 'CollectOutput', 2);
        fclose(ff);
        currPts = shape{1};
    end
    currPts = currPts([18:60, 62:64, 66:68], :);
end

function currPts = loadPtsAll(ptsFile)
    try
        currPts = load(ptsFile);
    catch
        ff = fopen(ptsFile);
        shape = textscan(ff, '%f %f', 'HeaderLines', 3, 'CollectOutput', 2);
        fclose(ff);
        currPts = shape{1};
    end
end





