function [answer,idx] = isunique(usevals,isvals,ignoreInvalid)
%
%-------function help------------------------------------------------------
% NAME
%   isunique.m
% PURPOSE
%   check that all values in usevals are unique
% USAGE
%   [answer,idx] = isunique(usevals,isvals)
% INPUT
%   usevals - vector to be checked can be cell array, numeric, datetime or
%             duration
%   isvals        : true  -> return indices of unique values (default)
%                   false -> return indices of non-unique values
%   ignoreInvalid : true  -> exclude NaN, NaT, empty cells from test (default)
%                   false -> include them in the uniqueness test
% OUTPUT
%   answer - true if (valid) values are unique
%   idx - indices of values that are unique or duplicates depending on isvals
% NOTES
%   if the vector includes NaT, NaN or empty cells and ignoreInvalid is true
%   these values are excluded fromt the test and only valid values are used
%   in the unique test. If ignoreInvalid is false, the answer is false and
%   idx contains indices of the invalid values (ie NaT, NaN or empty cells)
%
% Author: Ian Townend
% CoastalSEA (c)Dec 2020
% modified Jan 2026 because logic in previous version was incorrect and now
% take advantage of 'unique' handling datetime and duration directly
%--------------------------------------------------------------------------
%
    if nargin<2
         isvals = true;
        ignoreInvalid = true;     
    elseif nargin<3
        ignoreInvalid = true;
    end

    % --- Identify invalid values (NaN or NaT) ----------------------------
    if isnumeric(usevals)
        invalidMask = isnan(usevals);    
    elseif isdatetime(usevals) || isduration(usevals)
        invalidMask = isnat(usevals);    
    elseif iscell(usevals)
        % Empty cells count as invalid
        invalidMask = cellfun(@isempty, usevals); 
    elseif iscategorical(usevals)
        invalidMask = [];
    else
        error('Unsupported data type for uniqueness check.');
    end

    % --- Behaviour when invalid values are NOT ignored ------------------
    if ~ignoreInvalid && any(invalidMask)
        answer = false;
        idx = find(invalidMask);  % invalid entries count as non-unique
        return
    end

    % --- Select values to test ------------------------------------------
    if ignoreInvalid
        % Exclude invalid values from the uniqueness test
        validMask = ~invalidMask;
    else
        % Include everything
        validMask = true(size(usevals));
    end

    vals = usevals(validMask);
    validIdx = find(validMask);

    % --- Uniqueness test -------------------------------------------------
    [~, idxUnique] = unique(vals, 'stable');
    answer = numel(idxUnique) == numel(vals);

    % --- Legacy index behaviour -----------------------------------------
    if isvals
        % Return indices of unique values (mapped back to original vector)
        idx = validIdx(idxUnique);

    else
        % Return indices of non-unique values (mapped back to original vector)
        allLocal = 1:numel(vals);
        nonUniqueLocal = allLocal(~ismember(allLocal, idxUnique));
        idx = validIdx(nonUniqueLocal);
    end
end