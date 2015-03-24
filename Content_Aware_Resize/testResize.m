tennant = imread('david.jpg');
lenna = imread('lenna.tif');
bird = imread('bird.jpg');
xp = imread('xp.jpg');
falls = imread('fallsSmall.jpg');
%%
%Let's carve some seams!!
newFallsSize1 = [270 420];
resizedFalls1 = contentAwareResize(falls, newFallsSize1,'yes');
imwrite(resizedFalls1, 'resizedFalls1.jpg');

%%
newBirdSize = [160 235];
resizedBird = contentAwareResize(bird, newBirdSize);
imwrite(resizedBird, 'resizedBird.jpg');
%resizedBird2 = contentAwareResize(bird, newBirdSize);
%imwrite(resizedBird2, 'resizedBird2.jpg');

%%
newTennantSize2 = [340 450];
resizedTennant2 = contentAwareResize(tennant, newTennantSize2,'yes');
imwrite(resizedTennant2, 'resizedTennant2.jpg');

resizedFalls2 = contentAwareResize(falls, newFallsSize1);
imwrite(resizedFalls2, 'resizedFalls2.jpg');

newLennaSize = [230 200];
resizedLenna = contentAwareResize(lenna, newLennaSize);
imwrite(resizedLenna, 'resizedLenna.jpg');


newTennantSize1 = [384 450];
resizedTennant1 = contentAwareResize(tennant, newTennantSize1);
imwrite(resizedTennant1, 'resizedTennant1.jpg');


newXPSize = [100 200];
resizedXP = contentAwareResize(xp, newXPSize);
imwrite(resizedXP, 'resizedXP.jpg');

%%
newTennantSize3 = [340 450];
resizedTennant3 = contentAwareResize(tennant, newTennantSize3);
imwrite(resizedTennant3, 'resizedTennant3.jpg');





