function Experiment = loadExperimentStruct(TmpExperiment)

ExpFile = fullfile(TmpExperiment.Subject.SubPath, ['SUB_' TmpExperiment.Subject.ID '_ExperimentStruct.mat']);
tmp = load(ExpFile);
Experiment = tmp.Experiment;

