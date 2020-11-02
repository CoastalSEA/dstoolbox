%% tsc2dst
% Function to convert a <matlab:doc('tscollection') tscollection> to a
% <matlab:doc('dstable') dstable>.

%% Syntax
%   dst = tsc2dst(tsc,idxtime,idxvars)    %converts a tscollection to a dstable object

%% Description
% Convert a _tscollection_ to a _dstable_. If a _dsproperties_ object is stored 
% in the _tscollection_ tsc.TimeInfo.UserData property, the DSproperties 
% for the variables included in the call are added to the _dstable_.

%% Input arguments
% idxtime - index vector for the subselection of time <br>
% idxvars - index vector for the subselection of variables, or the variable
% names as a cell array of character vectors.

%% See also
% <matlab:doc('dstable') dstable>, <matlab:doc('tsccollection') tscollection>,
% <matlab:doc('dst2tsc') dst2tsc>
