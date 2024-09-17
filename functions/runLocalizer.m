function Experiment = runLocalizer(Experiment)

% Find the localizer table
locData = Experiment.Images.Localizer;
nBlocks = length(unique(locData.Block));

% Extract variables
session = Experiment.Subject.WhichSession;

% Set up the log
varNames = ["Session","Block","Trial", "Category", "SingleElement", "CatchTrial", "Event", "ExpectedFlip", ...
    "RealFlip"];
varTypes = ["double","double","double", "string", "double", "double", "string", "double",...
    "double"];
sz = [1, length(varTypes)];
Experiment.Log.LocalizerLog = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

%% Start the scanner
text = ['Last bit (~10min): localizer run. \n Task: Press with index finger when you spot an element rotated upside-down.'];
DrawFormattedText(Experiment.Display.window, text, 'center', 'center');
Screen('Flip', Experiment.Display.window);

% Get trigger and assign it to t0
% t0 = time of first MRI trigger (first TR)
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
Experiment.Log.LocalizerLog(1,:) = table(session, 0, 0, " ", NaN, NaN, {'mri_start'},0,0);

Screen('DrawDots', Experiment.Display.window, [Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY], Experiment.Stim.FixationPixels, Experiment.Stim.FixationColour, [], 2);
vbl = Screen('Flip', Experiment.Display.window);
Experiment.Log.LocalizerLog(1,:) = table(session, 0, 0, " ", NaN, NaN, {'initial_fixation'},0,0);
Experiment.Log.ExpectedTime = Experiment.Time.StartGap; % Show next object after initial wait

fprintf(['\nStarting localizer run\n']);

output=fprintf('\n Block %d: %s - trial: %d \n', 0, " ", 0);

%% Loop through the blocks
for block = 1:nBlocks
    Experiment.Log.CurrentBlock = block;
    thisBlock = locData(locData.Block==block, :);
    Experiment.Log.BlockData = thisBlock;
    trialsN = height(thisBlock);
    
    % Listen for keypresses
    keysOfInterest = zeros(1,256);
    keysOfInterest(Experiment.Keys.LeftResponse) = 1;
    keysOfInterest(Experiment.Keys.RightResponse) = 1;
    keysOfInterest(Experiment.Keys.EscKey) = 1;
    KbQueueCreate([],keysOfInterest);
    KbQueueStart([]);
        
    for thisTrial = 1:trialsN
        
        fprintf(repmat('\b',1,output))
        output=fprintf('\nBlock %d: %s - trial: %d \n', block, thisBlock.CategoryName{1}, thisTrial);
               
        % Run the trial
        Experiment.Log.CurrentTrial = thisTrial;
        Experiment = runLocalizerTrial(Experiment);
        
        fprintf(repmat('\b',1,output))
        output=fprintf('\nBlock %d: %s - trial: %d \n', block, thisBlock.CategoryName{1}, thisTrial);
        
        [pressed, ~, ~, lastPress, ~] = KbQueueCheck([]);
        if pressed
            key_idx = find(lastPress);
            if key_idx == Experiment.Keys.EscKey
                Experiment.Log.Exit = 1;
                break;
            else
                key_time = lastPress(lastPress~=0);
                log = Experiment.Log.LocalizerLog;
                trial = table(session, block, thisTrial, {thisBlock.CategoryName{1}}, thisBlock.IsSingle(thisTrial), thisBlock.CatchTrial(thisTrial), "button_press", NaN, key_time);
                trial.Properties.VariableNames = log.Properties.VariableNames;
                Experiment.Log.LocalizerLog = [log; trial];
            end
        end
                
        if Experiment.Log.Exit == 1
            break;
        end
        
    end
    
    % Save the data
    Experiment = saveLog(Experiment, 'save_loc_log');
    
    KbEventFlush();
    KbQueueRelease();
    
    if Experiment.Log.Exit == 1
            break;
    end
    
    WaitSecs(Experiment.Time.LocalizerStopGap);
    Experiment.Log.ExpectedTime = Experiment.Log.ExpectedTime + Experiment.Time.LocalizerStopGap;
    
end


