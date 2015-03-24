function D = D_UV(M, N)
%DFTUV computes the ranges of U and V for use in
%computing frequency domain filters.
%
%Arguments:
%In most cases, M and N are the number of padded rows and columns used for
%creatingg frequency domain filters.
%
%Author: Andrew Smith
%Image Processing & Computer Vision II
%Adapted from:
%http://www.cs.uregina.ca/Links/class-info/425-nova/Lab5/M-Functions/dftuv.m

% Set up range of variables.
u = 0:(M-1);
v = 0:(N-1);

% Compute the indices for use in meshgrid
A = find(u > M/2);
u(A) = u(A) - M;
B = find(v > N/2);
v(B) = v(B) - N;

% Compute the ranges
[V, U] = meshgrid(v, u);

%Calculate D
D = sqrt(U.^2 + V.^2);