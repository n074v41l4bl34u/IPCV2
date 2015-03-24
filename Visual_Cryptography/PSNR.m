function [peak_signal_to_noise_ratio] = PSNR(image1, image2)
%Computes the peak signal to noise ratio between two images.
%
%Input:  image1, image2: matrices of the same dimensions and class, can
%        be multiple planes.
%
%Output: peak_signal_to_noise_ratio: if the input images are 1-planed this
%        will be a scalar,  otherwise it is a vector with the same length 
%        as there are planes.
%
%Megan M. Iafrati
%02.14.14

%Guard Code----------------------------------------------------------------
[row1 col1 plane1] = size(image1);
[row2 col2 plane2] = size(image2);

image1_class = class(image1);
image2_class = class(image2);

if row1 ~= row2 || col1 ~= col2 || plane1 ~= plane2
    error('Image dimensions do not agree.');
elseif strcmpi(image1_class, image2_class)== 0
    error('Image classes do not agree.');
end

%Calculation---------------------------------------------------------------
mean_squared_error = MSE(image1,image2);
if plane1 == 1
    peak_signal_to_noise_ratio = 10*log10(...
        (double(intmax(image1_class))^2)/mean_squared_error);
else
    peak_signal_to_noise_ratio = zeros(1,plane1);
    for plane_index = 1:plane1
        peak_signal_to_noise_ratio(plane_index) = 10*log10(...
            (double(intmax(image1_class))^2)...
            /mean_squared_error(plane_index));
    end
end

end