function Experiment = createDirFile(Experiment)

%% Log file

id = Experiment.Subject.ID;

% Create a directory for saving the pregenerated file
subPath = Experiment.Subject.SubPath;

if exist(subPath,'dir') == 0
    mkdir(subPath)
end

% Pregenerated file name
outFile = fullfile(subPath,['SUB_' id '_ExperimentStruct']);

% Check to avoid overiding an existing file
if exist([outFile,'.mat']) == 2 
    fileproblem = input('Pregenerated experiment file already exists! OVERWRITE (1/DEFAULT), or break (2)?');
    if fileproblem == 2
        return;
    elseif isempty(fileproblem) | fileproblem == 1
        delete([outFile, '.mat']);
    end
end 

Experiment.Subject.ExperimentStructPath = outFile;