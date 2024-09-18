%% MultiCAT - object information in multi-object arrays
% Experiment generation script
% Written by: Karla Matic, kmatic94@gmail.com
% Adapted to EEG use: Rotem Krispil
% First written: September 2023
% Last update: September 2024
% This script creates the design matrix, run structure, and stimuli. 
% The generated trials can be played using "experiment_player.m" script.

%% ------------------------------------------------------------
%                               Initial setup
% -------------------------------------------------------------------------
commandwindow
close all; clearvars;

%%% Data structures
Experiment = struct();

%%% Context 
Experiment.Mode.mode = 'test'; % test, experiment

%%% Paths
% Set main directory
Experiment.Paths.MainPath = pwd();

% Path to subject data/pregen file
idcs = strfind(Experiment.Paths.MainPath ,'\');
parent_dir = Experiment.Paths.MainPath (1:idcs(end)-1);
Experiment.Paths.OutDir = fullfile(parent_dir, 'data');

% Path to save pregenerated outputs 
Experiment.Paths.pregenOutputs = fullfile(Experiment.Paths.MainPath, 'design'); 

% Add directory with functions to Matlab path
addpath(genpath('functions')); 

%%-------------------------------------------------------------------------
%                           Get subject data
%---------------------------------------------------------------------------
Experiment = subjectInfo(Experiment);
Experiment = createDirFile(Experiment);
%%-------------------------------------------------------------------------
%                            Experiment parameters
%----------------------------------------------------------------------------
% Set up the parameters for the experiment: Stim, Task, Time, Env.

Experiment = setupExpParam(Experiment);

%%-------------------------------------------------------------------------
%                               Design matrix
%----------------------------------------------------------------------------
% Create a matrix of all possible conditions: category permutations (i.e, 
% combinations of categories where order/location does matter; category
% combinations (i.e., where order does not matter), and single-item
% array combinations. Given 8 categories shown in 4 locations, there is a 
% total of 1680 unique permutations, 70 unique combinations, and 32 unique
% single-item arrays.
%
% Output: Experiment.DM

Experiment = createDesignMatrix(Experiment); 
%run("createDesignMatrix.m")

%%-------------------------------------------------------------------------
%                 Load the sets and runs from .py output
%--------------------------------------------------------------------------
% Load externally generated trial scheme, where conditions are balanced
% across 6 sets with 4 runs in each set. 
%
% Output: Experiment.TrialScheme.Set(1:6).Runs(1:4).TrialScheme4Array

Experiment = setupBalancedSets(Experiment);

%%=========================================================================
%                           RANDOMIZATION
%==========================================================================
%%--------------------------------------------------------------------------
%                    Shuffle within and across sets
%-------------------------------------------------------------------------

if strcmp(Experiment.Subject.ID, 'test')
    rng(4019); % Seed: sub ID
else
    rng(4019+str2double(Experiment.Subject.ID)); % Seed: sub ID
end

% Shuffle the order of trials (within run), runs (within set) and sets
% Combine 1-array and 4-array trials
Experiment = combineConditions(Experiment); % Combine conditions and mix them together
Experiment = shuffleRuns(Experiment); % Shuffle the order of runs in each set
Experiment = shuffleSets(Experiment); % Shuffle the order of sets

% Assign the shuffled sets to sessions
% RK: this was hardcoded as 3 sets, thus changed. 
Experiment = setupSessions(Experiment);

%%-------------------------------------------------------------
%                       Set up catch trials
%---------------------------------------------------------------
Experiment = setupCatch(Experiment);

%%-------------------------------------------------------------------------
%                    Generate trials from trial scheme
%--------------------------------------------------------------------------
% Using the loaded trial scheme (Experiment.Sessions), generate the 
% individual trials: load exemplar IDs, add catch trials, add ITI jitter. 
%  
Experiment = generateTrials(Experiment);
Experiment = shuffleTrials(Experiment); % After adding catch trials, shuffle the order again

%%-------------------------------------------------------------------------
%                       Pregenerate timing
%--------------------------------------------------------------------------
Experiment = generateTiming(Experiment);

% 
% %% --------------------------------------------------------------------
% %                      Save the file
% %----------------------------------------------------------------------
filename = [Experiment.Subject.ExperimentStructPath, '.mat'];
save(filename, 'Experiment');
fprintf('\nExp file saved: \n');
disp(filename)
