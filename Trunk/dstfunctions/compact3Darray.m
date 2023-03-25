function [compactarray,rows,cols] = compact3Darray(array,dim,tol)
%
%-------function help------------------------------------------------------
% NAME
%   compact3Darray.m
% PURPOSE
%   remove the rows and columns that are zeros in all 2D matrices of a 2 or
%   3D array and return the compacted array.
% USAGE
%   [compactarray,rows,cols] = compact3Darray(array);
%   Example generates a 10x10x5 array and returns a 4x6x4 array for dim=3
%   use [compactarray,rows,cols] = compact3Darray()
% INPUTS
%   array - 2 or 3D array with leading and trailing zeros to be removed
%   dim - pivot dimension: checks 2D matrices for each 2D array extracted
%         from this dimension
%   tol - tolerance to allow zeros or small values to be used as the mask
% OUTPUT
%   compactarray - 2 or 3D array with rows and columns that are all zeros,
%                  for all dimensions, removed
%   rows - start and end indices of rows extracted from array
%   cols - start and end indices of columns extracted from array
%
% Author: Ian Townend
% CoastalSEA (c) March 2023
%--------------------------------------------------------------------------
%
if nargin<1
    % Create a sample multidimensional array
    A = zeros(10,10);
    A(2:5,3:6) = magic(4);
    array = repmat(A,1,1,4);
    array(:,:,5) = zeros(10,10);
    array(7,4,3) = 7;
    dim = 3;
end

%abstract functions to find first and last non-zero row and column values
mycols = @(x) [find(any(x>tol,1),1,'first'),find(any(x>tol,1),1,'last')];
myrows =  @(x) [find(any(x>tol,2),1,'first'),find(any(x>tol,2),1,'last')];

dim3 = size(array,dim);
rowrange = zeros(dim3,2); colrange = rowrange;
for i=1:dim3
    switch dim
        case 1
            data = squeeze(array(i,:,:));
        case 2
            data = squeeze(array(:,i,:));
        case 3
            data = array(:,:,i);
    end
    if any(data>tol,'all')
        rowrange(i,:) = myrows(data);
        colrange(i,:) = mycols(data);
    else
       rowrange(i,:) = [NaN,NaN];
       colrange(i,:) = [NaN,NaN];
    end
end

rows = minmax(rowrange,'omitnan');  %returns a 1x2 vector of the min and max values
cols = minmax(colrange,'omitnan');  %of the array

switch dim
    case 1
        compactarray = array(:,rows(1):rows(2),cols(1):cols(2));
    case 2
        compactarray = array(rows(1):rows(2),:,cols(1):cols(2));
    case 3
        compactarray = array(rows(1):rows(2),cols(1):cols(2),:);
end