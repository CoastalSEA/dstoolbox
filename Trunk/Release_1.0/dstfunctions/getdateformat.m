function format = getdateformat(varstr)
%
%-------function help------------------------------------------------------
% NAME
%   getdateformat.m
% PURPOSE
%   try to determine the datetime format of a text string
% USAGE
%   format = getdateformat(varstr)
% INPUT
%   varstr - character vector cell array of the date string 
% OUTPUT
%   format- Matlab datetime format identified for the date string
% NOTE
%   defaults to system Locale format if cannot resolve eg date and month
%   both less than 13
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
    sep = split(varstr,{'/','-',':',' '});
    date = ''; time = '';
    if contains(varstr,'/')
        ddMM = checkOrder(sep);
        yyyy = yearStyle(sep);
        date = sprintf('%s/%s/%s',ddMM{1},ddMM{2},yyyy);
    elseif contains(varstr,'-')
        ddMM = checkOrder(sep);
        yyyy = yearStyle(sep);
        date = sprintf('%s-%s-%s',ddMM{1},ddMM{2},yyyy);
    end
    %
    if contains(varstr,':')
        time = 'hh:mm:ss';
    end
    format =strip([date,' ',time]);
end
%%
function ddmm = checkOrder(sep)
    %try to sort order. Use UK order if cannot determine
    if str2double(sep{1})>12
        ddmm = {'dd','MM'};
    elseif str2double(sep{2})>12
        ddmm = {'MM','dd'};
    else
        d = datetime('today');     %get a system formatted date
        format = d.Format;
        fd = split(format,{'/','-'});
        if length(fd{2})==3 && length(sep{2})<3
            fd{2} = 'MM';
        end
        ddmm = {fd{1},fd{2}};
    end
end
%%
function yr = yearStyle(sep)
    %determine length of year string
    ny = length(sep{3});
    yr = repmat('y',1,ny);
end