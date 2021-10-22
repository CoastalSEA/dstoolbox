function [timeints,timeunits] = date2duration(dates,offset,timeunits)
%
%-------function help------------------------------------------------------
%NAME
%   date2duration.m
%PURPOSE
%   convert datetimes to durations with selected time units and an
%   optional offset from zero. prompts for units if not defined
% USAGE
%   [timeints,units] = date2duration(dates)
% INPUT
%   dates - datetime vector to define durations
%   offset - duration offset (optional or empty)
%   timeunits - unit of time duration to use (optional)
% OUTPUT
%   timeints - durations from t0 in selected time units. If there is an
%              offset>0 the durations are from the first value of dates, 
%              otherwise they are from 1-Jan-0001.
%   timeunits - user selected units for duration 
% NOTES
%   some stats routines pass offset=eps(0) to avoid divide by zero when
%   using durations from t(1).
% SEE ALSO
%   used in muiStats, regression_plot.m, descriptive_stats, CT_BeachAnalysis
%
% Author: Ian Townend
% CoastalSEA (c)Feb 2021
%--------------------------------------------------------------------------
%
    listxt = {'years','days','hours','minutes','seconds'};
    if nargin<2 || isempty(offset)
        offset = 0; 
        timeunits = getTimeUnits(listxt);
    elseif nargin<3
        timeunits = getTimeUnits(listxt);
    end
    %
    
    if offset>0
        t0 = dates(1)+offset;
    else
        t0 = datetime(1,1,1);
        t0.Format = dates.Format;
    end
    %
    if contains(timeunits,listxt)
        timeints = between(t0,dates,'years'); 
    else
        warndlg('Only years, days, hours, minutes or seconds handled')
        return
    end   
end
%%
function timeunits = getTimeUnits(listxt)
    %prompt user to select time units    
    answer = listdlg('Name','Variables', ...
                    'PromptString','Select units:', ...
                    'ListSize',[200,100],...
                    'SelectionMode','single', ...
                    'ListString',listxt);
    if isempty(answer), answer = 1; end
    timeunits = listxt{answer};
end