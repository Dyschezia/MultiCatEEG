function Experiment = runLocalizerTrial(Experiment)

% Toggle to save clips of experiment for reporting/schematic figures
saveExpImages = 1;

% Timing data saving
% Objects timed: 'fixation', 'stimulus'
timeRealFlip = []; 
timeExpectedFlip = [];
whichObject = [];

%% Extract variables

% Window
myWin = Experiment.Display.window;

% Preloaded textures
imageData = Experiment.Images.ImageDataLocalizer;

% Visual
screenCenter = [Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY];

% Fixation
fixRadius = Experiment.Stim.FixationPixels; 
fixColor = Experiment.Stim.FixationColour;

% Locate the stimulus array
trial = Experiment.Log.CurrentTrial;
thisTrialStimArray =  Experiment.Log.BlockData.StimArray{trial};

% Is it a catch trial?
isCatch = Experiment.Log.BlockData.CatchTrial(trial);
Experiment.Log.IsCatch = isCatch;

% Is it a 1-item array trial?
isSingle =  Experiment.Log.BlockData.IsSingle(trial);
Experiment.Log.IsSingle = isSingle;

% Convert stimulus array indices to preloaded texture pointers 
texturePointers = [];
if isSingle % For single arrays
    loc = unique(Experiment.Log.BlockData.Location(trial));
    image = thisTrialStimArray;
    texturePointers = imageData.textureIndex(imageData.imageIndex==image);
    destinationRects = Experiment.Images.RectDestinations(:, loc);
else % For 4-arrays
    for imageIdx = 1:length(thisTrialStimArray)
        image = thisTrialStimArray(imageIdx);
        % Find texture index for this image 
        imageTex = imageData.textureIndex(imageData.imageIndex==image);
        texturePointers = [texturePointers, imageTex]; % The vector of ‘texturePointers’ for the stimulus array
    end
    destinationRects = Experiment.Images.RectDestinations; % Assign stimuli to respective locations
end
   
% Timing
halfifi = Experiment.Env.HalfIFI;
stimExpTime = Experiment.Time.LocalizerStimOn;
itiGap = Experiment.Time.LocalizerStimOff;

% Response keys
% Add keys
escKey = Experiment.Keys.EscKey;
responseLeft = Experiment.Keys.LeftResponse;
responseRight = Experiment.Keys.RightResponse;

%% Begin the sequence

% Get the previous trial end time as the expected time
startTime = Experiment.Log.StartTime;
expectedTime = Experiment.Log.ExpectedTime;

% Show stimulus array
if ~isCatch % If it's not catch
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2); % Fixation
    if isSingle
        Screen('DrawTexture', myWin, texturePointers, [], destinationRects); % Stimulus
    else
        Screen('DrawTextures', myWin, texturePointers, [], destinationRects); % Stimulus
    end
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'stimulus'}];
    expectedTime = expectedTime + stimExpTime;
    if saveExpImages
        img = Screen('GetImage', myWin);
        imwrite(img, 'stimulus.png', 'PNG');
    end
    
else % If it is catch - flip one stimulus
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2); % Fixation
    if isSingle
        Screen('DrawTexture', myWin, texturePointers, [], destinationRects, 180); % 180 = rotation angle
    else
        rotloc = randi(4, 1, 1); % Choose a random item to rotate
        rotations = zeros(1,4);
        rotations(rotloc) = 180;
        Screen('DrawTextures', myWin, texturePointers, [], destinationRects, rotations); % Stimulus
    end
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'stimulus'}];
    expectedTime = expectedTime + stimExpTime;
    if saveExpImages
        img = Screen('GetImage', myWin);
        imwrite(img, 'stimulus.png', 'PNG');
    end
end

% Draw fixation and wait for ITI
Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2);
Screen('DrawingFinished', myWin);
vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
timeRealFlip = [timeRealFlip,  vbl - startTime];
timeExpectedFlip = [timeExpectedFlip, expectedTime];
whichObject = [whichObject, {'fixation'}];
expectedTime = expectedTime + itiGap; % Wait for a ITI
    

%% Save
Experiment.Log.ExpectedTime = expectedTime;
Experiment.Log.StartTime = startTime;
Experiment.Log.timeRealFlip = timeRealFlip;
Experiment.Log.timeExpectedFlip = timeExpectedFlip;
Experiment.Log.whichObject = whichObject;

%%% Save the data
Experiment = saveLog(Experiment, 'localizer_log'); 

end