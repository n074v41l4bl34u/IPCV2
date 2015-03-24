function mask = createSeamMasks(im)
%createSeamMasks is for use with contentAwareResize to specify regions to
%either eliminate or save regions when adjusting size with seams.

%First, prompt user to select area to save
mask1 = zeros(size(im(:,:,1)));
n = 1;
p1 = questdlg('Would you like to specify a region to preserve?','Yes','No');
if strcmpi(p1, 'Yes')
    while n == 1
        figure,imshow(im);
        roi = imfreehand(gca);
        %Build mask from input
        mask1 = mask1+roi.createMask();
        close
        %Just in case they want to save more area, prompt again
        p2 = questdlg('Select another region?','Yes','No');
        if strcmpi(p2,'Yes')
            n = 1;
        else
            n = 0;
        end
    end
end
%Correct for overlapping regions
mask1(mask1>0) = 1;

%Prompt user to select areas they would like to remove
mask2 = zeros(size(im(:,:,1)));
n = 1;
p1 = questdlg('Would you like to specify a region to be more likely to be removed?','Yes','No');
if strcmpi(p1, 'Yes')
    while n == 1
        figure,imshow(im);
        roi = imfreehand(gca);
        %Build mask from input
        mask2 = mask2+roi.createMask();
        close
        %Just in case there are multiple points, prompt again
        p2 = questdlg('Select another region?','Yes','No');
        if strcmpi(p2,'Yes')
            n = 1;
        else
            n = 0;
        end
    end
end
%Correct for overlapping regions
mask2(mask2>0) = -1;

%Add the two masks together. Regions that overlap will be set to zero.
mask = mask1 + mask2;

end
