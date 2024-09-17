function Experiment = shuffleTrials(Experiment)
% Within each run, shuffle the order of trials, and (!) shuffle the order
% of the catch variables, ITIs, Is1Array/Is4Array variables as well.

nSessions =  Experiment.Task.SessionsN;
nSets = 2;
nRuns = Experiment.Task.RunsN;

for sess = 1:nSessions
    for set = 1:nSets
        for run = 1:nRuns
            % all variables that need to shuffle
            stimuli = Experiment.Session(sess).Set(set).RunShuffled(run).StimArrays;
            catch_trials = Experiment.Session(sess).Set(set).RunShuffled(run).CatchTrials;
            catch_type = Experiment.Session(sess).Set(set).RunShuffled(run).CatchType;
            catch_response = Experiment.Session(sess).Set(set).RunShuffled(run).CatchResponse;
            is1array = Experiment.Session(sess).Set(set).RunShuffled(run).Is1Array;
            is4array = Experiment.Session(sess).Set(set).RunShuffled(run).Is4Array;
            iti = Experiment.Session(sess).Set(set).RunShuffled(run).ITIs;
            
            % get the shuffled index
            nTrials = length(stimuli); 
            shuffled_idx = randperm(nTrials);
            
            % Assign the shuffled rows (same shuffled index for all
            % variables
            Experiment.Session(sess).Set(set).RunShuffled(run).StimArrays = stimuli(shuffled_idx, :);
            Experiment.Session(sess).Set(set).RunShuffled(run).CatchTrials = catch_trials(shuffled_idx);
            Experiment.Session(sess).Set(set).RunShuffled(run).CatchType = catch_type(shuffled_idx);
            Experiment.Session(sess).Set(set).RunShuffled(run).CatchResponse = catch_response(shuffled_idx);
            Experiment.Session(sess).Set(set).RunShuffled(run).Is1Array = is1array(shuffled_idx);
            Experiment.Session(sess).Set(set).RunShuffled(run).Is4Array = is4array(shuffled_idx);
            Experiment.Session(sess).Set(set).RunShuffled(run).ITIs =  iti(shuffled_idx);
        end
    end
end
