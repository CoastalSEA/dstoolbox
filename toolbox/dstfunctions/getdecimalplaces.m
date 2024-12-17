function dp = getdecimalplaces(x)
%
%-------function help------------------------------------------------------
% NAME
%   getdecimalplaces.m
% PURPOSE
%   find the decimal places for numbers that are doubles
% USAGE
%   p = getdecimalplaces(x)
% INPUTS
%    x - number to be tested.  x can be a scalar or a vector array.
% OUTPUT
%   dp - number of decimal places in x, return p=0 if x is not a double
% NOTES
%   https://stackoverflow.com/questions/16527571/find-number-of-decimal-digits-of-a-variable-in-matlab
%     y = x.*10.^(1:20)
%     find(y==round(y),1)
%   However this does not work for integer and 2 decimal places when x<1.17 
%   Remove integers using isallround and trap the cases with 2 d.p.
% SEE ALSO
%   called in getprecision
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
% 
   if ~isvector(x)
       warndlg('getdecimalplaces only handles scalar and vector arrays')
       dp = []; return; 
   end

    dp = zeros(size(x));
    for i=1:length(x)
        if strcmp('double',getdatatype(x(i)))
            maxp = 20;                             %maximum number of decimal places
            if (mod(x(i), 1) == 0), continue; end  %exclude round numbers
            y = x(i).*10.^(1:maxp);
            isround = y==round(y);
            dp(i) = find(isround,1);               %number of decimal places (excludes trailing zeros)
            %if from p to end isround are all true, this is the correct answer. 
            %if p=1 and and isround is then true every 2 out of 3 samples, is also correct
            %if p=3 and isround is true every 2 out of 3 samples, this is not correct
            if ~all(isround(dp(i):end)) && dp(i)==3
                dp(i) = 2;                         %correct for small values with 2 d.p. (x<1.17)
            end
        end
    end
end