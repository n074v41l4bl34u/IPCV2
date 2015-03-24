function [ resizedIm ] = contentAwareResize( image, newSize, varargin )
%contentAwareResize intelligently resizes image to the dimensions newSize.
%Inputs:
%newSize should be a two-dimensional vector [rows columns]
%image can be an RGB or grayscale image
%varargin: if a third input (can be anything) is passed into the function,
%the user will be able to select ROI's to save or remove by seam carving.
%
%Outputs:
%resizedIm, an intelligently resized version of the input image of
%dimensions newSize
%
%Author: Andrew Smith
%Image Processing and Computer Vision II
%Last Edited: 4/21/14
%%

%Make sure newSize is proper dimensions, otherwise everything will be
%messed up.
if size(newSize) ~= [1 2]
    error('Must specify new size in vector format: [rows columns]')
end

if nargin > 3
    error('Only three inputs are allowed: the image, the new size, and whether or not you want to save ROIs');
end

%Collect information about the image
type = class(image);
resizedIm = image;
[r, c, p] = size(image);
if newSize(1) > r || newSize(2) > c
    error('As of right now, this function can only shrink images.');
end

%Convert to grayscale for energy function computation if necessary
if p > 1
    image = rgb2gray(image);
end

%Compute energy function
image = double(image);
hGrad = conv2(image, [-1, -2, -1; 0, 0, 0; 1, 2, 1], 'same');
vGrad = conv2(image, [-1, 0, 1; -2, 0, 2; -1, 0, 1], 'same');
energy = abs(hGrad) + abs(vGrad);

%Mask if desired
if nargin == 3;
    mask = createSeamMasks(resizedIm);
    energy(mask == 1) = max(energy(:));
    energy(mask == -1) = 0;    
end


%% Intelligently reduce rows
while newSize(1) < r
    
    %Preallocate seam sizes
    currentSeam = zeros([1, c]);
    seams = zeros([r,c]);
    
    %Loop through the (r-newSize) lowest energy seams. 
    for numSeam = 1:r
        
        %Find the starting point
        [~,ind] = min(energy(:,1));
        [currentSpotR, currentSpotC] = ind2sub(size(energy),ind);
        currentSeam(1) = ind;
        
        %Spread from this starting point
        for idx = 2:c
            
            %Matrix of INFs is used to find the location of the minimum of
            %the spread
            temp = inf(size(energy));
            
            %try/catch tree used to check edge of image
            try
                %This will set only the 3 values you're checking to the
                %value of the energy function. Every other value in the
                %matrix is infinity, letting you find the coordinates of
                %the minimum of these three easily.
                temp(currentSpotR-1:currentSpotR+1, currentSpotC+1) = energy(currentSpotR-1:currentSpotR+1, currentSpotC+1);
                [~,currentSeam(idx)] = min(temp(:));
                
            catch
                %Same method as before, but code only goes to these statements
                %if at an edge of the image, thereby only checking 2 values
                %instead of 3.
                if (currentSpotR-1) == 0
                    temp(currentSpotR:currentSpotR+1,currentSpotC+1) = energy(currentSpotR:currentSpotR+1,currentSpotC+1);
                    [~,currentSeam(idx)] = min(temp(:));
                elseif (currentSpotR+1) == r+1
                    temp(currentSpotR-1:currentSpotR,currentSpotC+1) = energy(currentSpotR-1:currentSpotR,currentSpotC+1);
                    [~,currentSeam(idx)] = min(temp(:));
                end
            end
            
            %Make your next starting point the current seam
            [currentSpotR, currentSpotC] = ind2sub(size(energy),currentSeam(idx));
        end
        
        %Collect the seam
        seams(numSeam,:) = currentSeam;
    end
    
    %Sum the energy of the seams - the seam with the least total energy is
    %the one to remove.
    energySums = sum(energy(seams),2);
    [~,minSeamNumber] = min(energySums);
    minSeam = seams(minSeamNumber, :);
    
    %Remove the seam from both the energy function and the final image.
    energy(minSeam) = [];
    if p > 1
        for x = 1:3
            resizedIm(minSeam) = [];
            minSeam = minSeam + numel(energy);
        end
    else
        resizedIm(minSeam) = [];
    end
    
    %Deleting pixels in this manner turns the image into a long vector -
    %reshape back to the proper size. 
    energy = reshape(energy, r-1, c);
    resizedIm = reshape(resizedIm,r-1, c, p);
    
    %Check size to see if right dimensions yet. If the final image has the
    %right amount of rows, the loop will stop.
    [r, c, p] = size(resizedIm);
end

%% Intelligently reduce columns

%The code for columns is almost exactly identical if we simply rotate the
%image and energy function.
resizedIm = imrotate(resizedIm, 90);
energy = imrotate(energy, 90);
[r, c, p] = size(resizedIm);

%Only difference is we're checking newSize(2): the columns.
while newSize(2) < r
    currentSeam = zeros([1, c]);
    seams = zeros([r,c]);
    for numSeam = 1:r
        [~,ind] = min(energy(:,1));
        [currentSpotR, currentSpotC] = ind2sub(size(energy),ind);
        currentSeam(1) = ind;
        for idx = 2:c
            temp = inf(size(energy));
            try
                temp(currentSpotR-1:currentSpotR+1, currentSpotC+1) = energy(currentSpotR-1:currentSpotR+1, currentSpotC+1);
                [~,currentSeam(idx)] = min(temp(:));
            catch
                if (currentSpotR-1) == 0
                    temp(currentSpotR:currentSpotR+1,currentSpotC+1) = energy(currentSpotR:currentSpotR+1,currentSpotC+1);
                    [~,currentSeam(idx)] = min(temp(:));
                elseif (currentSpotR+1) == r+1
                    temp(currentSpotR-1:currentSpotR,currentSpotC+1) = energy(currentSpotR-1:currentSpotR,currentSpotC+1);
                    [~,currentSeam(idx)] = min(temp(:));
                end
            end
            [currentSpotR, currentSpotC] = ind2sub(size(energy),currentSeam(idx));
        end
        seams(numSeam,:) = currentSeam;
    end
    energySums = sum(energy(seams),2);
    [~,minSeamNumber] = min(energySums);
    minSeam = seams(minSeamNumber, :);
    
    %Reshape columns of final image
    energy(minSeam) = [];
    if p > 1
        for x = 1:3
            resizedIm(minSeam) = [];
            minSeam = minSeam + numel(energy);
        end
    else
        resizedIm(minSeam) = [];
    end
    energy = reshape(energy, r-1, c);
    resizedIm = reshape(resizedIm,r-1, c, p);
    [r, c, p] = size(resizedIm);
end

%% Return final image
resizedIm = imrotate(resizedIm, -90);
inClass = str2func(type);
resizedIm = inClass(resizedIm);

end %function

