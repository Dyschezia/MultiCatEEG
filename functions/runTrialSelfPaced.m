function Experiment = runTrialSelfPaced(Experiment)
% RK(19/09/24) TODO:
% 2. RT is not being saved. 
% 3. EDIT SEND TRIGGER TO WAIT LESS TIME 
% Currently not adding trigger delay because it can just be added later. 

% Stimulus triggers are of the form of 1 - set,run,trial. Because there are
% 350 trials per run, this takes the form of 1 - set,run,hundreds -
% tens,ones. For example, trial 251 in run 3 set 2 will be 1 - 232 - 51.
% This cannot accomodate paradigms with more than 999 trials per run. 

% In this version of the function, the probe screen is not timed, and
% instead is self-paced by the subject.

% Toggle to save clips of experiment for reporting/schematic figures
saveExpImages = 0;

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

% RK (20/09/24) Is eyetracking collected? is EEG collected?
send_eeg_triggers = ~strcmp(Experiment.Env.Environment, 'home');
eyetracking = strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU');

if eyetracking % The address of the non eyetracking trigger is set in the function
    trigger_address = Experiment.Triggers.Address;
    % demo suggested sending messages to the edf file like trial number.
    % Can I also send run, set, session info like so?
    if Experiment.Mode.ETing == 1
        Eyelink('Message', 'TRIALID %d', trial);
        Eyelink('Message', 'RUNID %d', run);
        Eyelink('Message', 'SETID %d', set);
        Eyelink('Message', 'SESID %d', session);
       
        % Start EDF recording
        Eyelink('SetOfflineMode'); % this is what the demo is doing, although confusing
        Eyelink('StartRecording'); % start tracker recording
        % WaitSecs(0.1) % demo recommends letting the eye tracker collect some
        % data before first stimulus. However, this should happen during
        % initial fixation, which is long, so supposed to be ok. 
    end
end

if send_eeg_triggers
%    trigger_delay = Experiment.Triggers.TriggerDelay;
    stimulus_trigger = Experiment.Triggers.Stimulus;
    fixation_trigger = Experiment.Triggers.Fixation;
    probe_trigger = Experiment.Triggers.Probe;
    response_trigger = Experiment.Triggers.Response; 
    stimulus_trigger2 = set*100 + run*10 + mod(floor(trial/ 100), 10);
    stimulus_trigger3 = mod(trial, 100);
    multi_trigger_delay = Experiment.Triggers.MultiTriggerDelay;
end

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
            % RK 24/09/24 save probe identity
            Experiment.Log.CatchProbeIdx = image;
        else
            probe_idx = randi(length(texturePointers));
            texturePointersPrompt = texturePointers(probe_idx);
            % RK 24/09/24 save probe identity. This is very crude but
            % supposed to work. 
            Experiment.Log.CatchProbeIdx = probe_idx;
        end
    elseif catchType == 2 % NO trial - a category not in stimulus array
        arrayCat =  imageData.imageCategory(ismember(imageData.imageIndex, thisTrialStimArray')); % Categories in the array
        allOther = imageData.imageIndex(~ismember(imageData.imageCategory, arrayCat')); % Indices of images of not those categories
        prompt = allOther(randi(length(allOther)));
        texturePointersPrompt = imageData.textureIndex(imageData.imageIndex==prompt);
        % RK(19/09/24): Save probe identity
        Experiment.Log.CatchProbeIdx = prompt;
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

else % RK(19/09/24)
    Experiment.Log.CatchProbeIdx = NaN; % check if this is necassary
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
probeITI = Experiment.Time.AfterProbeGap;
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

% RK (24/09/24 Make sure eyelink is recording 
if eyetracking
    if Experiment.Mode.ETing == 1
        err = Eyelink('CheckRecording');
        if(err ~= 0)
            fprintf('EyeLink Recording stopped!\n');
            % Transfer a copy of the EDF file to Display PC
            Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
            Eyelink('CloseFile'); % Close EDF file on Host PC
            Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
            WaitSecs(0.1); % Allow some time for screen drawing
            % Transfer a copy of the EDF file to Display PC
            transferFile; % See transferFile function below)
            error('EyeLink is not in record mode when it should be. Unknown error. EDF transferred from Host PC to Display PC, please check its integrity.');
        end
        
    end
end

% Show stimulus array
Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2); % Fixation
if isSingle
    Screen('DrawTexture', myWin, texturePointers, [], destinationRects); % Stimulus
else
    Screen('DrawTextures', myWin, texturePointers, [], destinationRects); % Stimulus
end
Screen('DrawingFinished', myWin);
vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
% RK (20/09/24) send EEG trigger
if send_eeg_triggers
    if eyetracking
		%WaitSecs(trigger_delay);
		send_triggerIO64(trigger_address, stimulus_trigger);
        WaitSecs(multi_trigger_delay)% how long to wait between two triggers?
        send_triggerIO64(trigger_address, stimulus_trigger2)
        WaitSecs(multi_trigger_delay)
        send_triggerIO64(trigger_address, stimulus_trigger3)
        
        if Experiment.Mode.ETing == 1
            % RK (24/09/24) Send message to EDF file
            Eyelink('Message', 'STIM_ONSET');
        end
    else
        %WaitSecs(trigger_delay);
        send_triggerIO64(stimulus_trigger);
        WaitSecs(multi_trigger_delay)% how long to wait between two triggers?
        send_triggerIO64(stimulus_trigger2)
        WaitSecs(multi_trigger_delay)
        send_triggerIO64(stimulus_trigger3)
    end 
end

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
    % RK (20/09/24)
    if send_eeg_triggers
        if eyetracking
            %WaitSecs(trigger_delay);
            send_triggerIO64(trigger_address, fixation_trigger);
            if Experiment.Mode.ETing == 1
                % RK (24/09/24)
                Eyelink('Message', 'FIXATION');
            end
        else
            %WaitSecs(trigger_delay);
            send_triggerIO64(fixation_trigger);
        end 
    end

    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'fixation'}];
    expectedTime = expectedTime + itiGap; % Wait for a variable ITI
    
else % If it is a catch trial
    % Draw fixation and wait for first part of the delay
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2);
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    % RK (20/09/24)
    if send_eeg_triggers
        if eyetracking
            %WaitSecs(trigger_delay);
            send_triggerIO64(trigger_address, fixation_trigger);
            
            if Experiment.Mode.ETing == 1
                % RK (24/09/24)
                Eyelink('Message', 'FIXATION');
            end
        else
            %WaitSecs(trigger_delay);
            send_triggerIO64(fixation_trigger);
        end 
    end
   
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'fixation'}];
    expectedTime = expectedTime + itiCatch1; % Wait for first part of the catch gap
    
    % Show the prompt screen
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2); % Fixation
    Screen('DrawTextures', myWin, texturePointersPrompt, [], destinationRectsPrompt); % Prompt screen
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    % RK (20/09/24)
    if send_eeg_triggers
        if eyetracking
            %WaitSecs(trigger_delay);
            send_triggerIO64(trigger_address, probe_trigger);
            if Experiment.Mode.ETing == 1
                % RK (24/09/24)
                Eyelink('Message', 'PROBE');
            end
        else
            %WaitSecs(trigger_delay);
            send_triggerIO64(probe_trigger);
        end 
    end    
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'promptScreen'}];
    expectedTime = expectedTime + respTime;
    if saveExpImages
        img = Screen('GetImage', myWin);
        imwrite(img, 'promptScreen.png', 'PNG');
    end
    
    % Collect the response
    % RK 25/09/24 response is not timed but self paced. 
    Keys = Experiment.Keys;
     keysOfInterest = zeros(1,256);
     keysOfInterest([responseLeft responseRight]) = 1;
     KbQueueCreate([],keysOfInterest);
     KbQueueStart([]);
     [pressTime, key] = KbQueueWait([]); 
     KbQueueStop([]);
     KbQueueFlush([]);
    
    
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
    % RK (23/09/24)
    if send_eeg_triggers
        if eyetracking
            %WaitSecs(trigger_delay);
            send_triggerIO64(trigger_address, response_trigger);
            if Experiment.Mode.ETing == 1
                % RK (24/09/24)
                Eyelink('Message', 'RESPONSE');
            end
        else
            %WaitSecs(trigger_delay);
            send_triggerIO64(response_trigger);
        end 
    end    
    expectedTime = GetSecs() - startTime + 0.1;
    timeRealFlip = [timeRealFlip,  vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, NaN];
    whichObject = [whichObject, {'response'}];

            
    % Feedback
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
    
    
    if saveExpImages
        img = Screen('GetImage', myWin);
        imwrite(img, 'feedbackScreen.png', 'PNG');
    end
    
    % Draw fixation and wait for second part of the delay
    Screen('DrawDots', myWin, screenCenter, fixRadius,  fixColor, [], 2);
    Screen('DrawingFinished', myWin);
    vbl = Screen('Flip', myWin, startTime + expectedTime - halfifi);
    % RK (23/09/24)
    if send_eeg_triggers
        if eyetracking
            %WaitSecs(trigger_delay);
            send_triggerIO64(trigger_address, fixation_trigger);
            
            if Experiment.Mode.ETing == 1
                % RK (24/09/24)
                Eyelink('Message', 'FIXATION');
            end
        else
            %WaitSecs(trigger_delay);
            send_triggerIO64(fixation_trigger);
        end 
    end    
    timeRealFlip = [timeRealFlip, vbl - startTime];
    timeExpectedFlip = [timeExpectedFlip, expectedTime];
    whichObject = [whichObject, {'fixation'}];
    expectedTime = expectedTime + itiGap + probeITI; % Wait for first part of the catch gap
           
end

Experiment.Log.ExpectedTime = expectedTime;
Experiment.Log.StartTime = startTime;
Experiment.Log.timeRealFlip = timeRealFlip;
Experiment.Log.timeExpectedFlip = timeExpectedFlip;
Experiment.Log.whichObject = whichObject;

%%% Save the data

if Experiment.Mode.ETing == 1
    % RK (24/09/24) Stop eyetracking
    Eyelink('StopRecording'); % Stop tracker recording
end

% Save timing data 
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