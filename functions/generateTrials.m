function Experiment = generateTrials(Experiment)

nSess = length(Experiment.Session); % Loop through sessions
for sesidx = 1:nSess

    nSets = length(Experiment.Session(sesidx).Set); % Loop through sets in the session
    for setidx = 1:nSets
      
        nRuns = length(Experiment.Session(sesidx).Set(setidx).Run);
        for runidx = 1:nRuns

            trial_scheme = Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).TrialSchemeShuffled;
            trial_length = length(trial_scheme);
            
            %% If it's a catch trial, duplicate the trial
            catch_copies = [];
            for trial = 1:trial_length
                if Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).CatchTrials(trial) == 1
                    catch_copies = [catch_copies; trial_scheme(trial, :)];
                end
            end
            
            trial_scheme = [trial_scheme; catch_copies]; % The 10 catch trials are duplicated in the trial scheme and added to the end
            trial_length = length(trial_scheme);
            % Also save these trials in the Catch vector
            Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).CatchTrials(end+1:end+(length(catch_copies))) = repelem(0,length(catch_copies),1); 
            Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).CatchType(end+1:end+(length(catch_copies))) = repelem(0,length(catch_copies),1); 
            Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).CatchResponse(end+1:end+(length(catch_copies))) = repelem(0,length(catch_copies),1); 
            
            
            %% All exemplar/orientation combinations
            allexemp = 1:Experiment.Stim.ExemplarsPerCatN;
            allorient = 1:Experiment.Stim.OrientationsPerCatN;
            [n,m]=ndgrid(allexemp,allorient);
            itemcomb = string([m(:),n(:)]);
            itemcomb = strcat(itemcomb(:,1), itemcomb(:,2));

            %% Select a random item for each cell in trial_scheme
            stim_arrays = zeros(size(trial_scheme,1), size(trial_scheme,2));
            for row = 1:size(trial_scheme,1)
                for col = 1:size(trial_scheme,2)
                    itemc = trial_scheme(row,col); % Item category
                    itemeo = itemcomb(randi(length(itemcomb))); % Select a random item
                    item = strcat(string(itemc), itemeo); % Combine with item category

                    if itemc == 0 % If the given item is empty (1-array)
                        stim_arrays(row,col) = 0;                       
                    else
                        stim_arrays(row,col) = str2double(item); % Save item
                    end
                end
            end

            %% Add a vector indicating if it's a 1-array trial
            is1array = any(trial_scheme==0, 2);
            is4array = ~is1array;

            % Add a vector indicating location of the 1-array
            trial_scheme(any(trial_scheme==0, 2), :);

            %% ITIs
            % RK (18/09/24): This distribution is almost uniform but makes ITIs in the
            % middle a tiny bit more likely. I'm not sure if it makes any
            % sense over uniform because of how small the difference is. 
            mu = (Experiment.Time.ItiRange(1)+Experiment.Time.ItiRange(2))/2; % Mean of the normal distribution of ITIs
            sigma = Experiment.Time.ItiMean; % SD of the normal distribution. Was 2. 
            nd = makedist('Normal', 'mu', mu, 'sigma', sigma); % Create a proability distrinution
            ndt = truncate(nd, Experiment.Time.ItiRange(1), Experiment.Time.ItiRange(2)); % Truncate so it's never under/over specified
            itis = round(random(ndt, trial_length, 1), 1); % ITIs for each trial in a run, sampled from nf, rounded to 100ms

            %% Add to the main struct
            Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).StimArrays = stim_arrays;
            Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).Is1Array = is1array;
            Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).Is4Array = is4array;
            Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).ITIs = itis;
            Experiment.Session(sesidx).Set(setidx).RunShuffled(runidx).TrialsN = trial_length;

        end
    end
end



        
    