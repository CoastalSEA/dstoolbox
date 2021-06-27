function [vdim,cdim,vsze] = getvariabledimensions(intable,variable)
%
%-------function help------------------------------------------------------
% NAME
%   getvariabledimensions.m
% PURPOSE
%   find total number of dimensions for a variable in a table or dstable
% USAGE
%   [vdim,cdim,vsze] = getvariabledimensions(intable,variable)
% INPUT
%   intable - table or dstable
%   variable - variable name (char vector, sting, numeric or logical index)
% OUTPUT
%   vdim - total number of dimensions for variable
%   cdim - number of dimensions for the first cell of table (excludes row and single dimension)
%   vsze - size of variable (rows,dim1,dim2, ...dimN)
% NOTES
%   gets number of dimensions where 1x1 array is regarded as a point value
%   and hence 0-dimensional, a vector is 1-d, a matrix 2-d, etc
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2020
%--------------------------------------------------------------------------
%
    if isa(intable,'dstable')
        intable = intable.DataTable;
    end
    rdim = height(intable);               %number of rows
    samplevar = intable{1,variable};
    vsze = size(samplevar);               %size of cell
    cdim = sum(vsze>1);                   %dimensions of first cell
    vdim = double(rdim>1)+cdim;           %number of dimensions
    vsze(1) = rdim;                       %add in row size
end