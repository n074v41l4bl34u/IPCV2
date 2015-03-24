%Name: Andrew Smith
%Project 2: Threshold Selection w/ Otsu's Method
%Submitted: 20 March 2013

function [threshold, thresholdedImage] = otsu_threshold(image, varargin)
%otsu_threshold Calculates the appropriate threshold of a grayscale image
%to convert to a binary bw image. 
%Function calls:
%To return only the threshold:
%[ threshold ] = otsu_threshold( image ) 
%
%To return the threshold and a plot of the histogram showing the threshold:
%[ threshold ] = otsu_threshold( image, 'verbose' )
%
%To return the threshold and thresholded image:
%[ threshold, thresholdedImage ] = otsu_threshold( image )
%
%To return the threshold, thresholded image, and a plot of the histogram showing the threshold:
%[ threshold, thresholdedImage ] = otsu_threshold( image, 'verbose' )


%First, make sure the image is grayscale
[r, c, p] = size(image);
if p > 1
    error('Image must be grayscale');
end

%Preallocate necessary arrays:
varB = zeros(256,1);
thresholdedImage = uint8(zeros(size(image)));

%Compute histogram of image:
histo = imhist(image);

%Convert to PDF:
probDF = histo/sum(histo);

%Find the mean of the whole PDF:
mT = 0;
for mTidx = 1:256
    mT = mT + (mTidx * probDF(mTidx));
end

%Calculate the between-class variance:
mK = 0;
wK = 0;
for varBidx = 1:256
    mK = mK + (varBidx * probDF(varBidx));
    wK = wK + probDF(varBidx);
    varB(varBidx) = (((mT * wK) - mK)^2) / (wK * (1 - wK));
end

%The ideal threshold for the image is the location of maximum variance
[~, threshold] = max(varB);

%Create thresholded image:
for rIdx = 1:r
    for cIdx = 1:c
        if image(rIdx,cIdx) < threshold
            thresholdedImage(rIdx,cIdx) = 0;
        else
            thresholdedImage(rIdx,cIdx) = 255;
        end
    end
end

%Plot the histogram with a vertical red line at the threshold if 'verbose'
%specified:
if strcmpi(varargin,'verbose')
    x = [threshold, threshold];
    y = [0, max(histo)];
   plot(histo);
   hold on;
   plot(x,y, 'r');
end

end


