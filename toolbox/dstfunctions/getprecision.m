function p = getprecision(x)
%
%-------function help------------------------------------------------------
% NAME
%   getprecision.m
% PURPOSE
%   find the precision (number of significant digits) of a number that is a double
% USAGE
%   p = getprecision(x)
% INPUTS
%    x - number to be tested.  x can be a scalar or a vector array.
% OUTPUT
%   p - precision of x ie number of significant digits
%       return p=0 if x is not a double, -ve sign not included in count
% NOTES
%   https://stackoverflow.com/questions/16527571/find-number-of-decimal-digits-of-a-variable-in-matlab
%     y = x.*10.^(1:20)
%     find(y==round(y),1)
%   However this does not work for integer and 2 decimal places when x<1.17 
%   Remove integers using isallround and trap the cases with 2 d.p.
% SEE ALSO
%   called in numvec2str
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
% 
   if ~isvector(x)
       warndlg('getprecision only handles scalar and vector arrays')
       p = []; return; 
   end

    nrec = length(x);
    dp = getdecimalplaces(x);                %number of decimal places
    ip = zeros(1,nrec);
    for i=1:nrec                             %number of integer places
        ip(i) = length(num2str(floor(abs(x(i)))));     
    end
  
    p = dp+ip;                               %number of significant places
end