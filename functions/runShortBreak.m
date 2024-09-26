function Experiment = runShortBreak(Experiment)
% RK 26/09/24

% Get necassary values
session = Experiment.Subject.WhichSession;
set = Experiment.Subject.WhichSet;
run = Experiment.Log.CurrentRun;

window = Experiment.Display.window; 
expectedTime = Experiment.Log.ExpectedTime;
startTime = Experiment.Log.StartTime;
shortBreakDur = Experiment.Task.ShortBreakDur;
ScreenCenterX = Experiment.Env.ScreenCenterX;
ScreenCenterY = Experiment.Env.ScreenCenterY;
halfifi = Experiment.Env.HalfIFI;

% add text on screen saying take a short break
text = ['Take a short break of ' num2str(shortBreakDur) ' seconds. Press any key to skip'];
DrawFormattedText(window, text, 'center', 'center');
Screen('DrawingFinished', window);
vbl = Screen('Flip', window, startTime + expectedTime - halfifi);

% Update expected time of the next event
expectedTime = expectedTime + shortBreakDur;
Experiment.Log.timing(end+1,:) = table(session, set, run, NaN, NaN, NaN, {'short_break'},NaN, vbl);

% Check if a key is pressed until the end of the break
keyDown = 0;
while GetSecs() < startTime + expectedTime - 0.1
    [keyDown, ~ , ~ , ~ ] = KbCheck();
    if keyDown
        expectedTime = GetSecs() - t0 + 0.1;
        break
    else
        text = ['Take a short break of ' num2str(floor(startTime + expectedTime - GetSecs())) ' seconds. Press any key to skip'];
        DrawFormattedText(window, text, 'center', 'center');
        Screen('DrawingFinished', window);
        vbl = Screen('Flip', window);
        WaitSecs(0.05);
    end
end

% Run a drift check 
if strcmp(Experiment.Env.Environment, 'EEG_eyelink_FU') && Experiment.Mode.ETing == 1
    EyelinkDoDriftCorrection(Experiment.Eyetracking.el, ScreenCenterX, ScreenCenterY);
    expectedTime = GetSecs() - startTime + 0.1;
end

% Add a longer fixation to make sure subjects is fixating
Screen('DrawDots', window, [ScreenCenterX, ScreenCenterY], Experiment.Stim.FixationPixels, Experiment.Stim.FixationColour, [], 2);
Screen('DrawingFinished', window);
vbl = Screen('Flip', window, startTime + expectedTime - halfifi);
Experiment.Log.timing(end+1,:) = table(session, set, run, NaN, NaN, NaN, {'long_fixation'},NaN,vbl);
expectedTime = expectedTime + startGap;

Experiment.Log.ExpectedTime = expectedTime;
