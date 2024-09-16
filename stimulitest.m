% Open PTB screen
%fprintf('\nOpening Psychtoolbox\n')
background = [255, 255, 255]/2; % Bacgkround color in RGB 
%background = [0.5, 0.5, 0.5]; % Bacgkround color in RGB 
%Experiment.Stim.BackgroundColor = background;

Screen('Preference', 'SkipSyncTests', 0);
[window, rect] = Screen('OpenWindow', 2); %background
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

Screen('FillRect', window, background);

[thisImage, ~, ~] = imread("D:\Psychtoolbox\Karla\MultiCAT\ptb_code\object03.jpg");
imageTex = Screen('MakeTexture', window, thisImage);     

Screen('DrawTexture', window, imageTex, [], []); % Stimulus
Screen('Flip', window)

img = Screen('GetImage', window);
imwrite(img, 'stimulus.png', 'PNG');
