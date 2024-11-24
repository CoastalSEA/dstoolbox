function p = getprecision(x)
%
%-------function help------------------------------------------------------
% NAME
%   getprecision.m
% PURPOSE
%   find the precision of a number that is a double
% USAGE
%   p = getprecision(x)
% INPUTS
%    x - a number to be tested. If x is a vector, only the first value is
%    tested.
% OUTPUT
%   p - precision of x, return p=0 if x is not a double
% NOTES
%   https://stackoverflow.com/questions/16527571/find-number-of-decimal-digits-of-a-variable-in-matlab
%     y = x.*10.^(1:20)
%     find(y==round(y),1)
%   However this does not work for integer and 2 decimal places when x<1.17 
%   Remove integers using isallround and trap the cases with 2 d.p.
% SEE ALSO
%   called in editrange_ui and var2str
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
% 
    p = 0;
    if ~isscalar(x), x = x(1); end

    if strcmp('double',getdatatype(x))
        maxp = 20;                       %maximum number of decimal places
        if (mod(x, 1) == 0), return; end %exclude round numbers
        y = x.*10.^(1:maxp);
        isround = y==round(y);
        p = find(isround,1);             %number of decimal places (excludes trailing zeros)
        %if from p to end isround are all true, this is the correct answer. 
        %if p=1 and and isround is then true every 2 out of 3 samples, is also correct
        %if p=3 and isround is true every 2 out of 3 samples, this is not correct
        if ~all(isround(p:end)) && p==3
            p = 2;                       %correct for small values with 2 d.p. (x<1.17)
        end
    end
end