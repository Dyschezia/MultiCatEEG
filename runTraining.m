function Experiment = runTraining(Experiment)

%% Data
session = 1;
set = 1;
allRuns = Experiment.Session(session).Set(set).RunShuffled;
nRuns = length(allRuns);  

%% Loop through runs
for run = 1
    
    text = ['Welcome to the training run. This will take 2-3 minutes.\n\n' ...
                'During the training run, please keep your INDEX finger on the LEFT ARROW,'...
                'and MIDDLE finger on the RIGHT ARROW. \n You will give your response by pressing those buttons.'...
                '\n\n\nWhen you are ready, begin the training by pressing RIGHT ARROW.'];
    DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
    Screen('Flip', Experiment.Display.window);
     
    %% Setup the run
        
    % Wait for RIGHT arrow to be pressed
     keysOfInterest = zeros(1,256);
     keysOfInterest(115) = 1;
     KbQueueCreate([],keysOfInterest);
     KbQueueStart([]);
     t0 = KbQueueWait([]); % Wait for the trigger
     KbQueueStop([]);
     KbQueueFlush([]);
        
    Experiment.Log.StartTime = t0;
    
    Screen('DrawDots', Experiment.Display.window, [Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY], Experiment.Stim.FixationPixels, Experiment.Stim.FixationColour, [], 2);
    vbl = Screen('Flip', Experiment.Display.window);
    Experiment.Log.ExpectedTime = Experiment.Time.StartGap; % Show next object after initial wait
    
    fprintf(['\nStarting run' num2str(run) '\n']);
        
    %% Loop through trials
    Experiment.Log.CurrentRun = run;
    thisRun = allRuns(run);
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(3) = 1;
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(5) = 1;
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(6) = 1;
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(10) = 1;
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(12) = 1;
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(15) = 1;
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(18) = 1;
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(19) = 1;
    Experiment.Session(1).Set(1).RunShuffled(1).CatchTrials(25) = 1;
    
    output=fprintf('run %d/%d - trial: %d ', run, nRuns, 0);
    for thisTrial = 1:25
        
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
        Experiment = runTrainingTrial(Experiment);

        fprintf(repmat('\b',1,output))
        output=fprintf('run %d/%d - trial: %d ', run, nRuns, thisTrial);
        
         if Experiment.Log.Exit == 1
                break;
         end
         
    end
            
    if Experiment.Log.Exit == 1
        break;
    end
    
end
