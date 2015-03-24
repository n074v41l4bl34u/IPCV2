function hybridIm = createHybrid(nearIm, farIm, d0)
%hybridIm takes two images and creates a hybrid image according to Oliva,
%Torralba, and Schyns (2006). A hybrid image is a combination of two
%images, where one can only be seen if viewed closely and one that can only
%be seen if viewed from a distance.
%
%Arguments:
%nearIm: image to be seen when viewed up close.
%farIm: image to be seen when viewed from a distance.
%d0 is the cutoff frequency in the gaussian filter
%
%Requires function D_UV
%Author: Andrew Smith
%Image Processing & Computer Vision II

nearIm = double(nearIm);
farIm = double(farIm);

%Get sizes
[nRows, nCols, nP] = size(nearIm);
[fRows, fCols, fP] = size(farIm);

%Force rows to same size
if nRows > fRows
    nearIm = imresize(nearIm, [fRows, nCols]);
else
    farIm = imresize(farIm, [nRows, fCols]);
end

%Recollect sizes
[nRows, nCols, nP] = size(nearIm);
[fRows, fCols, fP] = size(farIm);

%Force columns to same size
if nCols > fCols
    nearIm = imresize(nearIm, [nRows, fCols]);
else
    farIm = imresize(farIm, [fRows, nCols]);
end

%Recollect sizes
[nRows, nCols, nP] = size(nearIm);
[~, ~, fP] = size(farIm);

%Determine padding for Gaussian filter
pad = 2*[nRows nCols];
d0 = d0*pad(1);

%Compute D(U,V)
D = D_UV(pad(1),pad(2));

%Compute Gaussian filter
GAUSS = exp(-(D.^2)./(2*(d0^2)));

%Transform images to Fourier domain
NEARIM = fftn(nearIm, [size(GAUSS,1),size(GAUSS,2),nP]);
FARIM = fftn(farIm, [size(GAUSS,1),size(GAUSS,2),fP]);

%Repeat the filter in each plane, for easier multiplication
GAUSS(:,:,2) = GAUSS(:,:,1);
GAUSS(:,:,3) = GAUSS(:,:,1);

%Low-pass filter the far image and high-pass filter the near image, add the
%frequencies.
HYBRIDIM_LOW = FARIM .* GAUSS;
HYBRIDIM_HIGH = NEARIM .* (1-GAUSS);
HYBRIDIM = HYBRIDIM_LOW + HYBRIDIM_HIGH;

%Return to spatial domain
hybridIm = uint8(ifftn(HYBRIDIM));
hybridIm = hybridIm(1:nRows,1:nCols,:);


