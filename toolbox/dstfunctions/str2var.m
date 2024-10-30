function var = str2var(varstr,type,format,iswarn)
%
%-------function help------------------------------------------------------
% NAME
%   str2var.m
% PURPOSE
%   Convert the input cell array of character vectors to an array of the 
%   specified data type and using the given format if datetime, or duration, 
% USAGE
%   var = str2var(varstr,type,format,iswarn)
% INPUT
%   varstr - character vector cell array of the variable. 
%   type   - data type of the variable
%   format - input format for datetime and duration data, or
%            çategories' flag 'to set categories for categorical data
%   iswarn - optional flag for warning message to be shown - default is true
% OUTPUT
%   var - array of variable of defined type and format
% NOTE
%   var2str does the reverse. Used in inputUI and dstable
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
    if nargin<2, iswarn = true; end
    
    if iscell(type)
        type = type{1};
    end
    
    ntypes = {'logical','int8','int16','int32','int64','uint8','uint16',... 
              'uint32','uint64','single','double'};
    if any(strcmp(ntypes,type))
        num_type = char(type);
        type = "numeric";
    end
    
    switch type
        case 'datetime'
            if ~isempty(format)
                var = datetime(varstr,'InputFormat',format);
                var.Format = format;
            else
                try
                    var = datetime(varstr);
                catch
                    format = getdateformat(varstr);
                    try
                        var = datetime(varstr,'InputFormat',format);
                    catch
                        warndlg('Unable to identify datetime format')
                    end
                end                    
            end
        case 'duration'
            %str2duration splits string if format not defined
            var = str2duration(varstr,format);
            var.Format = format;
        case 'calendarDuration'
            var = str2caldur(varstr);
        case 'char'
            var = varstr;
        case 'string'
            var = string(varstr);
        case 'logical'
            var = logical(str2double(varstr));    
        case 'numeric'
            var = str2double(varstr);
            var = cast(var,num_type);        
        case {'categorical','ordinal'}
            if nargin<3 || isempty(format) || strcmp(format,'categories')
                format = unique(varstr);
            end
            if ischar(varstr), varstr = {varstr}; end %handle single character vectors
            if strcmp(type,'categorical')
                var = categorical(varstr,format);
            else
                var = categorical(varstr,format,'Ordinal',true);
            end
        case 'unknown'
            var = varstr;
        otherwise
            if iswarn
                warndlg('Unknown data type in str2var')
            end
            var = [];
    end
end
