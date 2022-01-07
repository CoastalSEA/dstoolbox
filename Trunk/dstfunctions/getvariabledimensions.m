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
%   vdim includes the row as a dimension when the table has a single row
%   and there is a value in RowNames. It also includes dimensions in a 
%   dstable that are defined and single valued (in a table these are
%   excluded because the dimension is not >1 and there is no infomration 
%   about variable dimensions).
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2020
%--------------------------------------------------------------------------
%
    if isa(intable,'dstable')
        if ~isempty(intable.Dimensions)
            isunitdim = structfun(@length,intable.Dimensions)==1; 
        else
            isunitdim = false;
        end
        intable = intable.DataTable;               
    else
        isunitdim = false;
    end
    rdim = height(intable);               %number of rows
    samplevar = intable{1,variable};      %data in first cell of variable
    vsze = size(samplevar);               %size of cell
    cdim = sum(vsze>1);                   %dimensions of first cell
    vdim = double(rdim>1)+cdim;           %number of dimensions
    if rdim==1 && ~isempty(intable.Properties.RowNames)
        %correct for single row, which is defined as a dimension (ie has a value)
        vdim = vdim+1;       
    end    
    %
    if any(isunitdim)
        %correct for a dimension that is defined but is single valued (only
        %applies to data in a dstable which includes dimensions).
        vdim = vdim+sum(isunitdim);
    end
    vsze(1) = rdim;                       %add in row size
end