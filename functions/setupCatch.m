function Experiment = setupCatch(Experiment) 

        % Catch trials are counterbalanced per set. 
        % There are 10 catch trials per run, and 40 catch trials per set. 
        % In one set, 12 catch trials are following 1-arrays, and 28 catch
        % trials are following 4-arrays. 
        % Out of those, in half trials (6 1-arrays and 14 4-arrays) the correct response is YES, 
        % and out of those, in half YES appears on the left side of the
        % screen (3 1-arrays and 7 4-arrays). We set all this up here.
        
        nSessions = Experiment.Task.SessionsN;
        nRuns = Experiment.Task.RunsN;
    
        for sess = 1:nSessions
            
            for set = 1: length(Experiment.Session(sess).Set)
                
                [r1, r2, r3, r4] = Experiment.Session(sess).Set(set).RunShuffled.TrialSchemeShuffled;   
                set_scheme = [r1; r2; r3; r4];
                
                is1array = any(set_scheme==0, 2);
                is4array = ~is1array;
                
                set_length = length(set_scheme);
                run_length = length(r1);
                
                catch_trials = zeros(set_length, 1);
                catch_type = zeros(set_length, 1);
                catch_response = zeros(set_length, 1);
                        
                %% First select some catch trials out of 1-arrays
                N_catch_1array = 12; % Hard coded here, change if needed
                all1idx = find(is1array);
                catch_idx_1 = [];
                for run = 1:nRuns % Here we make sure we take the same number of catch trials per run
                    run_begin = (run-1)*run_length + 1;
                    run_end = run_length*run;
                    idx = ismember(all1idx, run_begin:run_end);
                    run_idx = all1idx(idx); % Get all indices of 1-arrays that belong to this run
                    sample = run_idx(1:3:end); % Sample every 3rd 1-array trial         
                    shuffled = sample(randperm(length(sample))); % Shuffle the sub-sampled array
                    catch_idx_1 = [catch_idx_1; shuffled(1:(N_catch_1array/nRuns))]; % take how many we need
                end
                 catch_trials(catch_idx_1) = 1;
               
                % Asisgn half of them as YES trials, and half as NO
                half = N_catch_1array/2;
                catch_idx_1_shuffle = catch_idx_1(randperm(length(catch_idx_1)));
                catch_idx_yes = catch_idx_1_shuffle(1:half);
                catch_idx_no = catch_idx_1_shuffle(half+1:N_catch_1array);
                catch_type(catch_idx_yes) = 1; %YES
                catch_type(catch_idx_no) = 2; % NO
                
                % Then assign half response locations as yes-no, and half af no-yes
                half = length(catch_idx_yes)/2;
                catch_idx_yes_left = catch_idx_yes(1:half);
                catch_idx_yes_right = catch_idx_yes(half+1:length(catch_idx_yes));
                catch_idx_no_left = catch_idx_no(1:half);
                catch_idx_no_right = catch_idx_no(half+1:length(catch_idx_no));
                catch_response(catch_idx_yes_left) = 1; %LEFT
                catch_response(catch_idx_no_left) = 1; % LEFT
                catch_response(catch_idx_yes_right) = 2; % RIGHT
                catch_response(catch_idx_no_right) = 2; % RIGHT
                
                  %% Then do the same for 4-arrays
                  N_catch_4array = 28; % Hard coded here, change if needed
                  all4idx = find(is4array);
                  catch_idx_4 = [];
                  for run = 1:nRuns % Here we make sure we take the same number of catch trials per run
                      run_begin = (run-1)*run_length + 1;
                      run_end = run_length*run;
                      idx = ismember(all4idx, run_begin:run_end);
                      run_idx = all4idx(idx); % Get all indices of 1-arrays that belong to this run
                      sample = run_idx(1:3:end); % Sample every 3rd 4-array trial
                      shuffled = sample(randperm(length(sample))); % Shuffle the sub-sampled array
                      catch_idx_4 = [catch_idx_4; shuffled(1:(N_catch_4array/nRuns))]; % take how many we need
                  end
                  catch_trials(catch_idx_4) = 1;
                  
                % Asisgn half of them as YES trials, and half as NO
                half = N_catch_4array/2;
                catch_idx_4_shuffle = catch_idx_4(randperm(length(catch_idx_4)));
                catch_idx_yes = catch_idx_4_shuffle(1:half);
                catch_idx_no = catch_idx_4_shuffle(half+1:N_catch_4array);
                catch_type(catch_idx_yes) = 1; % YES
                catch_type(catch_idx_no) = 2; % NO
                
                % Then assign half response locations as yes-no, nad half af no-yes
                half = length(catch_idx_yes)/2;
                catch_idx_yes_left = catch_idx_yes(1:half);
                catch_idx_yes_right = catch_idx_yes(half+1:length(catch_idx_yes));
                catch_idx_no_left = catch_idx_no(1:half);
                catch_idx_no_right = catch_idx_no(half+1:length(catch_idx_no));
                catch_response(catch_idx_yes_left) = 1; % LEFT
                catch_response(catch_idx_no_left) = 1; % LEFT
                catch_response(catch_idx_yes_right) = 2; % RIGHT
                catch_response(catch_idx_no_right) = 2; % RIGHT
                
                %% Then save these variables
                Experiment.TrialScheme.SetShuffled(set).CatchTrials = catch_trials;
                Experiment.TrialScheme.SetShuffled(set).CatchType = catch_type;
                Experiment.TrialScheme.SetShuffled(set).CatchResponse = catch_response;
                
                %% Then split and assign to runs
                catch_trials_reshaped = reshape(catch_trials, [set_length/nRuns, nRuns]);
                catch_type_reshaped = reshape(catch_type, [set_length/nRuns, nRuns]);
                catch_response_reshaped = reshape(catch_response, [set_length/nRuns, nRuns]);
                
                for run = 1:nRuns
                    Experiment.Session(sess).Set(set).RunShuffled(run).CatchTrials = catch_trials_reshaped(:,run);
                    Experiment.Session(sess).Set(set).RunShuffled(run).CatchType = catch_type_reshaped(:,run);
                    Experiment.Session(sess).Set(set).RunShuffled(run).CatchResponse = catch_response_reshaped(:,run);
                end
                
            end
        end