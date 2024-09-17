function Experiment = subjectInfo(Experiment)
% Set Up Subject information and directory 

mainPath = Experiment.Paths.MainPath;

%% Request participant information
switch Experiment.Mode.mode
    case 'test'
        id = 'test';
        fprintf(['\nSubject ID: ' id]);
         
    case 'experiment'
        id = '';
        while isempty(id)
            id = input('Subject ID:  ', 's');
        end
end

subPath = fullfile(Experiment.Paths.OutDir,['SUB_' id]);

Experiment.Subject = struct();
Experiment.Subject.ID = id;
Experiment.Subject.SubPath = subPath;