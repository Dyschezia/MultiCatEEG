function Experiment = setupSessions(Experiment)
for sesidx = 1:3

    if sesidx==1
        Experiment.Session(sesidx).Set(1:2) = Experiment.TrialScheme.SetShuffled(1:2);

    elseif sesidx==2
        Experiment.Session(sesidx).Set(1:2) = Experiment.TrialScheme.SetShuffled(3:4);

    else
        Experiment.Session(sesidx).Set(1:2) = Experiment.TrialScheme.SetShuffled(5:6);
        
    end
end