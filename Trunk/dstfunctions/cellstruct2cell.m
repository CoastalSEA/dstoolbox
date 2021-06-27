function outcell = cellstruct2cell(instruct)
%
%-------function help------------------------------------------------------
% NAME
%   cellstruct2cell.m
% PURPOSE
%   convert a struct of cell arrays of the same dimension, to a cell array
%   with fields as the rows and cell entries as the columns
% USAGE
%   outcell = cellarraystruct2cellarray(instruct)
% INPUT
%   instruct - input struct of cell arrays, string arrays, or a struct array
% OUTPUT
%   outcell - output cell array with dimensions of p x n, where p is
%   the number of fields in the struct, 1 x n are the dimensions of the 
%   cell array assigned to each struct field, or the struct array
% NOTES
%   if ANY struct field is a string array (rather than a cell array) then 
%   the function returns a p x n string array. 
%   use converStringstoChars(string array) to get back to a cell array
%   To go the other way, use cell2struct(outcell,fieldnames,dim) - dim=1.
% SEE ALSO
%   see test_utilfunctions.m for examples of usage
% 
% Author: Ian Townend
% CoastalSEA (c)Sept 2020
%--------------------------------------------------------------------------
%
    outcell = {};
    [m,n] = size(instruct);    
    fnames = fieldnames(instruct);
    p = length(fnames);
    tempcell = struct2cell(instruct); %creates a {p,m,n} cell array
    %find the size of the larges cell array in any of the struct fields
    %trap single cell or string array struct from converting to char vector
    strname = instruct.(fnames{1});
    if n==1 && (iscell(strname) || isstring(strname))
        for i=1:p
            m = max(m,size(instruct.(fnames{i}),1));
            n = max(n,size(instruct.(fnames{i}),2));
        end
%         [m,n] = size(tempcell{1});
        if (n>1 && m==1)
            tempcell = [ tempcell{:} ];   %unpack cell array to {1,(pxmxn)}
        elseif (n==1 && m>1)
            n = m; m = 1;
            tempcell = [ tempcell{:} ];   %unpack cell array to {1,(pxmxn)}
        end
    end
    %
    if m>1    
        warndlg('cellstruct2cell only handles {1,n} cell arrays')
        return; 
    elseif p*n~=numel(tempcell)
        warndlg('struct cell array has missing values in cellstruct2cell')
        return;
    end
    outcell = reshape(tempcell,n,p)';
end