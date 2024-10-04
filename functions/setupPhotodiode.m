function Experiment = setupPhotodiode(Experiment)
    % Currently hardcoded 20pixel big square at the top left corner of the
    % screen. 
    
    % Size of square in pixels
    size = 45; 
    
    % set rectangle
    photodiodeRect = SetRect(0,0,size,size);
    
    % Set color
    color = [255, 255, 255];
    
    % Save
    Experiment.Photodiode.size = size;
    Experiment.Photodiode.color = color;
    Experiment.Photodiode.rect = photodiodeRect;
    
    
    