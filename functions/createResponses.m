function Experiment = createResponses(Experiment)

% Parameters
halfHeight = (Experiment.Env.ScreenSizeY/ 2);
imageRect = [Experiment.Env.ScreenCenterX  - halfHeight, Experiment.Env.ScreenCenterY - halfHeight, Experiment.Env.ScreenCenterX + halfHeight,Experiment.Env.ScreenCenterY + halfHeight]; % Rectangle around screenCenter 
stimSize = Experiment.Env.ScreenSizeY - 0.1* Experiment.Env.ScreenSizeY ; % Make the letter 10% smaller than screen height

% Define folder to which images are saved
destination = fullfile(Experiment.Paths.MainPath, 'responses');
if ~exist(destination, 'dir') % Make new one if it doesn't exist
       mkdir(destination)
end

window = Experiment.Display.window;

%% Create Y/N responses
% stimSet = ['Y', 'N'];
% ynFolderLocation = destination;
% Screen('TextSize', window, stimSize);
% responseData = table(zeros(length(stimSet),1), strings(length(stimSet), 1));
% responseData.Properties.VariableNames = {'textureIndex', 'imageName'}';
% 
% for i = 1:length(stimSet)
%     % Write the text on screen
%     pr = sprintf(stimSet(i));
%     DrawFormattedText(window, pr, 'center', 'center', [0, 0, 0]);
%     Screen('Flip', window); % time.iifi hard coded
%     WaitSecs(0.01);
%     % Save  to folder
%     image_i = Screen('GetImage', window, imageRect);
%     imwrite(image_i, fullfile(ynFolderLocation, [stimSet(i), '.png']), 'PNG');
%     % Make texture
%     texture = Screen('MakeTexture', window, image_i);   
%     % Save info
%     responseData.textureIndex(i) = texture;
%     responseData.imageName(i) = stimSet(i);    
%     % Remove from screen
%     Screen('Flip', window); 
% end

%% Load Y/N responses
%If responses are already existing, just load them
stimSet = ['Y', 'N'];
ynFolderLocation = destination;
responseData = table(zeros(length(stimSet),1), strings(length(stimSet), 1));
responseData.Properties.VariableNames = {'textureIndex', 'imageName'}';

for i = 1:length(stimSet)
    % Load from folder
    image_i = imread(fullfile(ynFolderLocation, [stimSet(i), '.png']));
    % Make texture
    texture = Screen('MakeTexture', window, image_i);   
    % Save info
    responseData.textureIndex(i) = texture;
    responseData.imageName(i) = stimSet(i);    
end

%% Load into VRAM
% If possible, preload responses into VRAM
texturesLoaded = Screen('PreloadTextures', window, responseData.textureIndex);
if ~texturesLoaded
    error('Response textures could not be loaded into VRAM.')
end    

Experiment.Images.ResponseData = responseData;