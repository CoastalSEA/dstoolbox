function [answer,idx] = isunique(usevals,isvals)
%
%-------function help------------------------------------------------------
% NAME
%   isunique.m
% PURPOSE
%   check that all values in usevals are unique
% USAGE
%   answer = isunique(usevals)
% INPUT
%   usevals - vector to be checked can be character, numeric, datetime or
%             duration
%   isvals - logical true returns indices of all values that are unique and
%            false returns indices of values that are not unique (optional)
% OUTPUT
%   answer - true if all values in usevals are unique
%   idx - indices of values that are unique or duplicates depending on isvals
% NOTES
%   when returning duplicates these are for all indices except the first
%   occurrence. empty cells in cell arrays are ignored
%
% Author: Ian Townend
% CoastalSEA (c)Dec 2020
%--------------------------------------------------------------------------
%
    if nargin<2
        isvals = true;
    end
    if isdatetime(usevals) || isduration(usevals)
        usevals = cellstr(usevals);
    elseif iscell(usevals) && any(cellfun(@isempty,usevals))
        idx = cellfun(@isempty,usevals);
        usevals(idx) = [];
    end
    [~,idx,idy] = unique(usevals,'stable');
    answer = numel(idx)==numel(idy);
    
    if ~isvals
        ind = 1:length(usevals);
        idx = find(~ismember(ind,idx));
    end
end