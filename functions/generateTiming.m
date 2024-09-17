function Experiment = generateTiming(Experiment)
% pre-calcualte ideal timing for each run 

nSess = length(Experiment.Session);
for sesidx = 1:nSess

    for setidx = 1:length(Experiment.Session(sesidx).Set)
    
        nRuns = length(Experiment.Session(sesidx).Set(setidx).RunShuffled);
        for runidx = 1:nRuns

        trial_length = Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).TrialsN;

        events = {'stimulus', ...
                  'iti', ...
                  'catch_probe', ...
                  'catch_feedback', ...
                  'catch_iti1', ...
                  'catch_iti2',...
                  'wait_start', ...
                  'wait_stop'};

        stimulus = Experiment.Time.StimExpTime;
        catch_probe = Experiment.Time.RespWait;
        catch_feedback = Experiment.Time.FeedbackGap;
        catch_iti1 = Experiment.Time.CatchIti1;
        %catch_iti2 = Experiment.Time.CatchIti2;  
        wait_start = Experiment.Time.StartGap;
        wait_stop = Experiment.Time.StopGap;

        trials = [1];
        timing = [0];
        events = {};
        trialtiming = 0;       
        for trial = 1:trial_length

            thisiti = Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).ITIs(trial);
            trialcounter = 0; % Count how many events per trial
                
            if trial == 1
                events{end+1} = 'begin_run';
                trialtiming = trialtiming+wait_start;
            end

            % Procedure for catch trials
            if Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).CatchTrials(trial) == 1
                
                % Stimulus
                trialcounter = trialcounter+1;
                timing = [timing; trialtiming];
                events{end+1} = 'stimulus';
                trialtiming = trialtiming+stimulus;

                % First part of the ITI (gap until task)
                trialcounter = trialcounter+1;
                timing = [timing; trialtiming];
                events{end+1} = 'catch_iti1';
                trialtiming = trialtiming+catch_iti1;

                % Probe                
                trialcounter = trialcounter+1;
                timing = [timing; trialtiming];
                events{end+1} = 'catch_probe';
                trialtiming = trialtiming+catch_probe;

                % Feedback                
                trialcounter = trialcounter+1;
                timing = [timing; trialtiming];
                events{end+1} = 'catch_feedback';
                trialtiming = trialtiming+catch_feedback;

                % Second part of the ITI                
                trialcounter = trialcounter+1;
                timing = [timing; trialtiming];
                events{end+1} = 'iti';
                trialtiming = trialtiming+thisiti;

            else
                % Procedure for passive trials

                % Stimulus
                trialcounter = trialcounter+1;
                timing = [timing; trialtiming];
                events{end+1} = 'stimulus';
                trialtiming = trialtiming+stimulus;

                % ITI
                % Second part of the ITI                
                trialcounter = trialcounter+1;
                timing = [timing; trialtiming];
                events{end+1} = 'iti';
                trialtiming = trialtiming+thisiti;
            end

            if trial == trial_length % If it's the last trial                
                timing = [timing; trialtiming];
                events{end+1} = 'wait_end';
                trialcounter = trialcounter+1;
                trialtiming = trialtiming+wait_stop;
            end
            
            trials = [trials; repelem(trial, trialcounter, 1)];

        end

        timingExpected = table(trials, ...
                               timing, ...
                               events', ...
                               'VariableNames', {'trial', 'timing', 'event'});

        Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).TimingLog.TimingExpected = timingExpected;
        end
    end
end


