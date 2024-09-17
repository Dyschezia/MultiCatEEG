function Experiment = shuffleRuns(Experiment)
% Shuffle the order of runs within each Set 

nSets = length(Experiment.TrialScheme.Set);
for setidx = 1:nSets
    
    nRuns = length(Experiment.TrialScheme.Set(setidx).Run);
    thisset = Experiment.TrialScheme.Set(setidx).Run;
    
    % Shuffle the order of runs within the set
    shuffled = thisset(randperm(nRuns));
        
    Experiment.TrialScheme.Set(setidx).RunShuffled = shuffled;

end
