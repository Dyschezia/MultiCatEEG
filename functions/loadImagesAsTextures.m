function Experiment = loadImagesAsTextures(Experiment)
% Loads all stimuli to be used in the experiment as images from a folder.
% Also loads the textures for the response screen. 

%% Variables

% Path to images of individual stimuli
imagePath = Experiment.Paths.ImageDir;
listImages =  [dir(fullfile(imagePath, '*.jpg')), dir(fullfile(imagePath, '*.png'))]; % Get a list of all items in the directory
nImages = length(listImages); % Number of images to be used as stimuli
if nImages == 0
    error('No images in the image folder.')
end    

% If loading the images for a localizer
if strcmp(Experiment.Mode.imagemode, 'localizer')
    imagePath = Experiment.Paths.LocalizerDir;
    listImages =  [dir(fullfile(imagePath, '*.jpg')), dir(fullfile(imagePath, '*.png'))]; % Get a list of all items in the directory
    %listImagesScrambled =  [dir(fullfile(imagePath,'scrambled', '*.jpg')), dir(fullfile(imagePath, 'scrambled', '*.png'))]; % Get a list of all items in the directory
    %listImages = [listImages1; listImagesScrambled];
    nImages = length(listImages); % Number of images to be used as stimuli
    if nImages == 0
        error('No images in the image folder.')
    end
end
    
% Display
myWin = Experiment.Display.window;

% %% Resize images for testing purposes
% resizedPath = fullfile(Experiment.Paths.MainPath, 'stimulusSetResized');
% for imageIdx = 1:nImages
%     % Read an image
%     imageName = listImages(imageIdx).name;
%     thisImageLocation = fullfile(imagePath, imageName);
%     [thisImage, ~, ~] = imread(thisImageLocation);
%     resized = imresize(thisImage,0.1,'nearest'); % Resize to 30% using nearest neighbour
%     imwrite(resized, fullfile(resizedPath, [imageName, '.png']), 'PNG');
%     disp(imageIdx)
% end
%% Load images as textures into imageTex structure

% Preallocate matrix of all images as textures
imageTex = zeros(nImages,1); % Preallocate

imageData = table(zeros(nImages,1), strings(nImages, 1), zeros(nImages,1), zeros(nImages,1), zeros(nImages,1));
imageData.Properties.VariableNames = {'textureIndex', 'imageName', 'imageCategory', 'imageExemplar', 'imageOrientation'}';

% Activate for alpha
%Screen('BlendFunction', myWin, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

for imageIdx = 1:nImages
    
    % Read an image
    imageName = listImages(imageIdx).name;
    thisImageLocation = fullfile(imagePath, imageName);
    disp('Loaded image: ');
    disp(thisImageLocation);
    [thisImage, ~, ~] = imread(thisImageLocation);
   
    %Object information
    objectInfo = strsplit(imageName, '.'); 
    objectIdx = objectInfo{1}; % Full index of the image
    objectCat = objectIdx(1); % Images are named category-exemplar-orientation
    objectExmp = objectIdx(2);
    objectOrient = objectIdx(3); 
    
    imageTex(imageIdx) = Screen('MakeTexture', myWin, thisImage);     
    
    % Save info
    imageData.textureIndex(imageIdx) = imageTex(imageIdx);
    imageData.imageName(imageIdx) = imageName;
    imageData.imageIndex(imageIdx) = str2double(objectIdx);
    imageData.imageCategory(imageIdx) = str2double(objectCat);
    imageData.imageExemplar(imageIdx) = str2double(objectExmp);
    imageData.imageOrientation(imageIdx) = str2double(objectOrient);
      
end

%% Save to output struct

if strcmp(Experiment.Mode.imagemode, 'localizer')
    Experiment.Images.ImageDataLocalizer = imageData;
    Experiment.Images.ImageTexLocalizer = imageTex;
else
    Experiment.Images.ImageData = imageData;
    Experiment.Images.ImageTex = imageTex;
end

%% Preload into VRAM
% If possible, preload all textures into VRAM
texturesLoaded = Screen('PreloadTextures', myWin, imageTex);
if ~texturesLoaded
    error('Stimulus textures could not be loaded into VRAM.')
end    
