function Experiment = InitiateEyeTracking(Experiment)
dummymode = 0;
EyeLinkInit(dummymode); % initialize eyelink connection
status = EyeLink('IsConnected');
if status < 1 % If EyeLink not connected
    dummymode = 1;
end

% Open dialog box for EyeLink Data file name entry. File name up to
% 8 characters. 
prompt = {'Enter EDF file name (up to 8 characters)'};
dlg_title = 'Create EDF file';
def = {'test'}; % Create a default edf file name
answer = inputdlg(prompt, dlg_title, 1, def); % Prompt for new EDF file name 
% Print some text in Matlab's Command Window if a file name has not
% been entered
if isempty(answer)
    fprintf('Session cancelled by user (no edf file name set) \n')
    error('Session cancelled by user (not edf file name set)'); % Abort experiment (cleaning function?)
end
edfFile = answer(1);
% Is file name longer than 8 characters?
if length(edfFile) > 8
    fprintf('EDF filename too long (max 8 characters, letter numbers or underscores) \n')
    error('EDF filename too long '); 
end

% Open and name an EDF file
failOpen = EyeLink('OpenFile', edfFile);
if failOpen ~= 0 % abort if failed to open
    fprintf('Could not create EDF file %s', edfFile);
    error('Could not create EDF file %s', edfFile);
end

%% Save samples and events (events might be unnecessary?)
% Selects which events are saved to the EDF file. Include everthing
% just in case. 
Eyelink('Command', 'file_event_filter = LEFT, RIGHT, FIXATION, SACCADE, BLINK, MESSAGE, BUTTON, INPUT');
% Selects which sample data are saved to the EDF file. Include everthing
% just in case. 
Eyelink('Command', 'file_sample_data = LEFT, RIGHT, GAZE, HREF, RAW, AREA, GAZERS, BUTTON, STATUS, INPUT');
% currently not initiating any data to be available online

%% Set calibration preferences

% first get some defaults
el = EyelinkInitDefaults(Experiment.Display.window);
% set calibration/validation/drift-check(or drift-correct) size as well as background and target colors. 
% It is important that this background colour is similar to that of the stimuli to prevent large luminance-based 
% pupil size changes (which can cause a drift in the eye movement data)
el.calibrationtargetsize = 3;% Outer target size as percentage of the screen
el.calibrationtargetwidth = 0.7;% Inner target size as percentage of the screen
el.backgroundcolour = [255, 255, 255]/2; % Same as the experiment background!
el.calibrationtargetcolour = [0 0 0];% RGB black
% set "Camera Setup" instructions text colour so it is different from background colour
el.msgfontcolour = [0 0 0];% RGB black

% Use an image file instead of the default calibration bull's eye targets. 
% Commenting out the following two lines will use default targets:
%el.calTargetType = 'image'; % copy image to exp folder
%el.calImageTargetFilename = [pwd '/' 'fixTarget.jpg'];

% Set calibration beeps (0 = sound off, 1 = sound on)
el.targetbeep = 1;  % sound a beep when a target is presented
el.feedbackbeep = 1;  % sound a beep after calibration or drift check/correction

% You must call this function to apply the changes made to the el structure above
EyelinkUpdateDefaults(el);

Experiment.Eyetracking.el = el;

%% Calibrate 
% Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, Experiment.Env.ScreenSizeX-1, Experiment.Env.ScreenSizeY-1);

% Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
Eyelink('Command', 'calibration_type = HV13'); % horizontal-vertical 13-points

% Here the demo sets a buttonbox button to be used for manual calibration -
% check whether this can be set via the GUI too?

% Should I unhide the mouse here?

% Start listening for keyboard input. Suppress keypresses to Matlab windows.
% Is screen 0 the correct screen?
ListenChar(-1);
Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
% Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
EyelinkDoTrackerSetup(el);


    