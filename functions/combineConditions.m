function Experiment = combineConditions(Experiment)

nSets = length(Experiment.TrialScheme.Set);
for setidx = 1:nSets
    
    nRuns = length(Experiment.TrialScheme.Set(setidx).Run);
    for runidx = 1:nRuns
        % Only 4-arrays
        thisrun1 = Experiment.TrialScheme.Set(setidx).Run(runidx).TrialScheme4array;
        % Only 1-arrays
        thisrun2 = Experiment.DM.samplesPermutation_1item;
        % Combine 1-arrays and 4-arrays
        thisrun = [thisrun1; thisrun2];

        % Shuffle the order of rows
        shuffled = thisrun(randperm(size(thisrun, 1)), :);
        
        Experiment.TrialScheme.Set(setidx).Run(runidx).TrialSchemeShuffled = shuffled;

    end
end
