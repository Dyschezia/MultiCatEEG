function Experiment = setupExpParam(Experiment)
% TODO: 
% set nSubs
% catch N and P are not exact but I am not sure they are used. 


% Define a structure containing all experimental parameters.

%% 'Task' - choice of specific task and general parameters

% Subjects
Experiment.Task.nSubs = 30; % Planned number of subjects (including pilots)

% Trials and blocks
Experiment.Task.SessionsN = 2; % Total number of sessions
Experiment.Task.SetsN = 6; % Total number of balanced sets
Experiment.Task.RunsN = 4; % Total number of runs within a set
Experiment.Task.Trials4arrayN = 70; % Number of 4-array trials per run
Experiment.Task.Trials1arrayN = 280; % Number of 1-array trials per run
Experiment.Task.TrialsTotalN4array = Experiment.Task.Trials4arrayN * Experiment.Task.RunsN * Experiment.Task.SetsN;
Experiment.Task.TrialsTotalN1array = Experiment.Task.Trials1arrayN * Experiment.Task.RunsN * Experiment.Task.SetsN;
Experiment.Task.TrialsTotalN = Experiment.Task.TrialsTotalN4array + Experiment.Task.TrialsTotalN1array; % Number of all trials (all sizes, sessions, etc)
% RK (23/09/24) After how many trials should subjects be offered break?
Experiment.Task.TrialsPerBreak = 50;
Experiment.Task.ShortBreakDur = 10; % in seconds
 
% Fonts and environment setup
Experiment.Task.FontsizeInstruction = 1; % Font size for instruction texts
Experiment.Task.FontsizeProbe = 1; % Font size for report probe

%% 'Stim' - everything related to the stimulus array

% Stimulus set
Experiment.Stim.CategoriesN = 8; % How many categories
Experiment.Stim.ExemplarsPerCatN = 2; % How many exemplars per category
Experiment.Stim.OrientationsPerCatN = 2; % How many orientations for each exemplar
Experiment.Stim.UniqueItemsPerCarN = Experiment.Stim.ExemplarsPerCatN * Experiment.Stim.OrientationsPerCatN; 

% Stimulus array
Experiment.Stim.ArraySizes = [1, 4]; % Number of items in stimulus array
Experiment.Stim.LocationsN = 4; % How many different locations

% Size stimulus
Experiment.Stim.DistanceX = 3.5; % Distance of centre of image from fixation on x-axis
Experiment.Stim.DistanceY = 3.5; % Distance of centre of image from fixation on y-axis
Experiment.Stim.Height = 4; % Stimulus image height
Experiment.Stim.Width = 4; % Stimulus image width

% Fixation
Experiment.Stim.FixationColour = [0, 0, 0];
Experiment.Stim.FixRadius = 0.25; % Radius of fixation dot

% Background color
Experiment.Stim.BackgroundColor = [0.5 0.5 0.5];

%% 'Resp' - everything related to obtaining responses

% Proportion of trials where task appeart
% RK (18/09/24): set the number of catch trials per run in single and multi
% arrays (as this is what the function setupCatch.m needs; comment the old
% parameters to find if and when they're used? 

%Experiment.Resp.CatchP = 0.1; % Proportion of catch trials (i.e., response trials)
%Experiment.Resp.CatchN = round(Experiment.Resp.CatchP * Experiment.Task.TrialsTotalN);
%Experiment.Resp.CatchNperRun = round(Experiment.Resp.CatchN / (Experiment.Task.RunsN * Experiment.Task.SetsN));

Experiment.Resp.CatchNperRun1array = 28;
Experiment.Resp.CatchNperRun4array = 7; 
Experiment.Resp.CatchNperRun = Experiment.Resp.CatchNperRun4array + Experiment.Resp.CatchNperRun1array;

% Feedback
Experiment.Resp.Feedback = 1; % Showing feedback after response

% Response probe
Experiment.Resp.ProbeWidth = Experiment.Stim.Width; % Size of response probe in deg of visual field
Experiment.Resp.ProbeHeight = Experiment.Stim.Height; % Size of response probe in deg of visual field
Experiment.Resp.ProbeLocation = [0, 0]; % Offset from centre of visual field
Experiment.Resp.RespWidth = 2; % Size of the answers (yes/no) in deg of visual field
Experiment.Resp.RespHeight = 2; % Size of the answers (yes/no) in deg of visual field
Experiment.Resp.RespLocation = [2, 4]; % Offset from centre of visual field

% Localizer
Experiment.Task.LocalizerCatchN = 5; % Total N of catch trials durung one loc run

%% 'Time' - everything related to durations

% Stimulus
Experiment.Time.StimExpTime = 0.250;  % Stimulus array exposure time [s]

% Response
Experiment.Time.RespWait = 2.0; % How long to allow for the response
Experiment.Time.FeedbackGap = 0.25; % Gap after feedback
Experiment.Time.CatchIti1 = 0.7;
%Experiment.Time.CatchIti2 = 1.0;

% ITI
Experiment.Time.ItiMean = 0.8; % Mean ITI in seconds
Experiment.Time.ItiRange = [0.7, 0.9]; % Range in which ITI varies
Experiment.Time.ItiIncrement = 0.05; % Increment of ITI values
Experiment.Time.StartGap = 2.0; % Wait before the start of the first trial of the run
Experiment.Time.StopGap = 2.0; % Wait after thelast trial of the run
Experiment.Time.AfterProbeGap = 0.6; % Have an x seconds longer fixation after probe trial? 


%% RK (20/09/24) EEG Triggers 
% Indexing events will be done with 1 to
% 3 triggers. The first trigger sets the type of event, the two other ones
% will be used to code the identity of the trial. 
% To code stimuli, will use 3 triggers

% Set triggers defining event type
Experiment.Triggers.Stimulus = 1;
Experiment.Triggers.Fixation = 2;
Experiment.Triggers.Probe = 3;
Experiment.Triggers.Response = 4; 
Experiment.Triggers.Calibration = 5;