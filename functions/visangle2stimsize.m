% Provides x,y size in pixels to produce a given size in visual angle. 
% Use: [sizex,sizey] = visangle2stimsize(visanglex,[visangley],[totdistmm],[screenwidthmm],[screenres])
 
function [sizex,sizey] = visangle2stimsize(visanglex,visangley,totdist,screenwidth,screenres)

if nargin < 3
    % mm
    distscreenmirror=823;
  	distmirroreyes=90;
 	totdist=distscreenmirror+distmirroreyes;
  	screenwidth=268;
  
  	% pixels
  	screenres=1024;
end
 
visang_rad = 2 * atan(screenwidth/2/totdist);
visang_deg = visang_rad * (180/pi);
 
pix_pervisang = screenres / visang_deg;
fprintf("VISUAL ANGLE CALCULATION.\n"); 
fprintf("Number of pixels per degree of visual angle: %d\n\n\n", pix_pervisang);
 
sizex = round(visanglex * pix_pervisang);
 
if nargin > 1
 	sizey = round(visangley * pix_pervisang);
end