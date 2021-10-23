function [timenum,inpformat] = time2num(timein,offset)
%
%-------function help------------------------------------------------------
% NAME
%   time2num.m
% PURPOSE
%   convert datetime or duration to a numeric value (eg for plotting)   
% USAGE
%   [timenum.inpformat] = time2num(timein,offset,timeunits)
% INPUT
%   timein - array of datetime or duration values to be checked
%   offset - duration offset eg eps(0)  (optional)
% OUTPUT
%   timenum - timein values converted to numeric values. If there is an
%             offset>0 the durations are from the first value of dates, 
%             otherwise they are from 1-Jan-0001.
%   inpformat - format of input datetime or duration
% NOTES
%   some stats routines pass offset=eps(0) to avoid divide by zero when
%   using durations from t(1).
% SEE ALSO
%   date2duration is similar but returns duratios with or without offset
%   used in muiPlots and setfigslider
%   muiStats, regression_plot.m, descriptive_stats, CT_BeachAnalysis
%   
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    if nargin<2
        offset = 0;   %used to in stats functions to avoid divide by zero
    end
    %
    if isdatetime(timein)    
        %adjust start if offset has a positive value (eg eps(0))
        if offset>0
            startyear = timein(1);
        else
            startyear = datetime(0,1,1,0,0,0);
            startyear.Format = timein.Format;
        end
        elapsedtime = timein-startyear;     %returns duration values
        timenum = years(elapsedtime);       %returns numeric values
        inpformat = timein.Format;
    elseif iscalendarduration(timein)
        startyear = datetime(0,1,1,0,0,0);
        datetimein = startyear+timein;      %returns datetime values
        if offset>0
            startyear = datetime(0,1,1,0,0,0)+timein(1);
        end  
        elapsedtime = datetimein-startyear; %returns duration values
        timenum = years(elapsedtime);       %returns numeric values
        inpformat = timein.Format;
    else
        %use the string to get the numerical values and format of durations
        timenum = cellstr(timein);
        timenum = squeeze(split(timenum));
        if numel(timenum)==2 && iscolumn(timenum)
            %split returns a 2x1 cell array for a single values
            %force row vector when timein is a single value
            timenum= timenum'; 
        end  
        inpformat = timenum{1,2};
        timenum = getdurationnum(timenum,offset);
    end
    
    timenum(1) = timenum(1)+offset; %add offset to first record if defined
end
%%
function timenum = getdurationnum(timein,offset)
    timenum = cellfun(@str2num,timein(:,1),'UniformOutput',false);
    timenum = cell2mat(timenum);
    if offset>0
        timenum = timenum-timenum(1);
    end
end