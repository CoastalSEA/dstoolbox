function copydata2clip(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   copydata2clip.m
% PURPOSE
%   copy data from the active figure or tab to the clipboard
% USAGE
%   copydata2clip(src,evt)
% INPUTS
%   src - UI component that triggered the callback
%   evt - event data to the callback function (not used)
% OUTPUT
%   data is posted to the clipboard
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    if istable(src.UserData)
        data = table2cell(src.UserData);
        varnames = src.UserData.Properties.VariableNames;
        rownames = src.UserData.Properties.RowNames;
        clip = vertcat(varnames,data);
        if ~isempty(rownames)
            rownames = vertcat({''},rownames);
            clip = horzcat(rownames,clip);
        end
    elseif iscell(src.UserData)
        clip = src.UserData;
    end
    mat2clip(clip);          
end 