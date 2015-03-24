function result = calcNC(image1, image2)
%Calculates the noise correlation between the two images images must have
%matching dimensions. 
%Adapted from SIMILARITY_NC, IDL code by Carl Salvaggio
%Adapted for MATLAB by Andrew Smith on 3/2/14

%Check sizes
if size(image1) ~= size(image2)
    error('Image dimensions must match');
end

%Calculate noise correlation
result = sum(sum(double(image1) .* double(image2))) / sum(sum(double(image1.^2)));