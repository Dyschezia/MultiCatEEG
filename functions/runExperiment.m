function Experiment = runExperiment(Experiment)
%% TODO
% RECORD EYE MOVEMENTS DURING DRIFT CHECKS for future accuracy/precision
% calculation. 
% Can start start and end sync triggers a few times just in case 

%% Data
session = Experiment.Subject.WhichSession;
set = Experiment.Subject.WhichSet;
first_run = Experiment.Subject.WhichRun;
allRuns = Experiment.Session(session).Set(set).RunShuffled;
nRuns = length(allRuns);
totalRuns = Experiment.Task.SetsN/Experiment.Task.SessionsN*nRuns;
trialsPerBreak = Experiment.Task.TrialsPerBreak;
startGap = Experiment.Time.StartGap;
halfifi = Experiment.Env.HalfIFI;

% Mode
ETing = strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU') & Experiment.Mode.ETing;
eeg = ~strcmp(Experiment.Env.Environment, 'home');
startTrigger = Experiment.Triggers.SyncStart;
endTrigger = Experiment.Triggers.SyncEnd;
syncKeyWord = Experiment.Triggers.SyncKeyWord;

%% Loop through runs
for run = first_run:nRuns
    Experiment.Log.CurrentRun = run;
    thisRun = allRuns(run);
    trialsN = thisRun.TrialsN;
    
    % RK 25/09/24 If first run, show instructions
    if run == 1
        instructions = ['Welcome. In this experiment, single or multiple images will be presented on the screen for short durations.' ... 
            '\n Your task is to identify the objects presented. After some of the trials, you will be asked to decide (yes or no) whether' ...
            '\n an example image had appeared in the last screen you saw. You will answer these questions using the ' ...
            '\n right and left buttons.' ... 
            '\n \n It is important that you do NOT move your eyes from the center of the screen, but look at the black dot in ' ... 
            '\n the center throughout the experiment. You can move your eyes during a question if necessary, but bring them back ' ...
            '\n to the center before the next set of images is shown. Moreover, it is important that you try not to blink ' ... 
            '\n when images are shown. Try to blink only during questions, or when only the central dot (and not images) is shown. ' ...
            '\n You will be given time to rest your eyes throughout the experiment. ' ... 
            '\n \n \n If you have understood the instructions, please press ENTER to start a training session.'];
        DrawFormattedText(Experiment.Display.window, instructions, 'center', 'center');
        Screen('Flip', Experiment.Display.window);
        
        % Wait for response 
         Keys = Experiment.Keys;
         keysOfInterest = zeros(1,256);
         keysOfInterest(Keys.ControlKeys) = 1;
         KbQueueCreate([],keysOfInterest);
         KbQueueStart([]);
         press = KbQueueWait([]); 
         KbQueueStop([]);
         KbQueueFlush([]);
         
         % Run training 
         
    end
    
    run_to_display = run + nRuns*(set-1);
    text = ['Run ' num2str(run_to_display) ' out of ' num2str(totalRuns) '. Continue when ready.'];
    DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
    Screen('Flip', Experiment.Display.window);
    
    %% Setup or drift check eyelink
    %dummy_mode = 1; % should eyelink connection be initiated? if not, set 1
    if ETing
        %{
        if run == first_run
            % open EDF file, setup calibration settings, and calibrate
            Experiment = InitiateEyeTracking(Experiment);
        else
            EyelinkDoTrackerSetup(Experiment.Eyetracking.el);            
        end
        %}
        % Now splitting ET files by run 
        Experiment = InitiateEyeTracking(Experiment);
    end
    
    
    %% Setup the run
    
    % Get trigger and assign it to t0
    fprintf('\n\nPRESS ENTER TO START NEXT RUN\n\n');
     Keys = Experiment.Keys;
     keysOfInterest = zeros(1,256);
     keysOfInterest(Keys.ControlKeys) = 1;
     KbQueueCreate([],keysOfInterest);
     KbQueueStart([]);
     t0 = KbQueueWait([]); % Wait for the trigger
     KbQueueStop([]);
     KbQueueFlush([]);
        
    Experiment.Log.StartTime = t0; 
    
    % 10/10/24 Start ET recording 
    % Start EDF recording
    if ETing
        Eyelink('SetOfflineMode'); % this is what the demo is doing, although confusing
        Eyelink('StartRecording'); % start tracker recording
    end
    
    % 10/10/24 send syncing trigger to ET and EEG
    if eeg
        send_triggerIO64(startTrigger)
        if ETing
            Eyelink('Message', [syncKeyWord ' ' num2str(startTrigger)])
        end
    end

    Experiment.Log.timing(end+1,:) = table(session, set, run, 0, NaN, NaN, {'startSyncTrigger'},NaN,0);
    
    % Show initial fixation
    Screen('DrawDots', Experiment.Display.window, [Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY], Experiment.Stim.FixationPixels, Experiment.Stim.FixationColour, [], 2);
    vbl = Screen('Flip', Experiment.Display.window); 
    Experiment.Log.timing(end+1,:) = table(session, set, run, 0, NaN, NaN, {'fixation'},NaN,0);
    Experiment.Log.ExpectedTime = startGap; % Show next object after initial wait
    
    if eeg
        %WaitSecs(trigger_delay);
        send_triggerIO64(Experiment.Triggers.Fixation);
        if ETing
            % RK (24/09/24)
            Eyelink('Message', [syncKeyWord ' ' num2str(Experiment.Triggers.Fixation)])
        end 
    end
    
    % Draw graphics on the EyeLink Host PC display. See COMMANDS.INI in the Host PC's exe folder for a list of commands
    % check what this does. 
    %Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before drawing Host PC graphics and before recording        
    %Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
    
    fprintf(['\nStarting run' num2str(run) '\n']);
        
    %% Loop through trials
    
    
    output=fprintf('run %d/%d - trial: %d ', run, nRuns, 0);
    for thisTrial = 1:trialsN
        
        fprintf(repmat('\b',1,output))
        output=fprintf('run %d/%d - trial: %d ', run, nRuns, thisTrial);
                
        % Check if escape 
        [keyDown, ~, keyCode, ~] = KbCheck();
        if keyDown 
            if find(keyCode) == Experiment.Keys.EscKey
                    Experiment.Log.Exit = 1; break; 
            end
        end
        
        % Run the trial
        Experiment.Log.CurrentTrial = thisTrial;
        Experiment = runTrialSelfPaced(Experiment);

        fprintf(repmat('\b',1,output))
        output=fprintf('run %d/%d - trial: %d ', run, nRuns, thisTrial);
        
        % Save the data
        Experiment = saveLog(Experiment, 'save_log');
        
         if Experiment.Log.Exit == 1
                break;
         end
         
        % RK (23/09/24) Offer a break every trialsPerBreak trials:
        if mod(thisTrial, trialsPerBreak) == 0 && thisTrial ~= trialsN
            % At the end of the break the code runs a drift check; can't be
            % recording during a drift check. 
            if ETing 
                Eyelink('StopRecording');
            end
            Experiment = runShortBreak(Experiment); 
            if ETing % start recording again 
                Eyelink('StartRecording');
            end
        end
        
    end
    
    
    % 10/10/24 Send end sync trigger and save eye tracking data (ET data broken to files by run)
    if eeg
        send_triggerIO64(endTrigger)
        if ETing
            Eyelink('Message', [syncKeyWord ' ' num2str(endTrigger)])
            WaitSecs(0.2);
            Eyelink('StopRecording'); % Stop tracker recording
            WaitSecs(0.2);
            Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
            %Eyelink('Command', 'clear_screen 0'); % Clear Host PC backdrop graphics at the end of the experiment
            WaitSecs(0.2); % Allow some time before closing and transferring file
            Eyelink('CloseFile'); % Close EDF file on Host PC
            if ~Experiment.Eyetracking.dummymode 
                try    
                    % Transfer a copy of the EDF file to Display PC
                    status = Eyelink('ReceiveFile');
                    % Check if EDF file has been transferred successfully and print file size in Matlab's Command Window
                    if status > 0
                        fprintf('EDF file size: %.1f KB\n', status/1024); % Divide file size by 1024 to convert bytes to KB
                    end 
                catch % Catch a file-transfer error and print some text in Matlab's Command Window
                    fprintf('Problem receiving data file ''%s''\n', edfFile);
                    psychrethrow(psychlasterror);
                end    
            else
                fprintf('No EDF file saved in Dummy mode\n');    
            end
        end
        Experiment.Log.timing(end+1,:) = table(session, set, run, 0, NaN, NaN, {'endSyncTrigger'},NaN,0);
    end

    WaitSecs(0.1);
         
    % Need to break AFTER end trigger is sent and file is closed and
    % transfered 
    if Experiment.Log.Exit == 1
        break;
    end
    
end

% Save behavioral data
Experiment = saveLog(Experiment, 'add_features');
Experiment = saveLog(Experiment, 'save_log');
