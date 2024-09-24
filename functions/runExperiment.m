function Experiment = runExperiment(Experiment)
% RK (18/09/24) TODO: 
% 1. Add instruction screen. 
% 3. Eyelink things. 
%   a. After short break - drift check. After long break - recalibration.

%% Data
session = Experiment.Subject.WhichSession;
set = Experiment.Subject.WhichSet;
first_run = Experiment.Subject.WhichRun;
allRuns = Experiment.Session(session).Set(set).RunShuffled;
nRuns = length(allRuns);
totalRuns = Experiment.Task.SetsN/Experiment.Task.SessionsN*nRuns;
trialsPerBreak = Experiment.Task.TrialsPerBreak;
shortBreakDur = Experiment.Task.ShortBreakDur;
startGap = Experiment.Time.StartGap;
halfifi = Experiment.Env.HalfIFI;

%% RK (23/09/24) If beginnning of exp, instruction screen

%% Loop through runs
for run = first_run:nRuns
    
    % RK (18/09/24): remove hardcoding 2 sets per ses
    %{
    if set == 1
        run_to_display = run;
    else
        run_to_display = run + 4;
    end
    %}
    run_to_display = run + nRuns*(set-1);
    text = ['Run ' num2str(run_to_display) ' out of' totalRuns '. Continue when ready.'];
    DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
    Screen('Flip', Experiment.Display.window);
     
    %% Setup or drift check eyelink
    %dummy_mode = 1; % should eyelink connection be initiated? if not, set 1
    if strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU')
        if run == first_run
            % open EDF file, setup calibration settings, and calibrate
            Experiment = InitiateEyeTracking(Experiment);
        else
            EyelinkDoTrackerSetup(Experiment.Eyetracking.el);            
        end
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
    
    % Show initial fixation 
    Screen('DrawDots', Experiment.Display.window, [Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY], Experiment.Stim.FixationPixels, Experiment.Stim.FixationColour, [], 2);
    vbl = Screen('Flip', Experiment.Display.window);
    Experiment.Log.timing(end+1,:) = table(session, set, run, 0, NaN, NaN, {'initial_fixation'},NaN,0);
    Experiment.Log.ExpectedTime = startGap; % Show next object after initial wait
    
    % Draw graphics on the EyeLink Host PC display. See COMMANDS.INI in the Host PC's exe folder for a list of commands
    % check what this does. 
    %Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before drawing Host PC graphics and before recording        
    %Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
    
    fprintf(['\nStarting run' num2str(run) '\n']);
        
    %% Loop through trials
    Experiment.Log.CurrentRun = run;
    thisRun = allRuns(run);
    trialsN = thisRun.TrialsN;
    
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
        Experiment = runTrial(Experiment);

        fprintf(repmat('\b',1,output))
        output=fprintf('run %d/%d - trial: %d ', run, nRuns, thisTrial);
        
        % Save the data
        Experiment = saveLog(Experiment, 'save_log');
        
         if Experiment.Log.Exit == 1
                break;
         end
         
        % RK (23/09/24) Offer a break every trialsPerBreak trials:
        if mod(thisTrial, trialsPerBreak) == 0
            % add text on screen saying take a short break
            text = ['Take a short break of ' shortBreakDur '. Press any key to skip'];
            DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
            Screen('DrawingFinished', Experiment.Display.window);
            vbl = Screen('Flip', Experiment.Display.window, t0 + Experiment.Log.ExpectedTime - halfifi);
            
            % Update expected time of the next event
            Experiment.Log.ExpectedTime = Experiment.Log.ExpectedTime + shortBreakDur;
            Experiment.Log.timing(end+1,:) = table(session, set, run, NaN, NaN, NaN, {'short_break'},NaN, vbl);
            
            % Check if a key is pressed until the end of the break
            keyDown = 0;
            while GetSecs() < t0 + Experiment.Log.ExpectedTime
                [keyDown, ~ , ~ , ~ ] = KbCheck();
                if keyDown
                    Experiment.Log.ExpectedTime = GetSecs() - t0 + 0.1;
                    break
                end
            end
            
            % Run a drift check 
            EyelinkDoDriftCorrection(Experiment.Eyetracking.el, Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY);
            Experiment.Log.ExpectedTime = GetSecs() - t0 + 0.1;
            
            % Add a longer fixation to make sure subjects is fixating
            Screen('DrawDots', Experiment.Display.window, [Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY], Experiment.Stim.FixationPixels, Experiment.Stim.FixationColour, [], 2);
            Screen('DrawingFinished', Experiment.Display.window);
            vbl = Screen('Flip', Experiment.Display.window, t0 + Experiment.Log.ExpectedTime - halfifi);
            Experiment.Log.timing(end+1,:) = table(session, set, run, NaN, NaN, NaN, {'long_fixation'},NaN,vbl);
            Experiment.Log.ExpectedTime = Experiment.Log.ExpectedTime + startGap;
             
        end
        
    end
            
    if Experiment.Log.Exit == 1
        break;
    end
    
    % RK(19/09/24) remove waiting till scanner defined duration
    %{
    else
        last_event = thisRun.TimingLog.TimingExpected.timing(end-1);
        wait_time = Experiment.Time.RunDuration - last_event;
        WaitSecs(wait_time); % Wait until the end of the run (scanner defined)
    end
    %}
    
    
end

% Save the data
Experiment = saveLog(Experiment, 'add_features');
Experiment = saveLog(Experiment, 'save_log');
