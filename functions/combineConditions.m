function Experiment = combineConditions(Experiment)
% Rotem: change from original version: originally this combines the 32 different
% ways to present single objects with the 70 trials of the 4 arrays for each run.
% However, in the EEG exp we would like to add more single array trials and
% thus for the function to use the preset (and changed) value of single
% arrays per run. To make the number of trials where each category appears
% equal we want to have 280 single array trials in each run. Since this is
% not a multiple of 32 we need to do some sampling and make sure sets are still comparable. 

nSets = length(Experiment.TrialScheme.Set);
for setidx = 1:nSets
    nRuns = length(Experiment.TrialScheme.Set(setidx).Run);
    nTrials1array = Experiment.Task.Trials1arrayN;
   
    % how many unique 1 arrays
    nUnique1arrays = size(Experiment.DM.samplesPermutation_1item, 1);
    
    % Number of times all unique single arrays appear in the set
    nSingleRepeats = nTrials1array * nRuns / nUnique1arrays;
    
    % Create a pool of the total single arrays in the set
    set1arrays = repmat(Experiment.DM.samplesPermutation_1item, nSingleRepeats, 1);
    
    % Shuffle order
    set1arrays = set1arrays(randperm(nTrials1array * nRuns),:);
    
    for runidx = 1:nRuns
        % Only 4-arrays
        thisrun1 = Experiment.TrialScheme.Set(setidx).Run(runidx).TrialScheme4array;
        
        % Only 1-arrays
        %thisrun2 = Experiment.DM.samplesPermutation_1item;
        thisrun2 = set1arrays((runidx-1) * nTrials1array + 1 : runidx * nTrials1array, :);

        % Combine 1-arrays and 4-arrays
        thisrun = [thisrun1; thisrun2];

        % Shuffle the order of rows
        shuffled = thisrun(randperm(size(thisrun, 1)), :);
        
        Experiment.TrialScheme.Set(setidx).Run(runidx).TrialSchemeShuffled = shuffled;

    end
end
