function Experiment = optimizeRunBalance(Experiment)
 
nshuffles = 100;
nreps = 1000;

% First create the starting point runs matrix.
runs = zeros(70,4,24);
for ci = 1:length(Experiment.DM.samplesCombination)

    c = Experiment.DM.samplesCombination(ci, :);
    thiscperms = perms(c);
    [r,c] = size(thiscperms);
    nlay = Experiment.Task.SessionsN*Experiment.Task.RunsN; % Number of layers (=runs)

    % Shuffle the order of permutations
    shuffledperms = thiscperms(randperm(size(thiscperms,1)),:);

    % Reshape 24 permutations in 3D
    thiscperms3d = permute(reshape(shuffledperms',[c,r/nlay,nlay]),[2,1,3]);

    % Add the shuffled vector to all runs
    runs(ci, :, :) = thiscperms3d;

    % Count categories per location
    counts_orig = countCategoryLocation(runs, Experiment);
end

% disp("")
% disp("Starting point counts:")
% disp("")
% disp(counts_orig)

% Optimal distirbution for comparison
optimal = counts_orig;
optimal(:,:,:) = mean(mean(mean(counts_orig)));

%% Then optimize it
% 'runs' keeps changing on every go
% 'bestrun' only changes at the end of each rep if it's better than last

for rep = 1:nreps

    disp("Repetition N: ")
    disp(rep)

    if rep == 1
        thisrun = runs;
    else
        thisrun = bestrun;
    end

    for ci = 1:size(runs,1) % Loop through all combinations
    
        thiscperms = thisrun(ci,:,:);
    
        for s = 1:nshuffles % Shiffle permutations between runs
    
            % Shuffle the order of permutations across the third dimension
            shuffidx = randperm(size(thiscperms,3));
            shuffledperms = thiscperms(1,:,shuffidx);
    
            % Add the shuffled vector to all runs
            thisrun(ci, :, :) = shuffledperms;

            % Count categories per location
            counts = countCategoryLocation(thisrun, Experiment);
    
            % Evaluate whether the fit is better
    
            % Calculate the average difference between these counts and the
            % optimal distribution
            difference = mean(mean(mean(abs(optimal - counts))));
      
            if s ==1
                previous = mean(mean(mean(abs(optimal - counts_orig))));
            end
            
            % Compare this difference to the one on previous shuffle
            if difference < previous
                previous = difference; 
            end
        end
    end

    % Once the whole run is with optimal distribution of permutations,
    % compare to previously optimal run
    
    counts = countCategoryLocation(thisrun, Experiment);
    global_difference = mean(mean(mean(abs(optimal - counts))));

    if rep ==1
        global_previous = mean(mean(mean(abs(optimal - counts_orig))));
    end

    if global_difference < global_previous
        global_previous = global_difference;
        bestrun = thisrun;
    end
end

Experiment.DM.BestRun = bestrun;
Experiment.DM.BestCounts = counts;
