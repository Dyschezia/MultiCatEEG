function Experiment = setupSessions(Experiment)
% originally hardcoded with 3 sessions. Instead, take the number of sets
% set in setupExpParam.m. 
nSes = Experiment.Task.SessionsN;
nSets = Experiment.Task.SetsN;

if mod(nSets,nSes) ~= 0
    error('The number of sets cannot be evenly split into the number of sessions.')
else
    nSetsPerSes = nSets/nSes;
    for sesidx = 1:nSes
        %{
        if sesidx==1
            Experiment.Session(sesidx).Set(1:2) = Experiment.TrialScheme.SetShuffled(1:2);

        elseif sesidx==2
            Experiment.Session(sesidx).Set(1:2) = Experiment.TrialScheme.SetShuffled(3:4);

        else
            Experiment.Session(sesidx).Set(1:2) = Experiment.TrialScheme.SetShuffled(5:6);

        end
        %}
        Experiment.Session(sesidx).Set(1:nSetsPerSes) = Experiment.TrialScheme.SetShuffled((sesidx-1)*nSetsPerSes + 1 : (sesidx-1)*nSetsPerSes + nSetsPerSes);
        
    end
end