function Experiment = InitiateEyeTracking(Experiment)
% Should I set screen number to be different than 0?

dummymode = 0;
EyelinkInit(dummymode); % initialize eyelink connection
status = Eyelink('IsConnected');
if status < 1 % If EyeLink not connected
    dummymode = 1;
end

% Set file name (SXX_session_runOfTotal)
session = Experiment.Subject.WhichSession;
set = Experiment.Subject.WhichSet;
run = Experiment.Log.CurrentRun;
totalRuns = length(Experiment.Session(session).Set(set).RunShuffled);
runOfTotal = totalRuns * (set-1) + run;
subject = Experiment.Subject.ID; 

if strcmp(subject, 'test')
    edfFile = ['tst_' num2str(session) '_' num2str(runOfTotal)];
else
    edfFile = ['S' num2str(subject) '_' num2str(session) '_' num2str(runOfTotal)];
end

% Is file name longer than 8 characters?
if length(edfFile) > 8
    fprintf('EDF filename too long (max 8 characters, letter numbers or underscores) \n')
    error('EDF filename too long '); 
end

% Open and name an EDF file
failOpen = Eyelink('OpenFile', edfFile);
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
if el.targetbeep || el.feedbackbeep
    InitializePsychSound();
end

% You must call this function to apply the changes made to the el structure above
EyelinkUpdateDefaults(el);

Experiment.Eyetracking.el = el;
Experiment.Eyetracking.dummymode = dummymode;

%% Calibrate 
% Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, Experiment.Env.ScreenSizeX-1, Experiment.Env.ScreenSizeY-1);

% Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
Eyelink('Command', 'calibration_type = HV13'); % horizontal-vertical 13-points

% Set drift checks to force a maximum error of 1 degree (default is 2)
 %Eyelink('Command', 'drift_correction_rpt_error = 1.0');

% Here the demo sets a buttonbox button to be used for manual calibration -
% check whether this can be set via the GUI too?

% Should I unhide the mouse here?

% Start listening for keyboard input. Suppress keypresses to Matlab windows.
% Is screen 0 the correct screen?
%ListenChar(-1);
% Which screen does the next command clean?
Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
% Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
EyelinkDoTrackerSetup(el);


    