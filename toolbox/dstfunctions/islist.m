function islst = islist(var,option)
%
%-------function help------------------------------------------------------
% NAME
%   islist.m
% PURPOSE
%   To test whether a variable is some form of text data. Input option allows 
%   different combinations of character data types to be tested. If option is not included
%   the function tests for cellstr, or string, or categorical, or char array
% USAGE
%   islst = islist(var,option)
% INPUTS
%   var - variable to test
%   option - selection of text types to test (optional, default = 1) 
%            The combinations included are as follows:
%            1 - cellstr, string, categorical, char (NxM) array ie a list
%            2 - cellstr, string
%            3 - cellstr, string, categorical,
%            4 - cellstr, string, categorical, char
%            5 - cellstr, string, char
%            6 - cellstr, string, char (NxM) array ie a list
% OUTPUT
%   islst - true if var is a list of selected types
% SEE ALSO
%   muiDataUI.m and muiSelectUI.m
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024 
%--------------------------------------------------------------------------
% 
    if nargin<2
        option = 1;
    end

    switch option
        case 1 
            islst = iscellstr(var) || isstring(var) || iscategorical(var) ||...
                    (ischar(var) && size(var,1)>1);                           
        case 2
            islst = iscellstr(var) || isstring(var);
        case 3
            islst = iscellstr(var) || isstring(var) || iscategorical(var);
        case 4
            islst = iscellstr(var) || isstring(var) || iscategorical(var) ||...
                    ischar(var); 
        case 5 
            islst = iscellstr(var) || isstring(var) || ischar(var); 
        case 6
            islst = iscellstr(var) || isstring(var) || (ischar(var) && size(var,1)>1);                     
        otherwise
            warndlg('Unknown selection option in islist')
            islst = false;
    end
end