function imageOut = li_demosaic(image,orientation)
%li_demosaic takes in a raw TIFF with no interpolation, and demosaicks it
%according to Randhawa and Li.
%("Color Filter Array Demosaicking Using High-Order Interpolation Techniques
%With a Weighted Median Filter for Sharp Color Edge Preservation," 2009).
%
%Inputs: 'image', a single band bayer image, and 'orientation', the
%orientation of the Bayer pattern.
%Possible orientations:
%1:[G B   2:[G R   3:[B G   4:[R G
%   R G]     B G]     G R]     G B]
%Output: 3-band full-color image array.
%
%Written by: Andrew Smith
%Image Processing and Computer Vision II

%Pad array with repeated border
im = double(padarray(image, [4,4], 'replicate'));
[rows cols] = size(im);

%Preallocate
imageOut = zeros(rows,cols,3);
redLocations = zeros(rows, cols);
blueLocations = zeros(rows, cols);
greenLocations = zeros(rows, cols);

%Determine locations of the colors
switch orientation
    case 1
        %[G B
        % R G]
        redLocations(2:2:end,1:2:end) = 1;
        blueLocations(1:2:end,2:2:end) = 1;
        greenLocations(1:2:end,1:2:end) = 1;
        greenLocations(2:2:end,2:2:end) = 1;
    case 2
        %[G R
        % B G]
        redLocations(1:2:end,2:2:end) = 1;
        blueLocations(2:2:end,1:2:end) = 1;
        greenLocations(1:2:end,1:2:end) = 1;
        greenLocations(2:2:end,2:2:end) = 1;
    case 3
        %[B G
        % G R]
        redLocations(2:2:end,2:2:end) = 1;
        blueLocations(1:2:end,1:2:end) = 1;
        greenLocations(2:2:end,1:2:end) = 1;
        greenLocations(1:2:end,2:2:end) = 1;
    case 4
        %[B G
        % G R]
        redLocations(1:2:end,1:2:end) = 1;
        blueLocations(2:2:end,2:2:end) = 1;
        greenLocations(2:2:end,1:2:end) = 1;
        greenLocations(1:2:end,2:2:end) = 1;
    otherwise
        error('ErrorTests:convertTest','The allowed orientations are:\n 1:[G B   2:[G R   3:[B G   4:[R G\n    R G]     B G]     G R]     G B]');
end

%--------------------------------------------------------------------------
%Calculate possible Green values throughout the image interpolated in each
%direction:
topStorage1 = circshift(im,[-1 0]) + 0.75*(im-circshift(im,[-2 0])) - ... 
    0.25*(circshift(im,[-1 0]) - circshift(im,[-3 0]));
leftStorage1 = circshift(im,[0 -1]) + 0.75*(im-circshift(im,[0 -2])) - ... 
    0.25*(circshift(im,[0 -1]) - circshift(im,[0 -3]));
rightStorage1 = circshift(im,[0 1]) + 0.75*(im-circshift(im,[0 2])) - ...
    0.25*(circshift(im,[0 1]) - circshift(im,[0 3]));
bottomStorage1 = circshift(im,[1 0]) + 0.75*(im-circshift(im,[2 0])) - ...
    0.25*(circshift(im,[1 0]) - circshift(im,[3 0]));

%Compute vertical and horizaontal gradients used for estimating green at red/blue pixels
vGatRB = abs(circshift(im,[-1 0]) - circshift(im,[1 0]));
hGatRB = abs(circshift(im,[0 1]) - circshift(im,[0 -1]));
orientationGatRB = zeros(size(im));
orientationGatRB(vGatRB < hGatRB) = 1;

%Calculate Green values at red and blue locations by taking a weighted 
%median based on orientation:
greenPlane = zeros(size(im));

greenPlane(orientationGatRB == 1) = median([leftStorage1(orientationGatRB == 1) ... 
    rightStorage1(orientationGatRB == 1) topStorage1(orientationGatRB == 1) ...
    topStorage1(orientationGatRB == 1) bottomStorage1(orientationGatRB == 1) ...
    bottomStorage1(orientationGatRB == 1)],2);

greenPlane(orientationGatRB == 0) = median([leftStorage1(orientationGatRB == 0) ... 
    leftStorage1(orientationGatRB == 0) rightStorage1(orientationGatRB == 0) ...
    rightStorage1(orientationGatRB == 0) topStorage1(orientationGatRB == 0) ...
    bottomStorage1(orientationGatRB == 0)],2);
greenPlane(greenLocations == 1) = im(greenLocations == 1);

imageOut(:,:,2) = greenPlane;
%--------------------------------------------------------------------------
%Compute gradients used for estimating red/blue aat blue/red pixels. This
%actually uses diagonal gradients.
vRBatBR = abs(circshift(im,[-1 -1]) - circshift(im,[1 1]));
hRBatBR = abs(circshift(im,[-1 1]) - circshift(im,[1 -1]));
orientationRBatBR = zeros(size(im));
orientationRBatBR(vRBatBR < hRBatBR) = 1;

%Calculate possible Red/Blue values at Blue/Red locations by interpolating
%in each direction:
topStorage2 = circshift(im,[-1 -1]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[-1 -1]));
leftStorage2 = circshift(im,[-1 1]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[-1 1]));
rightStorage2 = circshift(im,[1 -1]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[1 -1]));
bottomStorage2 = circshift(im,[1 1]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[1 1]));

%Calculate Red values at Blue locations by taking a weighted median based
%on orientation:
redPlane = zeros(size(im));

redPlane(orientationRBatBR == 1) = median([leftStorage2(orientationRBatBR == 1) ... 
    rightStorage2(orientationRBatBR == 1) topStorage2(orientationRBatBR == 1) ...
    topStorage2(orientationRBatBR == 1) bottomStorage2(orientationRBatBR == 1) ...
    bottomStorage2(orientationRBatBR == 1)],2);

redPlane(orientationRBatBR == 0) = median([leftStorage2(orientationRBatBR == 0) ... 
    leftStorage2(orientationRBatBR == 0) rightStorage2(orientationRBatBR == 0) ...
    rightStorage2(orientationRBatBR == 0) topStorage2(orientationRBatBR == 0) ...
    bottomStorage2(orientationRBatBR == 0)],2);

%This plane actually includes Blue values at Red locations as well
bluePlane = zeros(size(im));
redPlane(greenLocations == 1) = 0; %Red and Blue values at Green locations calculated later
bluePlane(redLocations == 1) = redPlane(redLocations == 1);
bluePlane(blueLocations == 1) = im(blueLocations == 1);

%Reset original Red values at Red locations
redPlane(redLocations == 1) = im(redLocations == 1);
%--------------------------------------------------------------------------
%Last thing to do is calculate Red and Blue values at Green locations
%Red at Green:
topStorage3 = circshift(redPlane,[-1 0]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[-1 0]));
leftStorage3 = circshift(redPlane,[0 -1]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[0 -1]));
rightStorage3 = circshift(redPlane,[0 1]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[0 1]));
bottomStorage3 = circshift(redPlane,[1 0]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[1 0]));

%Compute gradients used for estimating red/blue at green pixels. 
vRBatG = abs(circshift(redPlane,[-1 -1]) - circshift(redPlane,[1 1]));
hRBatG = abs(circshift(bluePlane,[-1 1]) - circshift(bluePlane,[1 -1]));
orientationRBatG = zeros(size(im));
orientationRBatG(vRBatG < hRBatG) = 1;

%Calculate Red values at Green locations by taking a weighted 
%median based on orientation:
tempPlane(orientationRBatG == 1) = median([leftStorage3(orientationRBatG == 1) ... 
    rightStorage3(orientationRBatG == 1) topStorage3(orientationRBatG == 1) ...
    topStorage3(orientationRBatG == 1) bottomStorage3(orientationRBatG == 1) ...
    bottomStorage3(orientationRBatG == 1)],2);

tempPlane(orientationRBatG == 0) = median([leftStorage3(orientationRBatG == 0) ... 
    leftStorage3(orientationRBatG == 0) rightStorage3(orientationRBatG == 0) ...
    rightStorage3(orientationRBatG == 0) topStorage3(orientationRBatG == 0) ...
    bottomStorage3(orientationRBatG == 0)],2);

redPlane(greenLocations == 1) = tempPlane(greenLocations == 1);

%--------------------------------------------------------------------------
%Blue at Green
topStorage4 = circshift(bluePlane,[-1 0]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[-1 0]));
leftStorage4 = circshift(bluePlane,[0 -1]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[0 -1]));
rightStorage4 = circshift(bluePlane,[0 1]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[0 1]));
bottomStorage4 = circshift(bluePlane,[1 0]) + (imageOut(:,:,2) - circshift(imageOut(:,:,2),[1 0]));

vBatG = abs(circshift(bluePlane,[-1 -1]) - circshift(bluePlane,[1 1]));
hBatG = abs(circshift(redPlane,[-1 1]) - circshift(redPlane,[1 -1]));
orientationBatG = zeros(size(im));
orientationBatG(vBatG < hBatG) = 1;

%Calculate Blue values at Green locations by taking a weighted 
%median based on orientation:
tempPlane2(orientationBatG == 1) = median([leftStorage4(orientationBatG == 1) ... 
    rightStorage4(orientationBatG == 1) topStorage4(orientationBatG == 1) ...
    topStorage4(orientationBatG == 1) bottomStorage4(orientationBatG == 1) ...
    bottomStorage4(orientationBatG == 1)],2);

tempPlane2(orientationBatG == 0) = median([leftStorage4(orientationBatG == 0) ... 
    leftStorage4(orientationBatG == 0) rightStorage4(orientationBatG == 0) ...
    rightStorage4(orientationBatG == 0) topStorage4(orientationBatG == 0) ...
    bottomStorage4(orientationBatG == 0)],2);

bluePlane(greenLocations == 1) = tempPlane2(greenLocations == 1);

%--------------------------------------------------------------------------
imageOut(:,:,1) = redPlane;
%GreenPlane already set 
imageOut(:,:,3) = bluePlane;

%Clip off of the padded borders
imageOut = uint8(imageOut(5:rows-4,5:cols-4,:));

end