function Experiment = sendEEGTrigger(Experiment, usecase)
% RK(19/09/24): The function sends a trigger depending on the room of
% recording. The amplifier in the EEG-eyelink room can send 16bit triggers,
% but the one in the EEG room only 8. 
% For eyelink, stimuli are defined using 4 digit numbers where each digit
% varies from 1 to 8, standing for each category. 

if strcmp(Experiment.Env.Environment,'EEG_eyelink_FU')
    switch usecase
        case 'fixation'
        case 'stimulus'
        case 'probe'
        case 'response'

    end 
elseif strcmp(Experiment.Env.Environment,'EEG_FU')
      error('Triggers are not defined yet for the noneyelink room')  
end 

end