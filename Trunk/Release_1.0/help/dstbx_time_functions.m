%% dstoolbox functions that manipulate time variables
% Summary of the functions available in the _dstfunctions_ folder that move
% convert data between formats

%%
% * *deciyear.m*
% -  convert datetimes, or date strings, to decimal years
% 
% * *date2caldur.m*
% - convert datetimes to calendar durations with selected time units and an
% optional offset from zero. Prompts for units if not defined
%
% * *date2duration.m*
% - convert datetimes to durations with selected time units and an
% optional offset from zero. Prompts for units if not defined
% 
% * *getdateformat.m*
% - try to determine the datetime format of a text string
%
% * *isdatdur.m*
% - identify whether RowNames or a Variable in a dstable are datetime, 
% duration or calendarDuration 
%
% * *istimeseriesdst.m*
% - check whether the first variable in a dstable is a datetime vector
% array
%
% * *num2caldur.m*
% - convert a number to a calendar duration based on specified units
%
% * *num2duration.m*
% - convert a number to a duration based on specified format (or vice versa)
% 
% * *str2caldur.m*
% - convert a string created from a calendar duration back to a calendar 
% duration
%
% * *str2duration.m*
% - convert a string created from a duration back to a duration
% 
% * *str2var.m*
% - Convert the input cell array of character vectors to an array of the 
% specified data type and using the given format if datetime, or duration,
% 
% * *time2num.m*
% - convert datetime, duration or calendarDuration to a numeric value (eg for plotting)
%
% * *var2str.m*
% - convert the input variable to a cell array of strings and return the 
% data type and format (for datetime, duration and calendarDuration only) 






