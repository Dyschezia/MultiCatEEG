function Experiment = setupEnvironment(Experiment)
% Additional 'Env' settings that are set up once the PTB display is opened.
% Also set up keys/responses.

window = Experiment.Display.window;

%% 'Env' - some parameters related to the experimental context

% Define environment and load appropriate settings
% Manually enter distance in cm and screen size [x,y] in cm
switch Experiment.Env.Environment
    case 'EEG_FU' % RK(19/09/24)
        Experiment.Env.TotalDistance = 60; % RK(19/09/24)
        Experiment.Env.ScreenSize = [47.5, 29.5]; % RK(19/09/24)
        
        % Add keys
        Experiment.Keys.EscKey = 27;
        Experiment.Keys.LeftResponse = 49; %1
        Experiment.Keys.RightResponse = 50; %2
        Experiment.Keys.ControlKeys = 13; % Enter
        Experiment.Keys.MRItrigger = 53; % MRI trigger - 5

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
        Experiment.Env.TotalDistance = 110;
        Experiment.Env.ScreenSize = [48, 27]; %[59.8, 33.6];   
        
        % Add keys
        Experiment.Keys.EscKey = 10; %KbName('5%')
        Experiment.Keys.LeftResponse = 114;
        Experiment.Keys.RightResponse = 115;
        Experiment.Keys.ControlKeys = 37; % Enter
        Experiment.Keys.MRItrigger = 15; % MRI trigger
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
    
Experiment.Env.IFI = Screen('GetFlipInterval', window);
Experiment.Env.HalfIFI = Experiment.Env.IFI / 2;




