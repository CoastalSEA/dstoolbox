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
    if isa(src.UserData,'dstable')
        src.UserData = src.UserData.DataTable;
    end
    
    if istable(src.UserData)
        data = table2cell(src.UserData);
        datalen = cellfun(@length,data,'UniformOutput',false);
        isarray = any([datalen{:}]>1);
        varnames = src.UserData.Properties.VariableNames;
        rownames = src.UserData.Properties.RowNames;
        clip = vertcat(varnames,data);
        if ~isempty(rownames)  
            %add row names to left side of matrix
            rownames = vertcat({''},rownames);
            clip = horzcat(rownames,clip);
        elseif size(clip,1)==2 && isarray
            %if single row of data with one or more arrays, invert so that 
            %the arrays can be output
            arraycell = cell(size(varnames,2),max([datalen{:}]));
            for i=1:length(datalen)
                arraycell(i,1:datalen{i}) = num2cell(data{i});            
            end
            clip = [varnames',arraycell];
        end
    elseif ~isempty(src.UserData)
        clip = src.UserData;
    else
        warndlg('No data available'); return;
    end
    %
    try
        mat2clip(clip);    
    catch
        warndlg('Unknown data type in coydata2clip')
    end
end 