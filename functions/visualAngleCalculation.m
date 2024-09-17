function Experiment = visualAngleCalculation(Experiment)
% We define relevant sizes (stimulus height and width, distance, etc.) and
% locations on screen in terms of visual angles, i.e. how many degrees from
% the fixation point is the relevant point on the screen. This ensures that
% the presentation scales correctly and automatically when presented on
% monitors of different size and resolution, or when placed at different
% distances.
%
% Here we convert degrees of visual field into number of pixels on the screen 
% We save all relevant converted alues in 'Experiment' struct. 

%% General parameters
totdist = Experiment.Env.TotalDistance;
screenwidth = Experiment.Env.ScreenSize(1);
screenres = Experiment.Env.ScreenSizeX;

%% Eccentricity from center (stimulus distance from fixation)

visanglex = Experiment.Stim.DistanceX;
visangley = Experiment.Stim.DistanceY;

[sizex, sizey] = visangle2stimsize(visanglex,visangley,totdist,screenwidth,screenres);

Experiment.Stim.DistancePixelsX = sizex;
Experiment.Stim.DistancePixelsY = sizey;

%% Stimulus size

visanglex = Experiment.Stim.Width;
visangley = Experiment.Stim.Height;

[sizex, sizey] = visangle2stimsize(visanglex,visangley,totdist,screenwidth,screenres);

Experiment.Stim.WidthPixels = sizex;
Experiment.Stim.HeightPixels = sizey;

%% Fixation 

visanglex = Experiment.Stim.FixRadius;

[sizex, ~] = visangle2stimsize(visanglex,visangley,totdist,screenwidth,screenres);

Experiment.Stim.FixationPixels = sizex;

%% Response probe size

visanglex = Experiment.Resp.ProbeWidth;
visangley = Experiment.Resp.ProbeHeight;

[sizex, sizey] = visangle2stimsize(visanglex,visangley,totdist,screenwidth,screenres);

Experiment.Resp.ProbeWidthPixels = sizex;
Experiment.Resp.ProbeHeightPixels = sizey;

%% Response choices (yes/no) size

visanglex = Experiment.Resp.RespWidth;
visangley = Experiment.Resp.RespHeight;

[sizex, sizey] = visangle2stimsize(visanglex,visangley,totdist,screenwidth,screenres);

Experiment.Resp.ProbeWidthPixels = sizex;
Experiment.Resp.ProbeHeightPixels = sizey;

end