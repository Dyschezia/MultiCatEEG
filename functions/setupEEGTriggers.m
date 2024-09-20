function Experiment = setupEEGTriggers(Experiment)
% RK (20/09/24): Function sets up and adds to the trial scheme triggers for 
% different events. Since the eyelink room amp has 16 bits, trigger number 
% can go up to +~60000.
% Currently setting trigger in 'home' mode as if mode == 'EEG_eyelink_FU'. 
% Stimuli triggers are of the form 1xxxx. Response triggers are of the form
% 2xxxx. Eyelink calibration events are of the form 3xxxx. Probe events are
% 4xxxx. 
if strcmp(Experiment.Env.Environment, 'EEG_FU')
    error('triggers are not defined for the EEG room yet (amp has only 8 bits)');
else
    
    % Setting stimulus triggers of form 1xxxx
    Sess = Experiment.Subject.WhichSession;
    Set = Experiment.Subject.WhichSet;
    nSets = length(Experiment.Session(Sess).Set);
    
    % To create the triggers, we will form triggers from the stimulus
    % arrays. The position in the trigger vector of each stimulus will
    % depend in its position in the trial scheme s.t. the stimuli in column
    % 1 will have the 1000s value, etc. 
    placeValues = [1000 100 10 1]; 
    
    for setidx = Set:nSets
        nRuns = length(Experiment.Session(Sess).Set(setidx));
        for runidx = 1:nRuns
            
            run = Experiment.Session(Sess).Set(setidx).RunShuffled(runidx);
            trial_scheme = run.TrialSchemeShuffled;
            
            % Multiplying the category value of each stimulus by a number
            % setting its location in the trigger. 
            category_triggers = trial_scheme * placeValues';
            
            % Add 10000 to know this is a stimulus trigger
            category_triggers = category_triggers + 10000;
            
            % Save trigger vector to run trial scheme 
            Experiment.Session(Sess).Set(setidx).RunShuffled(runidx).StimulusTriggers = category_triggers;
        end
    end
end 