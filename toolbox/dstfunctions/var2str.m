function [varstr,type,format] = var2str(var,iswarn)
%
%-------function help------------------------------------------------------
% NAME
%   var2str.m
% PURPOSE
%   Convert the input variable to a cell array of strings and return the 
%   data type and format (for datetime, duration and CalendarDuration only)    
% USAGE
%   [varstr,type,format] = var2str(var,iswarn)
% INPUT
%   var - input variable to be tested - can be single value, or array of
%         same data type
%   iswarn - optional flag for warning message to be shown - default is true
% OUTPUT
%   varstr - cell array of the variable as a character vector. 
%            returns empty cell if type not found
%   type   - data type of the variable
%   format - input format for datetime and duration data
% NOTE
%   str2var does the reverse. Used in inputUI and dstable
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
    if nargin<2, iswarn = true; end
    
    format = [];
    if isempty(var)
        varstr = {''}; type = []; format = [];
        return;
    elseif iscell(var)
        var1 = var{1};
        if ischar(var1)
            var1 = var(1);
        end
    else
        var1 = var(1);
    end
    type = getdatatype(var1); 
    
    if isnumeric(var) || islogical(var)
        varstr = cellstr(num2str(var));
    elseif isdatetime(var) || isduration(var)
        varstr = cellstr(var);
        format = var.Format;     
    elseif iscalendarduration(var)
        varstr = cellstr(var);     %calendarDuration format is some of 'yqmwdt'
        format = var.Format;
    elseif iscategorical(var)
        varstr = cellstr(var);     %returns categoric as cell array of character vectors
        format = 'categories';     %used to restore categorical in str2var    
    else
        try
            varstr = cellstr(var); %returns strings as cell array of character vectors
            if isempty(type)
                type = 'unknown';
            end
        catch
            if iswarn
                warndlg('Unknown data type in var2str')
            end
            varstr = {};
        end
    end
end