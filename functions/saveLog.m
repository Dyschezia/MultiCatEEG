function Experiment = saveLog(Experiment, usecase)

switch usecase
    
    case 'timing_data'
        timingData = Experiment.Log.timing;
        
        trial_length = length(Experiment.Log.timeRealFlip);
    
        whichTrial = repelem(Experiment.Log.CurrentTrial, trial_length);
        whichRun = repelem(Experiment.Log.CurrentRun, trial_length);
        whichSet = repelem(Experiment.Subject.WhichSet, trial_length);
        whichSession = repelem(Experiment.Subject.WhichSession, trial_length);
        is1array = repelem(Experiment.Log.IsSingle, trial_length);
        isCatch = repelem(Experiment.Log.IsCatch, trial_length);
        
        timingDataTrial = table(whichSession', whichSet', whichRun', whichTrial', is1array', isCatch', ...
            Experiment.Log.whichObject', Experiment.Log.timeExpectedFlip', Experiment.Log.timeRealFlip');
         timingDataTrial.Properties.VariableNames = timingData.Properties.VariableNames;
         Experiment.Log.timing = [timingData; timingDataTrial];
         
    case 'log_data'
        
        logData = Experiment.Log.log;
        session = Experiment.Subject.WhichSession;
        set = Experiment.Subject.WhichSet;
        run = Experiment.Log.CurrentRun;
        trial = Experiment.Log.CurrentTrial;
        
        idx = find(logData.Session==session & logData.Set==set & logData.Run==run & logData.Trial==trial);
        location_response = logData.LocationResponse(idx);
        response = Experiment.Log.response;
        probe = Experiment.Log.CatchProbeIdx; % RK(19/09/24)
        
        logData.ResponseKey(idx) = Experiment.Log.key;
        logData.ResponseSide(idx) = response; % RK(19/09/24) (small change, was accessing Log)
        logData.CatchProbeIdx(idx) = probe; % RK(19/09/24)
        
        if location_response==1 % Yes is on the left
            if strcmp(response, "left")
                responseYN = "yes";
            elseif strcmp(response, "right")
                responseYN = "no";
            else
                responseYN = "missed";
            end
        elseif location_response==2 % Yes is on the right
            if strcmp(response, "left")
                responseYN = "no";
            elseif strcmp(response, "right")
                responseYN = "yes";
            else
                responseYN = "missed";
            end
        end
        logData.ResponseYN(idx) = responseYN;
        logData.ResponseAccuracy(idx) = Experiment.Log.iscorrect; % Was the response correct
        
        Experiment.Log.log = logData;
        
    case 'localizer_log'
        log = Experiment.Log.LocalizerLog;
        locData = Experiment.Images.Localizer;
        trial_length = length(Experiment.Log.timeRealFlip);
        whichTrial = repelem(Experiment.Log.CurrentTrial, trial_length);
        whichBlock = repelem(Experiment.Log.CurrentBlock, trial_length);
        whichSession = repelem(Experiment.Subject.WhichSession, trial_length);
        is1array = repelem(Experiment.Log.IsSingle, trial_length);
        isCatch = repelem(Experiment.Log.IsCatch, trial_length);
        category = locData.CategoryName(locData.Block==Experiment.Log.CurrentBlock);
        category = repelem(category(1), trial_length);
        
        logTrial = table(whichSession', whichBlock', whichTrial', category', is1array', isCatch', ...
            Experiment.Log.whichObject', Experiment.Log.timeExpectedFlip', Experiment.Log.timeRealFlip');
        logTrial.Properties.VariableNames = log.Properties.VariableNames;
        Experiment.Log.LocalizerLog = [log; logTrial];
         
    case 'save_log'
            
        % Write log files
        log = Experiment.Log.log;
        timing = Experiment.Log.timing;
        save([Experiment.Paths.Output,'_ALL', '.mat'], 'Experiment');
        writetable(log,[Experiment.Paths.Output,'_LOG.csv']);
        writetable(timing,[Experiment.Paths.Output,'_TIMING.csv']);
        
    case 'save_loc_log'
        
        % Write localizer log
        loclog = Experiment.Log.LocalizerLog;
        writetable(loclog,[Experiment.Paths.Output,'_LOCALIZER.csv']);
        
    case 'add_features'
        % TIMING DATA
        Experiment.Log.timing.EventDuration = [diff(Experiment.Log.timing.ExpectedFlip); NaN]; % Calculate real duration of each event
        Experiment.Log.timing.EventDurationReal = [diff(Experiment.Log.timing.RealFlip); NaN]; % Calculate real duration of each event
        Experiment.Log.timing.FlipDifference = Experiment.Log.timing.ExpectedFlip - Experiment.Log.timing.RealFlip; % Real flip - delayed/early?
           
    case 'setup_log'
        % Create out file
        handle =  ['Sub_', num2str(Experiment.Subject.ID), ...
                   '_Session_', num2str(Experiment.Subject.WhichSession), ...
                   '_Set_', num2str(Experiment.Subject.WhichSet)];
        dt = datetime();
        dt.Format = 'dd-MMM-uuuu_HH-mm-ss';
        timestamp = char(dt);
        out = fullfile(Experiment.Subject.SubPath, [handle, '_', timestamp]);
        Experiment.Paths.Output = out;

        % Turn off warning
        id = 'MATLAB:table:RowsAddedExistingVars';
        warning('off',id)
        
        % Log table
        varTypes = ["cell","cell","cell"];
        varNames = ["Subject","Age","Sex"];
        sz = [1, length(varNames)];
        log = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
        
        % Variables
        session = Experiment.Subject.WhichSession;
        set = Experiment.Subject.WhichSet;
        first_run = Experiment.Subject.WhichRun;
        nRuns = length(Experiment.Session(session).Set(set).RunShuffled);
        subjectID = Experiment.Subject.ID;
        subjectAge = Experiment.Subject.Age;
        subjectSex = Experiment.Subject.Sex;
        
        idx = 1;
        for run = first_run:nRuns
            % RK (18/09/24): switched a few places where the run scheme was
            % called to the use of runTrials... just make sure it doesn't
            % fuck anything. 
            nTrials = Experiment.Session(session).Set(set).RunShuffled(run).TrialsN;
            runTrials = Experiment.Session(session).Set(set).RunShuffled(run);
            for trial = 1:nTrials
                
                % General information
                log.Subject(idx)  = {subjectID};
                log.Age(idx)  = {subjectAge};
                log.Sex(idx)  = {subjectSex};
                
                % Experiment information
                log.Session(idx) = session;
                log.Set(idx) = set;
                log.Run(idx) = run;
                log.Trial(idx) = trial;
                
                % Stimulus
                array = runTrials.StimArrays(trial,:);
                log.SingleTrial(idx) = runTrials.Is1Array(trial);
                if log.SingleTrial(idx)
                    log.Position(idx) = find(array ~= 0); % If it's 1-array, save location
                else
                    log.Position(idx) = 0; % If it's not 1-array, save '0' as location (all 4 items are present)
                end
                log.StimExemplar(idx) = {array};
                category = [];
                for item = 1:length(array)
                    itemidx = char(string(array(item)));
                    catidx = str2double(itemidx(1));
                    category = [category, catidx(1)];
                end
                log.StimCategory(idx) = {category};
                
                % Probe parameters
                log.CatchTrial(idx) = runTrials.CatchTrials(trial);
                log.CorrectResponse(idx) = runTrials.CatchType(trial);
                log.LocationResponse(idx) = runTrials.CatchResponse(trial);
                % RK (18/09/24): Probe is sampled later; set place to save
                % it. 
                log.CatchProbeIdx(idx) = NaN;
                
                % Given response
                log.ResponseKey(idx) = NaN;
                log.ResponseSide(idx) = " ";
                log.ResponseYN(idx) = " ";
                log.ResponseAccuracy(idx) = NaN;
                
                idx = idx+1;
            end
        end
        
        % Timing data log
        varNames = ["Session","Set","Run", "Trial", "SingleElement", "CatchTrial", "Event", "ExpectedFlip", ...
            "RealFlip"];        
        varTypes = ["double","double","double", "double", "double", "double", "string", "double",...
            "double"];
        sz = [1, length(varTypes)];
        
        timing = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
        
        % Save the log structures
        Experiment.Log.log = log;
        Experiment.Log.timing = timing;
        
end