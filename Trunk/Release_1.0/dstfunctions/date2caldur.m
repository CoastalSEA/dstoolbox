function [timedurs,timeunits] = date2caldur(dates,offset,timeunits)
%
%-------function help------------------------------------------------------
%NAME
%   date2caldur.m
%PURPOSE
%   convert datetimes to calendar durations with selected time units and an
%   optional offset from zero. prompts for units if not defined
% USAGE
%   [timedurs,timeunits] = date2caldur(dates,offset,timeunits)
% INPUT
%   dates - datetime vector to define durations
%   offset - duration offset eg eps(0) (optional or empty)
%   timeunits - unit of time duration to use (optional)
% OUTPUT
%   timedurs - calendar durations from t0 in selected time units. If there is an
%              offset>0 the durations are from the first value of dates, 
%              otherwise they are from 1-Jan-0001.
%   timeunits - user selected units for calendar duration 
% NOTES
%   some stats routines pass offset=eps(0) to avoid divide by zero when
%   using durations from t(1).
% SEE ALSO
%   date2duration which is similar but returns durations
%
% Author: Ian Townend
% CoastalSEA (c)Feb 2021
%--------------------------------------------------------------------------
%
    listxt = {'None','Years','Quarters','Months','Weeks','Days','Time'};
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
    if contains(timeunits,listxt)
        if strcmp(timeunits,'None')
            timedurs = between(t0,dates); %returns calendar durations
        else
            timedurs = between(t0,dates,timeunits); %returns calendar durations
        end
    else
        warndlg('Only Years, Quarters, Months, Weeks, Days, or Time handled')
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