function dtype = getdatatype(var)
%
%-------function help------------------------------------------------------
% NAME
%   getdatatype.m
% PURPOSE
%   find the data type of 'var', checks for:
%       logical,integer,float,char,string,categorical,datetime,duration,
%       calendarDuration
% USAGE
%   dtype = getdatatype(var)
% INPUT
%   var - input variable to be tested - can be single value or cell array
% OUTPUT
%   dtype - cell array of the data type of a variable. returns empty cell if type not found
% NOTE
%   If using Matlab 2020b the function underlyingType(X) is an alternative
%   for single values. This function handles cell arrays of different types 
%   of data and also checks if categorical data is ordinal.
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    types = {'logical','int8','int16','int32','int64','uint8','uint16',... 
             'uint32','uint64''single','double',...
             'char','string','categorical',...
             'datetime','duration','calendarDuration'};
             
    if ~iscell(var) && isnumeric(var)
        var = num2cell(var);                  %make cell if not already one
    elseif ~iscell(var) 
        var = {var};
    end
    nvar = length(var);
    dtype= cell(size(var));           
    for i=1:nvar
        mver = version('-release');  
        if str2double(mver(1:4))<2021            
            myfunc = @(x) isa(var{i},x);       %function for var cell arrays
            itype = cellfun(myfunc,types);
            dtype(i) = types(itype);
        else
            dtype{i} = underlyingType(var{i}); %introduced in v2020b
        end
        %
        if any(strcmp(dtype(i),'categorical'))
            if isordinal(var{i})
                dtype{i} = 'ordinal';
            end
        end
    end
end