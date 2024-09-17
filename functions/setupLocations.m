function Experiment = setupLocations(Experiment)
% Convert stimulus coordinates into rectangles that PTB needs
% (x-up-left, y-up-left, x-down-right, y-down-right)
% The origin (0,0) is the top left corner of the screen.

% Variables
nItems = 4;

% First create a base rectangle
baseRect = [0 0 Experiment.Stim.WidthPixels Experiment.Stim.HeightPixels];

% X and & offset from the centre
x = Experiment.Stim.DistancePixelsX;
y = Experiment.Stim.DistancePixelsY; 

% Screen centre
xc = Experiment.Env.ScreenCenterX;
yc = Experiment.Env.ScreenCenterY;

% Locations: top left, top right, bottom left, bottom right
rectLocations = [ [xc-x, yc+y]; [xc+x, yc+y]; [xc-x, yc-y]; [xc+x, yc-y] ];

% Centre the base rectangles on the locations
rectDestinations = [];
for loc = 1:length(rectLocations)
    positionX = rectLocations(loc, 1);
    positionY = rectLocations(loc, 2);
    rectDest = CenterRectOnPointd(baseRect, positionX, positionY);
    rectDestinations = [rectDestinations, rectDest'];
end

% Make the locations for the response screen
x = Experiment.Stim.DistancePixelsX; % Offset x
y = Experiment.Stim.DistancePixelsY; %Offset y
rectLocationsProbe = [[xc, yc-y]; [xc-x, yc+y]; [xc+x, yc+y]]; %Response screen: Probe, Response 1 (left), Response 2 (right)

% Centre the base rectangles on the locations
rectDestinationsProbe = [];
for loc = 1:length(rectLocationsProbe)
    positionX = rectLocationsProbe(loc, 1);
    positionY = rectLocationsProbe(loc, 2);
    rectDest = CenterRectOnPointd(baseRect, positionX, positionY);
    rectDestinationsProbe = [rectDestinationsProbe, rectDest'];
end

Experiment.Images.RectDestinations = rectDestinations;
Experiment.Images.RectDestinationsProbe = rectDestinationsProbe;



