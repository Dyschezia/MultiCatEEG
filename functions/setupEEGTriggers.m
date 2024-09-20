function Experiment = setupEEGTriggers(Experiment)
% RK (20/09/24): Function sets up and adds to the trial scheme triggers for 
% different events. Since the eyelink room amp has 16 bits, trigger number 
% can go up to +~60000.
% Stimuli triggers are of the form 1xxxx. Response triggers are of the form
% 2xxxx. Eyelink calibration events are of the form 3xxxx. Probe events are
% 4xxxx. 
if strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU')
    %...
elseif strcmp(Experiment.Env.Environment, 'EEG_FU')
    error('triggers are not defined for the EEG room yet (amp has only 8 bits)');
else
    fprintf('\n Not setting up EEG triggers (run in home)')
end 