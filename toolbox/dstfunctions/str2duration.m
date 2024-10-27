function durvar = str2duration(strvar,format)
%
%-------function help------------------------------------------------------
% NAME
%   str2duration.m
% PURPOSE
%   convert a string created from a duration back to a duration
% USAGE
%   durvar = str2duration(strvar,format)
% INPUT
%   strvar - text string of a duration (can include units)
%   format - format of duration (required if no units in strvar)
% OUTPUT
%   durvar - variable returned as a duration in defined duration units
%            if no duration format, returns durvar as numeric value or empty
% SEE ALSO
%   used in checkValidRange.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    try    
        durvar = duration(strvar,'InputFormat',format);
    catch  
        try
            %split string, handle charachter vector, cell array and strings
            [num,fmt] = splitString(strvar);
            if isnan(num), durvar = []; return; end
            %
            if nargin<2 && ~isempty(fmt)
                format = fmt;
            elseif nargin<2
                format = [];
            end
            %
            if isempty(format)        %unable to resolve duration format
                if isempty(num) || isnan(num)
                    durvar = [];      %not a numeric value
                else
                    durvar = num;     %numeric value
                end
                return;            
            end
            %
            durvar = num2duration(num,format);
        catch
            durvar = [];
        end
    end
end  
%%
function [num,format] = splitString(strvar)
    %handle splitting of character vector, cell array, or string vector
    C = regexp(strip(strvar),'\s+','split');
    if ischar(strvar) || (isstring(strvar) && length(strvar)==1)
        %character vector or string scalar                           
        num = str2double(C{1});
    else   %cell array or string vector
        num = cell2mat(cellfun(@(x) str2double(x{1}),C,'UniformOutput',0));
        C = C{1};
    end
    %
    if length(C)<2
        format = [];
    else
        format = C{2};   
    end
    
    %trap none duration character vectors or strings
    durtypes = {'s','sec','secs','m','min','mins','h','hr','hrs',...
                'd','day','days','y','yr','yrs'};
    if ~isempty(format) && ~any(strcmp(durtypes,format))
        num = NaN; format = [];
    end
end