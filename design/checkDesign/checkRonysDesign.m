clear
clc
% Check location/category per session

trial_scheme = readtable("pregeneratedOutputs/RonyOptimization/trial_scheme.csv");

for s = 1:length(unique(trial_scheme.session))
    thisrun = table2array(trial_scheme(trial_scheme.session == s, 1:4));
    df(:,:,s) = thisrun;
end

%% Count per location/run

ncat = 8;
nloc = 4;
nsplits = size(df,3);

counts = zeros(ncat,nloc,nsplits); % Categories, Locations, Runs
for run = 1:size(df,3)
    for loc = 1:size(df,2)
        counts(:,loc,run) = histcounts(df(:,loc,run), 1:9)';
    end
end

%% Plot
x = 3;
y = 2;
for run = 1:size(df,3)
    subplot(x,y,run)
    bar(counts(:,:,run));
    colororder("reef")
    xticklabels({"Cat1", "Cat2", "Cat3", "Cat4", "Cat5", "Cat6", "Cat7", "Cat8"})
    ylabel("Number of trials")
    title(['Set ', num2str(run)])
    subtitle('colors = locations')
end

%% Plot the number of category repetitions in each run
figure(2)
catcount = sum(counts,2);
catcount = reshape(catcount,size(catcount,1),size(catcount,3));
bar(catcount);
colororder("reef")
xticklabels({"Cat1", "Cat2", "Cat3", "Cat4", "Cat5", "Cat6", "Cat7", "Cat8"})
ylabel("Number of trials")
%ylim([0,40])
title('Number of times a category appears in a run')
subtitle('colors = runs')


%% Check if permutations/combinations are equalized
clear combcounts
clear combV
load('ExperimentStruct_Nov3_1633.mat')
samplesCombination = Experiment.DM.samplesCombination;

combV=zeros(size(df,1),1,size(df,3));
combcounts = zeros(size(samplesCombination,1),2,size(combV,3));
for c = 1:length(samplesCombination)
    comb = samplesCombination(c,:);
    for run = 1:size(df,3)
        combcount = 0;
        for row = 1:size(df,1)
            if unique(df(row,:,run)) == unique(comb)
                combV(row,:,run) = c;
                combcount = combcount + 1;
            end
        end
            combcounts(c,1,run) = c;
            combcounts(c,2,run) = combcount;
    end
end

% combcounts = table(combcounts(:,1,1), combcounts(:,2,1), combcounts(:,2,2), combcounts(:,2,3),...
%                     'VariableNames', ["CombIdx", "freqRun1", "freqRun2", "freqRun3"]);



%% Check blocks in each session

counts = zeros(ncat,nloc,24); 
counter = 0;
for run = 1:length(unique(trial_scheme.session))
    thisrun = trial_scheme(trial_scheme.session == run, :);

    for block = 1:length(unique(trial_scheme.block))
        thisblock = thisrun(thisrun.block == block, :);
        thisblock = table2array(thisblock(:,1:4));
        counter = counter + 1;
        for loc = 1:4
            counts(:,loc,counter) = histcounts(thisblock(:,loc), 1:9)';
        end
    end
end

%% Plot blocks
x = 6;
y = 4;
for run = 1:size(counts, 3)
    subplot(y,x,run)
    bar(counts(:,:,run));
    colororder("reef")
    xticklabels({"Cat1", "Cat2", "Cat3", "Cat4", "Cat5", "Cat6", "Cat7", "Cat8"})
    ylabel("Number of trials")
    title(['Run ', num2str(run)])
    %subtitle('colors = locations')
end

figure()
hist(counts(:))
xlabel("Count of category per location per run")
ylabel("Frequency across 8 categories, 4 locations, 24 runs")

    

