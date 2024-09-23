%% MultiCAT - object information in multi-object arrays
% Experiment player script
% Written by: Karla Matic, kmatic94@gmail.com
% Edits to adapt to EEG: Rotem Krispil, rotem.krispil@mail.huji.ac.il
% First written: November 2023
% Last update: September 2024
% This script loads the 'Experiment' structure for a given subject,
% plays the experiment, and logs the data.

%%
% RK (18/09/24) TODO: 
% 4. Check EEG triggers sending works correctly!
% 5. Eye tracking, saving. 
%   a. Remember to make background color the same as the exp!
% 6. In setupEnvironment.m, need to measure sizes and distances in the exp
% room (measured for eyelink room. Measure other room). 
% 7. Make sure calculations in visualAngleCalculation.m and
% visangle2stimsize.m are correct (run some precalculated values). 
% 8. Run createResponses.m once with the create section uncommented to
% create the Y/N images.
% 10. Add blinking period. 
% 11. Handle crashes (make sure eyelink data is saved as well)
% 12. Handle first trial (through training or in the exp).

% Don't forget to set sync to 0 and mode to exp before running!!!

%% ----------------------------------------------------------------------
%                           Initial setup
%--------------------------------------------------------------------------------------
commandwindow
close all; clearvars; sca;

% SCREEN
screennum = max(Screen('Screens')); % Change if needed
environment = 'home'; % EEG_eyelink_FU, EEG_FU (define), home
%run_duration = 420; % RK(19/09/24) commented. Duration of one run (scanner defined)

% Add directory with functions to Matlab path
addpath(genpath('functions')); 

% Main path
TmpExperiment = struct();

% What do we run?
TmpExperiment.Mode.mode = 'test'; % 'test' or 'experiment'

% For reliable  timing, this should be 0. But on multi-display setup, this
% may not work. 1 shortens the tests for timing, 2 disables all
% calibration.
if strcmp(TmpExperiment.Mode.mode, 'test')
    Screen('Preference', 'SkipSyncTests', 1); 
else
    Screen('Preference', 'SkipSyncTests', 0);
end

% Set main directory
TmpExperiment.Paths.MainPath = pwd();

% Path to subject data/pregen file
%{ 
if strcmp(environment, 'home')
    idcs = strfind(TmpExperiment.Paths.MainPath ,'/');
else
    idcs = strfind(TmpExperiment.Paths.MainPath ,'\'); % if it's run on Windows
end
%} 
%RK 19/09/24
idcs = strfind(TmpExperiment.Paths.MainPath ,'\'); 
parent_dir = TmpExperiment.Paths.MainPath (1:idcs(end)-1);
TmpExperiment.Paths.OutDir = fullfile(parent_dir, 'data');

% Get subject ID 
TmpExperiment = subjectInfo(TmpExperiment);

%% ------------------------------------------------------------------------------------
%                         Load pregenerated Experiment struct
%--------------------------------------------------------------------------------------

Experiment = loadExperimentStruct(TmpExperiment);

% Screen
Experiment.Env.WhichScreen = screennum; % Assign the display on which experiment should be played

% Run duration
%Experiment.Time.RunDuration = run_duration; %RK(19/09/24)

% Add paths 
Experiment.Paths.MainPath = TmpExperiment.Paths.MainPath;
Experiment.Paths.OutDir = TmpExperiment.Paths.OutDir;
Experiment.Paths.ImageDir = fullfile(Experiment.Paths.MainPath, 'stimulusSet'); 
Experiment.Subject.SubPath = TmpExperiment.Subject.SubPath;

% Add mode
Experiment.Mode.mode = TmpExperiment.Mode.mode;

%% --------------------------------------------------------------------
%                       Subject setup
%----------------------------------------------------------------------

Experiment = setupSubject(Experiment);

%% --------------------------------------------------------------------
%                       Display setup
%----------------------------------------------------------------------

% Environment
Experiment.Env.Environment = environment; 

if strcmp(Experiment.Mode.mode, 'test')
    PsychDebugWindowConfiguration(); % Transparent screen for debugging
end

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

if strcmp(Experiment.Mode.mode, 'experiment')
    HideCursor % hide mouse cursor
end
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

%% The log files for two sets are stored separately
Experiment.Log.Exit = 0;
n_sets = Experiment.Task.SetsN/Experiment.Task.SessionsN; %RK (19/09/24) was hardcoded
first_set = Experiment.Subject.WhichSet; % RK(19/09/24) set can now be set in setupSubject.m
for i_set = first_set:n_sets
    Experiment.Subject.WhichSet = i_set;
    
    if Experiment.Log.Exit == 1
        break;
    end
    
    %% Setup log
    Experiment = saveLog(Experiment, 'setup_log');

    %% --------------------------------------------------------------------
    %                       Run experiment
    %------------------------------------------------------------------------
    Experiment = runExperiment(Experiment);
end

%% ----------------------------------------------------------
%                       Run localizer
%------------------------------------------------------------------
% if ~Experiment.Log.Exit
%     
%      fprintf('\n\nPRESS ENTER TO CONTINUE NEXT RUN\n\n');
%      Keys = Experiment.Keys;
%      keysOfInterest = zeros(1,256);
%      keysOfInterest(Keys.ControlKeys) = 1;
%      KbQueueCreate([],keysOfInterest);
%      KbQueueStart([]);
%      t0 = KbQueueWait([]); % Wait for the trigger
%      KbQueueStop([]);
%      KbQueueFlush([]);
%     
%     % Create localizer blocks
%     Experiment = createLocalizer(Experiment);
%     
%     % Load localizer images as textures
%     Experiment.Mode.imagemode = 'localizer';
%     Experiment = loadImagesAsTextures(Experiment);   
%     
%     % Run localizer blocks
%     Experiment = runLocalizer(Experiment); 
%     
% end

%% Close window
sca;
