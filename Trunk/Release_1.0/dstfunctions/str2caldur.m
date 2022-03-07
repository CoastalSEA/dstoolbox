function caldurvar = str2caldur(strvar)
%
%-------function help------------------------------------------------------
% NAME
%   str2caldur.m
% PURPOSE
%   convert a string created from a calendar duration back to a calendar 
%   duration
% USAGE
%   caldurvar = str2caldur(strvar)
% INPUT
%   strvar - text string of a calendar duration (with units)
% OUTPUT
%   caldurvar - variable returned as a calendar duration in defined units
% SEE ALSO
%   used in str2var.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    %test whether every row has the same number of duration fields
    pat = {'y','q','mo','w','d','h','m','s'};
    if ~iscell(strvar)  %handle single character vectors
        strvar = {strvar};
    end
    caldurstr = binstrvar(strvar,pat);
    %
    caldurvar = zeros(size(caldurstr,1),1);
    for i=1:size(pat,2)
        caldurnum = cellfun(@str2num,caldurstr(:,i),'UniformOutput',false);
        caldurnum = cell2mat(caldurnum);
        caldurvar = caldurvar+num2caldur(caldurnum,pat{i});
    end
end
%%
function caldurstr = binstrvar(strvar,pat)
    %split the calendar duration strings into the components and assign to
    %an array
    nvar = size(strvar,1);
    npat = length(pat);
    caldurstr{nvar,npat} = [];
    for i=1:nvar
        substr = strsplit(strvar{i});
        for j=1:npat
            idx = contains(substr,pat{j});
            if any(idx)
                units = pat{j};
                %traps finding mo rather than m
                if sum(idx)>1 %both present
                    idx = find(idx,1,'last');
                elseif all(contains(substr,'mo')==idx) %only mo present
                    caldurstr{i,j} = '0';
                    continue;
                end
                %
                caldurstr{i,j} = substr{idx}(1:end-length(units));
            else
                caldurstr{i,j} = '0';
            end
        end
    end
end


