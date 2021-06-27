function durvar = num2duration(num,units)
%
%-------function help------------------------------------------------------
% NAME
%   num2duration.m
% PURPOSE
%   convert a number to a duration based on specified
% USAGE
%   durvar = str2duration(strvar,format)
% INPUT
%   num - numeric value of a duration
%   units - format of duration as a character vector
% OUTPUT
%   durvar - variable returned as a duration in defined duration units
% SEE ALSO
%   used in str2duration.m and ts_interval.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    switch units
        case {'s','sec','secs'}
            durvar = seconds(num);
        case {'m','min','mins'}
            durvar = minutes(num);
        case {'h','hr','hrs'}
            durvar = hours(num);
        case {'d','day','days'}
            durvar = days(num);
        case {'y','yr','yrs'}
            durvar = years(num);
        otherwise
            durvar = [];
            warndlg('Only days, hours, minutes or seconds handled')
    end
end