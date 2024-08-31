function outstruct = cellstruct2structarray(instruct)
%
%-------function help------------------------------------------------------
% NAME
%   cellstruct2structarray.m
% PURPOSE
%   convert a struct of cell arrays of the same dimension to a struct array
%   with a set of fields for each entry in the cell array
% USAGE
%   outstruct = cellarraystruct2structarray(inarray)
% INPUT
%   instruct - input struct of cell arrays or string arrays
% OUTPUT
%   outstruct - output struct array with dimensions of p x n, where p is
%   the number of fields in the struct, 1 x n are the dimensions of the 
%   cell array assigned to each struct field
% NOTES
%   if ANY struct field is a string array (rather than a cell array) then . 
%   use converStringstoChars(string array) to get back to a cell array
% SEE ALSO
%   see test_utilfunctions.m for examples of usage and cellstruct2cell.m
% 
% Author: Ian Townend
% CoastalSEA (c)Sept 2020
%--------------------------------------------------------------------------
%
    fnames = fieldnames(instruct);
    %convert struct of cell arrays to a cell array
    outcell = cellstruct2cell(instruct);   %returns a p x n cell array
    %if mix of string array and cell array, a string array is returned
    if ~isempty(outcell)
        outcell = convertStringsToChars(outcell);   %convert to cell array
        %convert to n x 1 struct array
        dim = 1;
        ndim = size(outcell,dim);
        if ndim==length(fnames)
            outstruct = cell2struct(outcell,fnames,1)';
        else
            warndlg('Number of rows in cell array does not match number of fields');
        end
    end
end