%% Various snippets

load('DM.mat')

%% A vector indexing each permutation as belonging to a combination
permutations = DM.samplesPermutation;
combs = DM.samplesCombination;

nPerms=length(permutations);
nCombs=length(combs);
nItems=size(permutations,2);
runLength=nCombs;
nRuns=nPerms/nCombs;

allSamples=zeros(runLength,nItems,nRuns);
perms_vector = zeros(nPerms,1);
perms_count = zeros(nCombs,2);

combIdx=1;
for c = 1:length(combs)
    counter = 0;
    for p = 1:length(permutations)
        if unique(permutations(p,:)) == unique(combs(c,:))
            perms_vector(p,1) = c;
            counter=counter+1;
        end
    end
    perms_count(c,1) = c;
    perms_count(c,2) = counter;
    combIdx=combIdx+1;
end

%csvwrite('combinations_vector', perms_vector)

%% Split permutations into runs - one combination per run
rng("default")

samplesPermutation = DM.samplesPermutation;
samplesCombination = DM.samplesCombination;

samplesPermutation = samplesPermutation(randperm(size(samplesPermutation,1)),:);

nPerms=length(samplesPermutation);
nCombs=length(samplesCombination);
nItems=size(samplesPermutation,2);
runLength=nCombs;
nRuns=nPerms/nCombs;

allSamples=zeros(runLength,nItems,nRuns);
combIdx=1;
for c = 1:length(samplesCombination)
    runIdx=1;
    for p = 1:length(samplesPermutation)
        if unique(samplesPermutation(p,:)) == unique(samplesCombination(c,:))
            allSamples(combIdx,:,runIdx) = samplesPermutation(p,:);
            runIdx=runIdx+1;
        end
    end
    combIdx=combIdx+1;
end

%DM.runStructure = allSamples;

%% 
