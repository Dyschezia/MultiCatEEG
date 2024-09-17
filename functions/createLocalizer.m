function Experiment = createLocalizer(Experiment)

if strcmp(Experiment.Mode.mode, 'test')
    rng(4017 + Experiment.Subject.WhichSession)
else
    rng(4017 + str2double(Experiment.Subject.ID)+Experiment.Subject.WhichSession)
end
    
Experiment.Paths.LocalizerDir = fullfile(Experiment.Paths.MainPath, 'localizerSet');
itemIndex = readtable(fullfile(Experiment.Paths.LocalizerDir, "itemIndex.csv"));

localizers = {'faces', 'houses', 'hands', 'objects', 'mixed', 'scrambled'};
object_localizer = {'cars', 'chairs', 'plants', 'shoes'};
locations = 4;
repperblock = 20; % how many repetitions per block

n4arrays = length(localizers);
n1arrays = length(localizers) * locations;
totalN = n4arrays + n1arrays;

vars = ["Block", "IsSingle", "CategoryName", "Location", "StimArray"];
types = ["double", "double", "cell", "double", "cell"];
locData = table('Size', [totalN*repperblock, length(vars)], 'VariableNames', vars, 'VariableTypes', types);

%% Create localizer blocks
block = 1;
for localizer_type = 1:length(localizers)
    
    cat = localizers(localizer_type);
    
    for i = 1:locations + 1 %Loop through all 1-arrays and one 4-array
   
        idx = (block-1)*repperblock+1:block*repperblock;
        
        % Save Block N
        locData.Block(idx) = repelem(block, repperblock, 1);
        
        % Save category name
        locData.CategoryName(idx) = repelem(cat, repperblock, 1);
        
        switch cat{:}
            
            case {"faces", "houses", "hands"}
                % Category N
                catN = itemIndex.CategoryIndex(strcmp(itemIndex.CategoryName, cat));
                
                % Select items that we need for this block
                block_items = dir(fullfile(Experiment.Paths.LocalizerDir,  [num2str(catN), '*.png']));
                block_items = {block_items.name};
                block_items = cellfun(@(x) x(1:3), block_items, 'UniformOutput', false);
                block_items = cellfun(@(x) str2double(x), block_items);
                
                stims = [];
                 % Draw random items for stim array
                for rep = 1:repperblock
                    R = randsample(block_items, 4, true); % With replacement - if without, change to False
                    stims = [stims; {R}];
                end
                
                % Save array
                locData.StimArray(idx) = stims;
                
            case "objects"
                % Category N
                catN = itemIndex.CategoryIndex(ismember(itemIndex.CategoryName, object_localizer));
                
                % Select items that we need for this block
                block_list = [];
                stims = {};
                for ci = 1:length(catN)
                    c = catN(ci);
                    block_items = dir(fullfile(Experiment.Paths.LocalizerDir,  [num2str(c), '*.png']));
                    block_items = {block_items.name};
                    block_items = cellfun(@(x) x(1:3), block_items, 'UniformOutput', false);
                    block_items = cellfun(@(x) str2double(x), block_items);
                    block_list = [block_list, block_items];
                end
                
                % Draw random items for stim array
                for rep = 1:repperblock
                    R = randsample(block_list, 4, true); % With replacement - if without, change to False
                    stims = [stims; {R}];
                end
                
                % Save Stim array
                locData.StimArray(idx) = stims;
                
                
            case "mixed"
                % Check which items are there in the localizer floder
                block_list = [];
                block_items = dir(fullfile(Experiment.Paths.LocalizerDir,  '*.png'));
                block_items = {block_items.name};
                block_items = cellfun(@(x) x(1:3), block_items, 'UniformOutput', false);
                block_items = cellfun(@(x) str2double(x), block_items);
                block_list = [block_list, block_items];
                block_list = block_list(33:end); % Remove the 32 scrambled images from the mix
                
                stims = {};
                % Draw random items for stim array
                for rep = 1:repperblock
                    R = randsample(block_list, 4, true); % With replacement - if without, change to False
                    stims = [stims; {R}];
                end
                
                % Save Category N
                locData.CategoryN(idx) = repelem({'all_cat'}, repperblock, 1);
                
                % Save Stim array
                locData.StimArray(idx) = stims;
                
            case "scrambled"
                % \list the scrambled images
%                 block_list = [];
%                 block_items = dir(fullfile(Experiment.Paths.LocalizerDir,  'scrambled', '*.png'));
%                 block_items = {block_items.name};
%                 
%                 stims = {};
%                 % Draw random items for stim array
%                 for rep = 1:repperblock
%                     R = randsample(block_items, 4, true); % With replacement - if without, change to False
%                     stims = [stims; {R}];
%                 end
%                 
%                 % Save Category N
%                 locData.CategoryN(idx) = repelem({'scrambled'}, repperblock, 1);
%                 
%                 % Save Stim array
%                 locData.StimArray(idx) = stims;

                block_list = [];
                block_items = dir(fullfile(Experiment.Paths.LocalizerDir,  'scrambled', '*.png'));
                block_items = {block_items.name};
                block_items = cellfun(@(x) x(1:3), block_items, 'UniformOutput', false);
                block_items = cellfun(@(x) str2double(x), block_items);
                block_list = [block_list, block_items];

                stims = {};
                % Draw random items for stim array
                for rep = 1:repperblock
                    R = randsample(block_list, 4, true); % With replacement - if without, change to False
                    stims = [stims; {R}];
                end

                % Save Category N
                locData.CategoryN(idx) = repelem({'scrambled'}, repperblock, 1);

                % Save Stim array
                locData.StimArray(idx) = stims;
                
        end
        
        if i == 5
            locData.IsSingle(idx) = repelem(0, repperblock, 1);
            locData.Location(idx) = repelem(0, repperblock, 1);
            
        else
%             if strcmp(cat, 'scrambled')
%                 all_items = [];
%                 for rep = 1:repperblock
%                     whole_array =  locData.StimArray(idx);
%                     item = whole_array{rep}(i);
%                     all_items = [all_items, item];
%                 end
%                 locData.StimArray(idx) = all_items;
%                 
%             else
            locData.IsSingle(idx) = repelem(1, repperblock, 1);
            locData.Location(idx) = repelem(i, repperblock, 1);
            % Select only one location
            tmp = cellfun(@(x) cell2mat(x),num2cell(locData.StimArray(idx),1),'uni',0);
            tmp = tmp{:};
            select = tmp(:, i);
            locData.StimArray(idx) = num2cell(select);
%             end
             
        end
        
        block = block + 1;
    end
    
end

%% Shuffle the order of localizer blocks
blocks = unique(locData.Block); % get all block Ns
Rblocks = blocks(randperm(length(blocks))); % shuffle them around
Rblocks_v = repelem(Rblocks, 20, 1); % create a new vector that repeats shuffled block Ns
locData.Block = Rblocks_v; % make this new vector the block Ns
locData = sortrows(locData, "Block");

%% Add localizer "catch"
% Add N catch trials, such that it is selected from a split of all trials
% (pseudorandom - catch occurs roughly equally interspersed)

totalN = length(blocks) * repperblock;
catchN = Experiment.Task.LocalizerCatchN;
splits = round(linspace(1, totalN, (catchN+1))); 
catch_trials = zeros(1, totalN);
for s = 1:catchN
    split = [splits(s), splits(s+1)];
    rand_idx = randi(split, 1, 1);
    catch_trials(rand_idx) = 1;
end
locData.CatchTrial = catch_trials';

%% Add trial numbers

%locData.Trial = [1:totalN]';

Experiment.Images.Localizer = locData;





