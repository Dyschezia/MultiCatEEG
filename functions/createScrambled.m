% Specify things
rng(str2double(Experiment.Subject.ID) + 508593)

dirImages = dir(fullfile(Experiment.Paths.LocalizerDir, '*.png'));
dimImage  = 2000; % dimension of the uploaded image
sizeSquare = 50; % size of the squares
numSquares = dimImage/sizeSquare; % number of squares given dim of image and squares
repImageSample = numSquares^2/length(dirImages); 

numMasks = 100; % number of masks to generate

% Check whether it'll run given the parameters

if mod(dimImage,sizeSquare)==0
else
    error("Indivisible")
end
    
if mod(numSquares^2,length(dirImages))==0
else
    error("Indivisible")
end

%% Run analysis

imageMatrix = zeros(dimImage,dimImage,length(dirImages));

for i = 1:length(dirImages)
    imageMatrix(:,:,i) = imread(fullfile(dirImages(i).folder,dirImages(i).name));
end

squareMatrix = zeros(numSquares*numSquares,sizeSquare,sizeSquare,length(dirImages));

dim=0;
for l1 = 1:sizeSquare:dimImage
    for l2 = 1:sizeSquare:dimImage
        dim=dim+1;
        squareMatrix(dim,:,:,:) = imageMatrix(l1:l1+sizeSquare-1,l2:l2+sizeSquare-1,:);
    end
end

%% Loop to generate [numMasks] masks

mkdir(fullfile(Experiment.Paths.LocalizerDir, 'scrambled'));

for m=1:numMasks
    selectFromImages = repmat(1:length(dirImages),1,repImageSample);
    selectFromImages = selectFromImages(randperm(length(selectFromImages)))';

    maskIm = zeros(dimImage,dimImage);

    square = 0;
    for s1 = 1:numSquares
        dim1Image = (s1-1)*sizeSquare+1;
        dim2Image = sizeSquare*s1;

        for s2=1:numSquares
            dim1Image2 = (s2-1)*sizeSquare+1;
            dim2Image2 = sizeSquare*s2;
            square=square+1;

            maskIm(dim1Image:dim2Image,dim1Image2:dim2Image2) = squeeze(squareMatrix(square,:,:,selectFromImages(square)));
        end
    end

    filename=sprintf('scrambled/mask%02d.png', m);
    imwrite(single(maskIm/256), fullfile(Experiment.Paths.LocalizerDir, filename), 'png');
end



