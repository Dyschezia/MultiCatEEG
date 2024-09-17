function Experiment = runExperiment(Experiment)

%% Data
session = Experiment.Subject.WhichSession;
set = Experiment.Subject.WhichSet;
allRuns = Experiment.Session(session).Set(set).RunShuffled;
nRuns = length(allRuns);  

%% Loop through runs
for run = 1:nRuns
    
    if set == 1
        run_to_display = run;
    else
        run_to_display = run + 4;
    end
    text = ['Run ' num2str(run_to_display) ' out of 8. Continue when ready.'];
    DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
    Screen('Flip', Experiment.Display.window);
     
    %% Setup the run
        
    % Get trigger and assign it to t0
    % t0 = time of first MRI trigger (first TR)
    fprintf('\n\nPRESS ENTER TO CONTINUE NEXT RUN\n\n');
     Keys = Experiment.Keys;
     keysOfInterest = zeros(1,256);
     keysOfInterest(Keys.ControlKeys) = 1;
     KbQueueCreate([],keysOfInterest);
     KbQueueStart([]);
     t0 = KbQueueWait([]); % Wait for the trigger
     KbQueueStop([]);
     KbQueueFlush([]);
    
    fprintf('\n\nSTART SCANNER\n\n');
    Keys = Experiment.Keys;
    keysOfInterest = zeros(1,256);
    keysOfInterest(Keys.MRItrigger) = 1;
    KbQueueCreate([],keysOfInterest);
    KbQueueStart([]);
    t0 = KbQueueWait([]); % Wait for the trigger
    KbQueueStop([]);
    KbQueueFlush([]);
    
    Experiment.Log.StartTime = t0;
    Experiment.Log.timing(end+1,:) = table(session, set, run, 0, NaN, NaN, {'mri_start'},NaN,0);
    
    Screen('DrawDots', Experiment.Display.window, [Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY], Experiment.Stim.FixationPixels, Experiment.Stim.FixationColour, [], 2);
    vbl = Screen('Flip', Experiment.Display.window);
    Experiment.Log.timing(end+1,:) = table(session, set, run, 0, NaN, NaN, {'initial_fixation'},NaN,0);
    Experiment.Log.ExpectedTime = Experiment.Time.StartGap; % Show next object after initial wait
    
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
         
    end
            
    if Experiment.Log.Exit == 1
        break;
    else
        last_event = thisRun.TimingLog.TimingExpected.timing(end-1);
        wait_time = Experiment.Time.RunDuration - last_event;
        WaitSecs(wait_time); % Wait until the end of the run (scanner defined)
    end
    
end

% Save the data
Experiment = saveLog(Experiment, 'add_features');
Experiment = saveLog(Experiment, 'save_log');
