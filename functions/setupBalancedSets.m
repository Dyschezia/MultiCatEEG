function Experiment = setupBalancedSets(Experiment)

% We separately pre-generated a trial scheme file, in which combinations or
% categories are balanced. Trial scheme consists of 6 sets which are
% perfectly balanced, each of which has 7 runs. This script loads this file
% and creates a TrialScheme struct.

% The pregenerated trial_scheme file is a 1680x6 array. Columns 1:4 are
% category IDs, column 5 is Set ID, columnd 6 is Run ID.
trial_scheme = readtable(fullfile(Experiment.Paths.pregenOutputs, "trial_scheme.csv"));

% Number of sets 
nSets = Experiment.Task.SetsN; % Total number sets
if nSets ~= length(unique(trial_scheme.session))
    warning("Number of sets in trial scheme .csv file does not correspond to manually set experimental parameters. Please check.")
end

% Number of runs per set
nRuns = Experiment.Task.RunsN; % Number of runs per set
if nRuns ~= length(unique(trial_scheme.block))
    warning("Number of runs in trial scheme .csv file does not correspond to manually set experimental parameters. Please check.")
end

for setidx = 1:nSets
    for runidx = 1:nRuns
        idx1 = trial_scheme.session==setidx; % Select Set
        idx2 = trial_scheme.block==runidx; % Select Run
        idx = idx1&idx2;

        thisrun = table2array(trial_scheme(idx, 1:4));
        Experiment.TrialScheme.Set(setidx).Run(runidx).TrialScheme4array = thisrun;
    end
end
