function caldurvar = num2caldur(num,units)
%
%-------function help------------------------------------------------------
% NAME
%   num2caldur.m
% PURPOSE
%   convert a number to a calendar duration based on specified units
% USAGE
%   caldurvar = num2caldur(strvar,units)
% INPUT
%   num - numeric value of a calendar duration
%   units - format of calendar duration as a character vector
% OUTPUT
%   caldurvar - variable returned as calendar duration in defined units.
% SEE ALSO
%   used in
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    switch units
        case {'s','sec','secs','seconds'}
            caldurvar = seconds(num);
        case {'m','min','mins','minutes'}
            caldurvar = minutes(num);
        case {'h','hr','hour','hours'}
            caldurvar = hours(num);
        case {'d','day','days'}
            caldurvar = caldays(num);
        case {'w','week','weeks'}
            caldurvar = calweeks(num);
        case {'m','mo','month','months'}
            caldurvar = calmonths(num);
        case {'q','quarter','quarters'}
            caldurvar = calquarters(num);
        case {'y','yr','yrs','year','years'}
            caldurvar = calyears(num); 
        otherwise
            caldurvar = [];
            warndlg('Only days, weeks, months, quarters and years handled')
    end
end