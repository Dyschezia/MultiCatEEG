%% Training run
%% ----------------------------------------------------------------------
%                           Initial setup
%--------------------------------------------------------------------------------------
commandwindow
close all; clearvars; sca;
PsychDebugWindowConfiguration(0.5); % Transparent screen for debugging
% SCREEN
screennum = max(Screen('Screens')); % Change if needed
environment = 'home'; % fMRI_FU, home
run_duration = 420; % Duration of one run (scanner defined)

% For reliable  timing, this should be 0. But on multi-display setup, this
% may not work. 1 shortens the tests for timing, 2 disables all
% calibration.
Screen('Preference', 'SkipSyncTests', 0); 

% Add directory with functions to Matlab path
addpath(genpath('functions')); 

% Main path
TmpExperiment = struct();

% What do we run?
TmpExperiment.Mode.mode = 'experiment'; % 'test' or 'experiment'

% Set main directory
TmpExperiment.Paths.MainPath = pwd();

% > Rotem edit 20.05.2024 remove mac option < 
% Path to subject data/pregen file 
idcs = strfind(TmpExperiment.Paths.MainPath ,'\'); % if it's run on Windows
parent_dir = TmpExperiment.Paths.MainPath (1:idcs(end)-1);
TmpExperiment.Paths.OutDir = fullfile(parent_dir, 'data');

% Get subject ID 
TmpExperiment.Subject.ID = '100';
subPath = fullfile(TmpExperiment.Paths.OutDir,'SUB_100');
TmpExperiment.Subject.SubPath = subPath;

%% ------------------------------------------------------------------------------------
%                         Load pregenerated Experiment struct
%--------------------------------------------------------------------------------------

Experiment = loadExperimentStruct(TmpExperiment);

% Screen
Experiment.Env.WhichScreen = screennum; % Assign the display on which experiment should be played

% Run duration
Experiment.Time.RunDuration = run_duration;

% Add paths 
Experiment.Paths.MainPath = TmpExperiment.Paths.MainPath;
Experiment.Paths.OutDir = TmpExperiment.Paths.OutDir;
Experiment.Paths.ImageDir = fullfile(Experiment.Paths.MainPath, 'stimulusSet'); 
Experiment.Subject.SubPath = TmpExperiment.Subject.SubPath;

% Add mode
Experiment.Mode.mode = TmpExperiment.Mode.mode;
Experiment.Subject.WhichSession = 1;

%% Adapt sizes for training
Experiment.Stim.Width = 2.5;
Experiment.Stim.Height = 2.5;
Experiment.Stim.DistanceX = 2.5;
Experiment.Stim.DistanceY = 2.5;

%% --------------------------------------------------------------------
%                       Display setup
%-----------------------------------------------------------------------------------

% Environment
Experiment.Env.Environment = environment; 

%PsychDebugWindowConfiguration(); % Transparent screen for debugging

% Open PTB screen
fprintf('\nOpening Psychtoolbox\n')
background = [255, 255, 255]/2; % Bacgkround color in RGB 
%background = [0.5, 0.5, 0.5]; % Bacgkround color in RGB 
%Experiment.Stim.BackgroundColor = background;
[window, rect] = Screen('OpenWindow', screennum); %background
Experiment.Display.window = window;
Experiment.Display.rect = rect;
fprintf('\nDone\n')

% Activate for alpha blending
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% fill screen with background color
Screen('FillRect', window, background);

HideCursor % hide mouse cursor
Priority(MaxPriority(window));

% Activate for alpha blending
% Screen('BlendFunction', exp.on_screen, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Set up and measure display parameters
Experiment = setupEnvironment(Experiment);

% Convert visual angle to pixels and cm.
Experiment = visualAngleCalculation(Experiment);

%% Load the images to vRAM
Experiment.Mode.imagemode = 'experiment';
Experiment = loadImagesAsTextures(Experiment);

%% Create responses
Experiment = createResponses(Experiment);

%% Define locations for images in the array
Experiment = setupLocations(Experiment);

Experiment.Log.Exit = 0;
instructions_rect = rect*0.7;
instructions_size = CenterRectOnPoint(instructions_rect, Experiment.Env.ScreenCenterX, Experiment.Env.ScreenCenterY);

%% --------------------------------------------------------------------
%                   Instructions
%------------------------------------------------------------------------
instructions_part1 = fullfile(Experiment.Paths.MainPath, 'training', 'part1'); 
instr_files = dir(fullfile(instructions_part1, '*.png'));

% Show first screen
[thisImage, ~, ~] = imread(fullfile(instructions_part1, instr_files(1).name));
imageTex = Screen('MakeTexture', window, thisImage);
Screen('DrawTexture', window, imageTex, [], instructions_size); % Draw instruction display
Screen('Flip', window)

ct = 1;
endct = length(instr_files) + 1;

while ct < endct
    % Check what key was pressed
    keysOfInterest = zeros(1,256);
    keysOfInterest(Experiment.Keys.RightResponse) = 1;
    keysOfInterest(Experiment.Keys.LeftResponse) = 1;
    keysOfInterest(Experiment.Keys.EscKey) = 1;
    KbQueueCreate([],keysOfInterest);
    KbQueueStart([]);
    KbQueueWait([]); % Wait for the trigger
    [keyDown, secs, keys] = KbCheck;
    KbQueueStop([]);
    KbQueueFlush([]);
        
    if find(keys) == Experiment.Keys.RightResponse
        ct = ct + 1;
        if ct == endct
            break
        end
        [thisImage, ~, ~] = imread(fullfile(instructions_part1, instr_files(ct).name));
        imageTex = Screen('MakeTexture', window, thisImage);
        Screen('DrawTexture', window, imageTex, [], instructions_size); % Draw instruction display
        Screen('Flip', window)
        
    elseif find(keys) == Experiment.Keys.LeftResponse
        ct = ct - 1;
        disp(ct)
        if ct < 1
            ct = 1;
        end
        [thisImage, ~, ~] = imread(fullfile(instructions_part1, instr_files(ct).name));
        imageTex = Screen('MakeTexture', window, thisImage);
        Screen('DrawTexture', window, imageTex, [], instructions_size); % Draw instruction display
        Screen('Flip', window)
        
    elseif find(keys) == Experiment.Keys.EscKey
        Experiment.Log.Exit = 1;
        break
    end
end


%% --------------------------------------------------------------------
%                       Run experiment
%------------------------------------------------------------------------

if ~Experiment.Log.Exit
    Experiment = runTraining(Experiment);
end
WaitSecs(1);

%% --------------------------------------------------------------------
%                   Instructions
%------------------------------------------------------------------------
instructions_part2 = fullfile(Experiment.Paths.MainPath, 'training', 'part2'); 
instr_files = dir(fullfile(instructions_part2, '*.png'));

% Show first screen
[thisImage, ~, ~] = imread(fullfile(instructions_part2, instr_files(1).name));
imageTex = Screen('MakeTexture', window, thisImage);
Screen('DrawTexture', window, imageTex, [], instructions_size); % Draw instruction display
Screen('Flip', window)

ct = 1;
endct = length(instr_files) +1;

while ct < endct
    % Check what key was pressed
    keysOfInterest = zeros(1,256);
    keysOfInterest(Experiment.Keys.RightResponse) = 1;
    keysOfInterest(Experiment.Keys.LeftResponse) = 1;
    keysOfInterest(Experiment.Keys.EscKey) = 1;
    KbQueueCreate([],keysOfInterest);
    KbQueueStart([]);
    KbQueueWait([]); % Wait for the trigger
    [keyDown, secs, keys] = KbCheck;
    KbQueueStop([]);
    KbQueueFlush([]);
        
    if find(keys) == Experiment.Keys.RightResponse
        ct = ct + 1;
        if ct >= endct-1
            ct = endct-1;
        end
        [thisImage, ~, ~] = imread(fullfile(instructions_part2, instr_files(ct).name));
        imageTex = Screen('MakeTexture', window, thisImage);
        Screen('DrawTexture', window, imageTex, [], instructions_size); % Draw instruction display
        Screen('Flip', window)
        
    elseif find(keys) == Experiment.Keys.LeftResponse
        ct = ct - 1;
        if ct < 1
            ct = 1;
        end
        [thisImage, ~, ~] = imread(fullfile(instructions_part2, instr_files(ct).name));
        imageTex = Screen('MakeTexture', window, thisImage);
        Screen('DrawTexture', window, imageTex, [], instructions_size); % Draw instruction display
        Screen('Flip', window)
        
    elseif find(keys) == Experiment.Keys.EscKey
        Experiment.Log.Exit = 1;
        break
    end
end



%% Close window
sca;
