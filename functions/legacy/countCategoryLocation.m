function counts = countCategoryLocation(runs, Experiment)

ncat = 8;
nloc = 4;
nsplits = 3;

counts = zeros(ncat,nloc,nsplits); % Categories, Locations, Runs
for run = 1:size(runs,3)
    for loc = 1:size(runs,2)
        counts(:,loc,run) = histcounts(runs(:,loc,run), 1:Experiment.Stim.CategoriesN+1)';
    end
end