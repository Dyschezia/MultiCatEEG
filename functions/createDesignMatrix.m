function Experiment = createDesignMatrix(Experiment)

categories = 1:Experiment.Stim.CategoriesN;
locations = 1:Experiment.Stim.LocationsN;
arraySizes = Experiment.Stim.ArraySizes;
total = length(categories) * length(locations) * length(arraySizes);

%% Design matrix
C = repelem(categories(:), total/length(categories)); % categories
L = repmat(locations(:), total/length(locations), 1); % locations
S = repmat(repelem(arraySizes(:), 4), total/length(categories), 1); % array sizes

DM.values = [C, L, S];
DM.legend = [{'category'}, {'location'}, {'arraySize'}];
DM.categories = [{'animals'}, {'cars'}, {'chairs'}, {'faces'}, {'hands'}, {'houses'}, {'plants'}, {'shoes'}];
DM.locations = [{'top_left'}, {'bottom_left'}, {'top_right'}, {'bottom_right'}];
DM.arraySize = [{'single_item'}, {'four_item'}];
DM.exemplars_legend = ["cat", "beetle", "armchair", "female", "highfive", "small", "small", "sneakers",...
                       "turtle", "jeep", "modern", "male", "thumbsup", "large", "large", "boots"]; 
DM.exemplars_idx = [11, 21, 31, 41, 51, 61, 71, 81; 
                    12, 22, 32, 42, 52, 62, 72, 82];
DM.orientations = [1:2];

%% All permutations for 4 item arrays (sampled without repetition, order matters)
% Given list of items
items = categories;

% Number of items to sample
numItemsToSample = length(locations);

% Permutations - Generate all possible 4-item samples with order (without repetition)
samples = perms(items);
samplesPermutation = unique(samples(:, 1:numItemsToSample), 'rows', 'stable');

% Combinations - Generate all possible 4-item samples without order (without repetition)
samplesCombination = nchoosek(items,4);

% Save combinations and permutations in the output variable
DM.samplesPermutation = samplesPermutation;
DM.samplesCombination = samplesCombination;


%% All permutations for 1-arrays for 4 locations
items = categories;
nans = [0,0,0,0];
samples = [];

for item = 1:length(items)
    for location = 1:length(locations)
        sample = nans;
        sample(location) = items(item);
        samples = [samples; sample];
    end
end

DM.samplesPermutation_1item = samples;

%% Save

Experiment.DM = DM;




