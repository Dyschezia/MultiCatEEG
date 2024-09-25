function Experiment = runExperiment(Experiment)
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
    
    %% Setup or drift check eyelink
    %dummy_mode = 1; % should eyelink connection be initiated? if not, set 1
    if strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU') && Experiment.Mode.ETing == 1
        if run == first_run
            % open EDF file, setup calibration settings, and calibrate
            Experiment = InitiateEyeTracking(Experiment);
        else
            EyelinkDoTrackerSetup(Experiment.Eyetracking.el);            
        end
    end
    
    % RK 25/09/24 If first run, show instructions
    if run == 1
        instructions = ['Welcome. In this experiment you will view arrays made of one or four objects, which will appear for short durations.' ... 
            '\n Please try to identify the objects presented, as on some trials you will be asked to decide whether a shown image had appeared in the preceding array.' ... 
            '\n Importantly, please continue to fixate on the fixation point at the middle of the screen throughout the experiment.' ...
            '\n Try to blink only when you are asked about an object, or when only a fixation is shown.' ... 
            '\n \n \n If you have understood the instructions, please press ENTER'];
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
    end
    
    run_to_display = run + nRuns*(set-1);
    text = ['Run ' num2str(run_to_display) ' out of ' num2str(totalRuns) '. Continue when ready.'];
    DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
    Screen('Flip', Experiment.Display.window);
     
    
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
            % add text on screen saying take a short break
            text = ['Take a short break of ' num2str(shortBreakDur) ' seconds. Press any key to skip'];
            DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
            Screen('DrawingFinished', Experiment.Display.window);
            vbl = Screen('Flip', Experiment.Display.window, t0 + Experiment.Log.ExpectedTime - halfifi);
            
            % Update expected time of the next event
            Experiment.Log.ExpectedTime = Experiment.Log.ExpectedTime + shortBreakDur;
            Experiment.Log.timing(end+1,:) = table(session, set, run, NaN, NaN, NaN, {'short_break'},NaN, vbl);
            
            % Check if a key is pressed until the end of the break
            keyDown = 0;
            while GetSecs() < t0 + Experiment.Log.ExpectedTime - 0.1
                [keyDown, ~ , ~ , ~ ] = KbCheck();
                if keyDown
                    Experiment.Log.ExpectedTime = GetSecs() - t0 + 0.1;
                    break
                else
                    text = ['Take a short break of ' num2str(floor(t0 + Experiment.Log.ExpectedTime - GetSecs())) ' seconds. Press any key to skip'];
                    DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
                    Screen('DrawingFinished', Experiment.Display.window);
                    vbl = Screen('Flip', Experiment.Display.window);
                    WaitSecs(0.2);
                end
            end
            
            % Run a drift check 
            if strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU') && Experiment.Mode.ETing == 1
                EyelinkDoDriftCorrection(Experiment.Eyetracking.el, Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY);
                Experiment.Log.ExpectedTime = GetSecs() - t0 + 0.1;
            end
            
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

% RK (24/09/24) Save eyetracking data
if strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU') && Experiment.Mode.ETing == 1
    Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
    %Eyelink('Command', 'clear_screen 0'); % Clear Host PC backdrop graphics at the end of the experiment
    WaitSecs(0.5); % Allow some time before closing and transferring file
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


% Save behavioral data
Experiment = saveLog(Experiment, 'add_features');
Experiment = saveLog(Experiment, 'save_log');
