function [timedurs,timeunits] = date2duration(dates,offset,timeunits)
%
%-------function help------------------------------------------------------
%NAME
%   date2duration.m
%PURPOSE
%   convert datetimes to durations with selected time units and an
%   optional offset from zero. prompts for units if not defined
% USAGE
%   [timedurs,timeunits] = date2duration(dates,offset,timeunits)
% INPUT
%   dates - datetime vector to define durations
%   offset - duration offset eg eps(0) (optional or empty)
%   timeunits - unit of time duration to use (optional)
% OUTPUT
%   timedurs - durations from t0 in selected time units. If there is an
%              offset>0 the durations are from the first value of dates, 
%              otherwise they are from 1-Jan-0001.
%   timeunits - user selected units for duration 
% NOTES
%   some stats routines pass offset=eps(0) to avoid divide by zero when
%   using durations from t(1).
% SEE ALSO
%   date2caldur which is similar but returns calendar durations
%   used in muiStats, regression_plot.m, CT_BeachAnalysis
%
% Author: Ian Townend
% CoastalSEA (c)Feb 2021
%--------------------------------------------------------------------------
%
    listxt = {'years','days','hours','minutes','seconds'};
    if nargin<2
        offset = 0; 
        timeunits = getTimeUnits(listxt);
    elseif nargin<3
        timeunits = getTimeUnits(listxt);
        if isempty(offset)
            offset = 0;
        end
    end
    %
    if offset>0
        t0 = dates(1);
    else
        t0 = datetime(0,1,1,0,0,0);
        t0.Format = dates.Format;
    end
    %
    timedurs = dates-t0;
    switch timeunits
        case 'years'
            timedurs.Format = 'y';
        case 'days'
            timedurs.Format = 'd'; 
        case 'hours'
            timedurs.Format = 'h';
        case 'minutes'
            timedurs.Format = 'm'; 
        case 'seconds'
            timedurs.Format = 's';
        otherwise
            warndlg('Only years, days, hours, minutes or seconds handled')
            return
    end    
    timedurs(1) = timedurs(1)+offset; %add offset to first record if defined
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