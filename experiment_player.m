%% MultiCAT - object information in multi-object arrays
% Experiment player script
% Written by: Karla Matic, kmatic94@gmail.com
% Adaptation to EEG and eyetracking: Rotem Krispil, rotem.krispil@mail.huji.ac.il
% First written: November 2023
% Last update: October 2024
% This script loads the 'Experiment' structure for a given subject,
% plays the experiment, and logs the data.

%%
% RK (18/09/24) TODO: 

% Add collect tracked eye
% - in experiment player (setup subject)
% - in setup log 

% 7. Make sure calculations in visualAngleCalculation.m and
% visangle2stimsize.m are correct (run some precalculated values). 
% 13. Maybe show performance measure 

% - training
% - reward for performance! but maybe after the initial 3 subjects?
% - translate instructions

%% ----------------------------------------------------------------------
%                           Initial setup
%--------------------------------------------------------------------------------------
commandwindow
close all; clearvars; sca;

% Setup
screennum = max(Screen('Screens')); % Change if needed
environment = 'home'; % EEG_eyelink_FU, EEG_FU (define), home
ETing = 0;
Photodiode = 1;

% Add directory with functions to Matlab path
addpath(genpath('functions')); 
\addpath(genpath('functions\eeg trigger functions')); 

% Main path
TmpExperiment = struct();

% What do we run?
TmpExperiment.Mode.mode = 'experiment'; % 'test' or 'experiment'

% For reliable  timing, this should be 0. But on multi-display setup, this
% may not work. 1 shortens the tests for timing, 2 disables all
% calibration.
%{
if strcmp(TmpExperiment.Mode.mode, 'test')
    Screen('Preference', 'SkipSyncTests', 1); 
else
    Screen('Preference', 'SkipSyncTests', 0);
end
%}

% Set main directory
TmpExperiment.Paths.MainPath = pwd();

% Path to subject data/pregen file
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

% Add paths 
Experiment.Paths.MainPath = TmpExperiment.Paths.MainPath;
Experiment.Paths.OutDir = TmpExperiment.Paths.OutDir;
Experiment.Paths.ImageDir = fullfile(Experiment.Paths.MainPath, 'stimulusSet'); 
Experiment.Subject.SubPath = TmpExperiment.Subject.SubPath;

% Add mode
Experiment.Mode.mode = TmpExperiment.Mode.mode;
Experiment.Mode.ETing = ETing; %RK 24/09/24
Experiment.Mode.Photodiode = Photodiode; %RK 04/10/24

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

%% Define photodiode square if used (RK 04/10/24)
if Photodiode
    Experiment = setupPhotodiode(Experiment);
end

%% The log files for each set are stored separately
Experiment.Log.Exit = 0;
n_sets = Experiment.Task.SetsN/Experiment.Task.SessionsN; %RK (19/09/24) was hardcoded
first_set = Experiment.Subject.WhichSet; % RK(19/09/24) set can now be set in setupSubject.m
for i_set = first_set:n_sets
    %Experiment.Subject.WhichSet = i_set;
    Experiment.Log.CurrentSet = i_set;
    
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

%% Close window
% RK (24/09/24)
if strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU') && Experiment.Mode.ETing == 1
    Eyelink('Shutdown'); % Close EyeLink connection
    ListenChar(0); % Restore keyboard output to Matlab
    ShowCursor; % Restore mouse cursor
end
sca;
