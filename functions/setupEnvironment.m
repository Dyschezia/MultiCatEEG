function Experiment = setupEnvironment(Experiment)
% Additional 'Env' settings that are set up once the PTB display is opened.
% Also set up keys/responses.

window = Experiment.Display.window;

%% 'Env' - some parameters related to the experimental context

% Define environment and load appropriate settings
% Manually enter distance in cm and screen size [x,y] in cm
switch Experiment.Env.Environment
    case 'EEG_eyelink_FU' % RK(19/09/24)
        Experiment.Env.TotalDistance = 60; % RK(19/09/24)
        Experiment.Env.ScreenSize = [47.5, 29.5]; % RK(19/09/24)
        
        % Add keys
        Experiment.Keys.EscKey = 27;
        Experiment.Keys.LeftResponse = 37; %left
        Experiment.Keys.RightResponse = 39; %right
        Experiment.Keys.ControlKeys = 13; % Enter
        %Experiment.Keys.MRItrigger = 53; % MRI trigger - 5
        
        % Set EEG triggers
        eeg_dir = 'D:\cichyLab\#Common\parallel_port';
        addpath(eeg_dir);
        Experiment.Triggers.Address = hex2dec('3FE0');
        Experiment.Triggers.TriggerDelay = 0.01367;
        Experiment.Triggers.MultiTriggerDelay = 0.01;
        %addpath('.\iosetup\');

        case 'EEG_FU' % RK(19/09/24)
        % Not yet measured! copied from above!!
        Experiment.Env.TotalDistance = 60; % RK(19/09/24)
        Experiment.Env.ScreenSize = [47.5, 29.5]; % RK(19/09/24)
        
        % Add keys
        Experiment.Keys.EscKey = 27;
        Experiment.Keys.LeftResponse = 37; %left
        Experiment.Keys.RightResponse = 39; %right
        Experiment.Keys.ControlKeys = 13; % Enter
        %Experiment.Keys.MRItrigger = 53; % MRI trigger - 5
        
        % Set EEG triggers
        eeg_dir = 'D:\cichyLab\#Common\parallel_port';
        addpath(eeg_dir);
        Experiment.Triggers.TriggerDelay = 0.011;
        % how long to wait between several triggers? 
        Experiment.Triggers.MultiTriggerDelay = 0.01;
        % For eeg only, function is supposed to work only with trigger_num.
        %addpath('.\iosetup\');

    %{
    case 'behavLabBCCN'
        Experiment.Env.TotalDistance = 100;
        Experiment.Env.ScreenSize = [59.8, 33.6];
        
         % Add keys
        Experiment.Keys.EscKey = 27; %KbName('5%')
        Experiment.Keys.LeftResponse = 37;
        Experiment.Keys.RightResponse = 39;
        Experiment.Keys.ControlKeys = 13; % Enter
        Experiment.Keys.MRItrigger = 53; % MRI trigger
        %}
        
    case 'home'
        Experiment.Env.TotalDistance = 50;
        Experiment.Env.ScreenSize = [31, 18.5]; %[59.8, 33.6];   
        
        % Add keys
        Experiment.Keys.EscKey = 27; %KbName('5%')
        Experiment.Keys.LeftResponse = 37;
        Experiment.Keys.RightResponse = 39;
        Experiment.Keys.ControlKeys = 13; % Enter
        %Experiment.Keys.MRItrigger = 15; % MRI trigger
end


%% Measuring the screen

% Get the size of the onscreen window
%Experiment.Env.ScreenSize = Screen('WindowSize', window);
[xPixels, yPixels] = Screen('WindowSize', window);
Experiment.Env.ScreenSizeX = xPixels;
Experiment.Env.ScreenSizeY = yPixels;

% Get the centre coordinate of the window
Experiment.Env.ScreenCenterX = Experiment.Env.ScreenSizeX/2;
Experiment.Env.ScreenCenterY = Experiment.Env.ScreenSizeY/2;

%% Estimate flip interval 
IFI = Screen('GetFlipInterval', window);
Experiment.Env.IFI = IFI;
Experiment.Env.HalfIFI = IFI / 2;

%% RK 04/10/24 Define event durations as multiple of IFIs

% Set timing parameters to be multiples of the IFI
Experiment.Time.StimExpTimeFrames = round(Experiment.Time.StimExpTime / IFI);
Experiment.Time.FeedbackGapFrames = round(Experiment.Time.FeedbackGap / IFI);
Experiment.Time.CatchIti1Frames = round(Experiment.Time.CatchIti1 / IFI);
Experiment.Time.StartGapFrames = round(Experiment.Time.StartGap / IFI);
Experiment.Time.StopGapFrames = round(Experiment.Time.StopGap / IFI);
Experiment.Time.AfterProbeGapFrames = round(Experiment.Time.AfterProbeGap / IFI);
Experiment.Time.RespWaitFrames = round(Experiment.Time.RespWait / IFI);

% Set the pregenerated random ITIs to be multiples of the IFI
nSessions = Experiment.Task.SessionsN;
nSets = Experiment.Task.SetsN / nSessions;
nRuns = Experiment.Task.RunsN;

for set = 1:nSets
    for run = 1:nRuns
        Experiment.Session(session).Set(set).RunShuffled(run).ITIsFrames = round(Experiment.Session(session).Set(set).RunShuffled(run).ITIs / IFI);
    end
end

