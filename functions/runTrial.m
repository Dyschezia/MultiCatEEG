function Experiment = runTrial(Experiment)

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
imageData = Experiment.Images.ImageData;

% Visual
screenCenter = [Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY];

% Locate the session, set, run, trial
session = Experiment.Subject.WhichSession;
set = Experiment.Subject.WhichSet;
run = Experiment.Log.CurrentRun;
trial = Experiment.Log.CurrentTrial;

% Locate the stimulus array for this trial
allRuns = Experiment.Session(session).Set(set).RunShuffled;
thisRun = allRuns(run);
allTrials = thisRun.StimArrays;
thisTrialStimArray = allTrials(trial, :);

% Is it a catch trial?
isCatch = thisRun.CatchTrials(trial);
if isCatch
    catchType = thisRun.CatchType(trial);
    catchResponse = thisRun.CatchResponse(trial);
end
Experiment.Log.IsCatch = isCatch;

% Is it a 1-item array trial?
isSingle = thisRun.Is1Array(trial);
Experiment.Log.IsSingle = isSingle;

% Convert stimulus array indices to preloaded texture pointers 
texturePointers = [];
if isSingle % For single arrays
    loc = find(thisTrialStimArray~=0);
    image = thisTrialStimArray(loc);
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

% Choose probe and assign
if isCatch
    
    if catchType == 1 % YES trial - In this case, probe should be drawn from the stimulus array
        if isSingle
            texturePointersPrompt = texturePointers;
        else
            texturePointersPrompt = texturePointers(randi(length(texturePointers)));
        end
    elseif catchType == 2 % NO trial - a category not in stimulus array
        arrayCat =  imageData.imageCategory(ismember(imageData.imageIndex, thisTrialStimArray')); % Categories in the array
        allOther = imageData.imageIndex(~ismember(imageData.imageCategory, arrayCat')); % Indices of images of not those categories
        prompt = allOther(randi(length(allOther)));
        texturePointersPrompt = imageData.textureIndex(imageData.imageIndex==prompt);
    else
        error('CatchType is neither 1 (YES) nor 2 (NO) - something is wrong. Check your trial structure.')
    end
    
    % Add yes/no
    texYes = Experiment.Images.ResponseData.textureIndex( Experiment.Images.ResponseData.imageName=="Y");
    texNo = Experiment.Images.ResponseData.textureIndex( Experiment.Images.ResponseData.imageName=="N");
    if catchResponse == 1 % The first response case (Yes on the left)
        texturePointersPrompt = [texturePointersPrompt, texYes, texNo];
    elseif catchResponse == 2 % The second response case (No on the left)
         texturePointersPrompt = [texturePointersPrompt, texNo, texYes];
    else
        error('CatchResponse is neither 1 (YES left) nor 2 (NO left) - something is wrong. Check your trial structure.')
    end
    
    % Calculate which response is correct - left or right
    if catchType==1 && catchResponse==1 % If the response is YES and YES is on the left
        correct_response="left";
    elseif catchType==1 && catchResponse==2 % If the correct is YES and YES is on the right
        correct_response="right";
    elseif catchType==2 && catchResponse==1 % If the correct is NO and NO is on the right
        correct_response="right";
    elseif catchType==2 && catchResponse==2 % If the correct is NO and NO is on the left
        correct_response = "left";
    end
    
    % Add locations on screen
    destinationRectsPrompt = Experiment.Images.RectDestinationsProbe;
end

% Fixation
fixRadius = Experiment.Stim.FixationPixels; 
fixColor = Experiment.Stim.FixationColour;

% Feedback color
feedbackCorrect = [0, 255, 0]; %[0 0.9 0.1] .* 
feedbackWrong = [255, 0, 0]; %[0.9 0.1 0] .* 
feedbackRegister =  [255, 255, 255]; %[0.2 0.2 0.2] .* % Color to register response
feedbackFixation =[255, 255, 255]; % [0.7 0.2 0.3] .* 
    
% Timing
initialGap = Experiment.Time.StartGap;
itiGap =  thisRun.ITIs(trial);
itiCatch1 = Experiment.Time.CatchIti1;
%itiCatch2 = Experiment.Time.CatchIti2;
halfifi = Experiment.Env.HalfIFI;
stimExpTime = Experiment.Time.StimExpTime;
respTime = Experiment.Time.RespWait;
feedbackTime = Experiment.Time.FeedbackGap;

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

% Depending on whether it's a response (catch) trial or not
if ~isCatch % If it's not catch
    % Draw fixation and wait for ITI
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2);
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'fixation'}];
    expectedTime = expectedTime + itiGap; % Wait for a variable ITI
    
else % If it is a catch trial
    % Draw fixation and wait for first part of the delay
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2);
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'fixation'}];
    expectedTime = expectedTime + itiCatch1; % Wait for first part of the catch gap
    
    % Show the prompt screen
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2); % Fixation
    Screen('DrawTextures', myWin, texturePointersPrompt, [], destinationRectsPrompt); % Prompt screen
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'promptScreen'}];
    expectedTime = expectedTime + respTime;
    if saveExpImages
        img = Screen('GetImage', myWin);
        imwrite(img, 'promptScreen.png', 'PNG');
    end
    
    % Collect the response
    begin_response = GetSecs();
    end_response = begin_response +  Experiment.Time.RespWait;
    response = [];
    keyDown = 0;
    
    RestrictKeysForKbCheck([Experiment.Keys.LeftResponse, Experiment.Keys.RightResponse, Experiment.Keys.EscKey]);
    while GetSecs() < end_response 
        [keyDown, secs, keyCode, deltaSecs] = KbCheck();
        if keyDown 
            key=find(keyCode);
            break;
        end
    end
    
    if keyDown
        % Save RT
        rt = secs - begin_response;
        rt_resolution = deltaSecs;
        
        if key == responseLeft
            response = "left";
            resprect = destinationRectsPrompt(:,2);
        elseif key == responseRight
            response = "right";
            resprect = destinationRectsPrompt(:,3);
        elseif key == escKey
            Experiment.Log.Exit = 1;
            return;
        end
        
        % Draw register rectangle
        Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2); % Fixation
        Screen('DrawTextures', myWin, texturePointersPrompt, [], destinationRectsPrompt); % Prompt screen
        Screen('FrameRect', myWin, feedbackRegister, resprect, 4);
        Screen('DrawingFinished', myWin);
        vbl = Screen('Flip', myWin);
        timeRealFlip = [timeRealFlip,  vbl - startTime];
        timeExpectedFlip = [timeExpectedFlip, NaN];
        whichObject = [whichObject, {'response'}];
    end
            
    % Feedback
    if isempty(response) % Change the fixation color if there's no response
        Screen('DrawDots', myWin, screenCenter, fixRadius,  feedbackFixation, [], 2);
        Screen('DrawingFinished', myWin);
        vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi); % After response time is out show feedback
        expectedTime = expectedTime + feedbackTime;
    else 
        if strcmp(correct_response, response) 
            feedback_color = feedbackCorrect; % If the response is correct
        else 
            feedback_color = feedbackWrong; % If the response is wrong
        end
          
        Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2); % Fixation
        Screen('DrawTextures', myWin, texturePointersPrompt, [], destinationRectsPrompt); % Prompt screen
        Screen('FrameRect', myWin, feedback_color, resprect, 4);
        Screen('DrawingFinished', myWin);
        vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi); % After response time is out show feedback
        timeRealFlip = [timeRealFlip,  vbl - startTime];
        timeExpectedFlip = [timeExpectedFlip, NaN];
        whichObject = [whichObject, {'feedback'}];
        expectedTime = expectedTime + feedbackTime;
    end
    
    if saveExpImages
        img = Screen('GetImage', myWin);
        imwrite(img, 'feedbackScreen.png', 'PNG');
    end
    
    % Draw fixation and wait for second part of the delay
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2);
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'fixation'}];
    expectedTime = expectedTime + itiGap; % Wait for first part of the catch gap
           
end

Experiment.Log.ExpectedTime = expectedTime;
Experiment.Log.StartTime = startTime;
Experiment.Log.timeRealFlip = timeRealFlip;
Experiment.Log.timeExpectedFlip = timeExpectedFlip;
Experiment.Log.whichObject = whichObject;

%%% Save the data
Experiment = saveLog(Experiment, 'timing_data'); % Timing Log
if isCatch
    if exist('key', 'var')
        Experiment.Log.key = key;
        Experiment.Log.response = response;
        Experiment.Log.iscorrect = strcmp(response, correct_response);
    else
        Experiment.Log.key = 0;
        Experiment.Log.response = "missed";
        Experiment.Log.iscorrect = 0;
    end
   
    Experiment = saveLog(Experiment, 'log_data'); % Timing Log
end

end