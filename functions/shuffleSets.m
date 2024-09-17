function Experiment = shuffleSets(Experiment)
% Shuffle the order of runs within each Set 

nSets = length(Experiment.TrialScheme.Set);

shuffled = Experiment.TrialScheme.Set(randperm(nSets));
Experiment.TrialScheme.SetShuffled = shuffled;
