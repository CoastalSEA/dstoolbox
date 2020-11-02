%% dst2tsc
% Method of the _dstable_ class to convert a <matlab:doc('dstable') dstable> to a
% <matlab:doc('tscollection') tscollection>.

%% Syntax
%   tsc = dst2tsc(dst,idxtime,idxvars)    %converts a dstable object to a tscollection object

%% Description
% Convert a _dstable_ to a _tscollection_. The DSproperties of the dstable are 
% adjusted to match any subselection of variables and stored in the 
% _tscollection_ tsc.TimeInfo.UserData property. 

%% Input arguments
% idxtime - index vector for the subselection of time. RowNames data type 
% used in the _dstable_ must be datetime or duration arrays, or character 
% vector in a datetime format recognised by _tscollection_ <br>
% idxvars - index vector for the subselection of variables, or the variable
% names as a cell array of character vectors. Variable type for the _dstable_ variable
% must be compatible with allowable <matlab:doc('timeseries') timeseries>
% variables.

%% See also
% <matlab:doc('dstable') dstable>, <matlab:doc('tsccollection') tscollection>,
% <matlab:doc('tsc2dst') tsc2dst>