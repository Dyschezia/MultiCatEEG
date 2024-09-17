load('ExpStruct.mat');

%% Get particular subject data

data = exp.subjects(6).runs;
data_cat = cat(3, data.categoryIdx);
split_data = num2cell(data_cat, [1 2]); %split data keeping dimension 1 and 2 intact
data_cat = vertcat(split_data{:});

multi_idx = sum(data_cat(:,:), 2 ) > 8; % take only multi-array trials
data_multi = data_cat(multi_idx, :); 
data_single = data_cat(~multi_idx, :); 

%% 
size(data_multi)
size(data_single)

%% How many times does each category appear in the experiment?

categories = 1:8;
locations = 1:4;
cat_loc = zeros(length(locations), length(categories));
cat_loc_single = zeros(length(locations), length(categories));


for c = categories
    totaln = sum(data_multi(:)==c);
    for l = locations
        totalnl = sum(data_multi(:, l)==c);
        totalnl_single = sum(data_single(:, l)==c);
        cat_loc(l, c) = totalnl;
        cat_loc_single(l, c) = totalnl_single;
    end
end

disp("(4-arrays) Each category (column) appears at each location (row) this number of times:")
disp(cat_loc)

%% How many times does each exemplar/orientation appear in the experiment?

% Exemplars
data_exmp = cat(3, data.exemplarIdx);
split_data = num2cell(data_exmp, [1 2]); %split data keeping dimension 1 and 2 intact
data_exmp = vertcat(split_data{:});

data_exmp_multi = data_exmp(multi_idx, :); 
data_exmp_single = data_exmp(~multi_idx, :); 

% Orientations
data_orient = cat(3, data.orientationIdx);
split_data = num2cell(data_orient, [1 2]); %split data keeping dimension 1 and 2 intact
data_orient = vertcat(split_data{:});

data_orient_multi = data_orient(multi_idx, :); 
data_orient_single = data_orient(~multi_idx, :); 

%% Count unique items
data_ids_str = strcat(string(data_multi), '_', string(data_exmp_multi), '_', string(data_orient_multi));
data_ids = str2double(strcat(string(data_multi), string(data_exmp_multi), string(data_orient_multi)));
unique_id = unique(data_ids);

id_counts = zeros(4, 8);
id_counts_nl = zeros(4, 8, 4);
rowidx = 1;
for i = 1:length(unique_id)
    id = unique_id(i);
    totaln = sum(data_ids(:)==id);
    idchar =  char(string(id));
    catidx = str2double(idchar(1));

    for l = locations
        totalnl = sum(data_ids(:, l)==id);
        id_counts_nl(rowidx, catidx, l) = totalnl;
    end
    id_counts(rowidx, catidx) = totaln;
    % Reset row counting for next category
    if rowidx == 4
        rowidx = 1;
    else 
        rowidx = rowidx+1;
    end
end

%% Create some figures

ids = unique_id;
freq = id_counts(:);

freq1 = id_counts_nl(:, :, 1);
freq2 = id_counts_nl(:, :, 2);
freq3 = id_counts_nl(:, :, 3);
freq4 = id_counts_nl(:, :, 4);

colors = parula(4);

figure
h1 = scatter(freq1(:), ids, "o", 'filled');
hold on
h2 = scatter(freq2(:), ids, "o",  'filled');
hold on
h3 = scatter(freq3(:), ids, "o",  'filled');
hold on
h4 = scatter(freq4(:), ids, "o",  'filled');
hold on
title("Frequency of item appearance per location");
ylabel("Item")
yticklabels(["Category 1", "Category 2", "Category 3", "Category 4", "Category 5", "Category 6", "Category 7", "Category 8"])  
xlabel("Frequency")
legend("Location 1","Location 2", "Location 3", "Location 4")

%%-------------------------------------------------------------------------
% Create design matrices
%--------------------------------------------------------------------------

%% 1) Single-item or multi-item DM
% The simplest 2-condition DM: multi-array condition or single-array
% condition.

C1 = []; % single-item condition
C2 = []; % multi-item condition
nC = 2; % Total number of conditions
nR = 24; % Total number of runs
DM = zeros(length(data), nC*nR); % length of the data , (conditions*runs)
for run = 1:length(data)
    run_data = data(run).categoryIdx;
    multi_idx = sum(run_data(:,:), 2 ) > 8; % take only multi-array trials
    single_idx = ~multi_idx;
    thisrun = [multi_idx, single_idx];

    begin = (run-1)*length(run_data)+1;
    endat = run*length(run_data);
    DM(begin:endat, (run-1)*nC+1:run*nC) = thisrun;
end
imagesc(DM)

%% 2) Unique combination of categories DM
% One condition for each unique combination of shown categories, ignoring
% location. There is 70 conditions for multi-arrays + 8 conditions for
% single arrays. Assign as 78 conditions.

nC = 78; % Total number of conditions
nR = 24; % Total number of runs
basicDM = load('DM.mat');
all_combinations = basicDM.DM.samplesCombination; % The 70 unique combinations

C = 1:nC; % conditions
nC = length(C); % number of conditions
nR = 24; % Total number of runs
DM = zeros(length(data), nC*nR); % length of the data , (conditions*runs)
for run = 1:length(data)
    run_data = data(run).categoryIdx;
    % Single/multi trials
    single_idx = sum(run_data(:,:), 2 ) <= 8; % single-array trials
    multi_idx = sum(run_data(:,:), 2 ) > 8; % multi-array trials;
    % Multi-item combinations
    for combidx = 1:70
        run_data contains all_combinations(combidx)


    end





    thisrun = [multi_idx, single_idx];

    begin = (run-1)*length(run_data)+1;
    endat = run*length(run_data);
    DM(begin:endat, (run-1)*nC+1:run*nC) = thisrun;
end
imagesc(DM)

%% Unique categories
    % Loop through categories and check if any row contains category
    any(run_data==8, 2)




