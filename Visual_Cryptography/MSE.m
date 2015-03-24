function [mean_squared_error] = MSE(image1, image2)
%Computes the mean squared error between two images.
%
%Input:  image1, image2: matrices of the same dimensions and class, can
%        be multiple planes.
%
%Output: mean_squared_error: if the input images are 1-planed this will be
%        a scalar,  otherwise it is a vector with the same length as there 
%        are planes.
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
if plane1 == 1
    mean_squared_error = (sum((double(image1(:))-double(image2(:))).^2))...
        /numel(image1);
else
    mean_squared_error = zeros(1,plane1);
    for plane_index = 1: plane1
        mean_squared_error(plane_index) = (sum(sum(...
            (double(image1(:,:,plane_index))...
            -double(image2(:,:,plane_index))).^2)))/(row1*col1);
    end
end

end