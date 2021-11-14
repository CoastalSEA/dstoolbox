function getdialog(msgtxt,msgpos,delay)
%
%-------function help------------------------------------------------------
% NAME
%   getdialog.m
% PURPOSE
%   generate a 'normal' message dialogue box with no buttons
% USAGE
%   getdialog(msgtxt,msgpos,delay)    
%   Call options: getdialog(msgtxt); getdialog(msgtxt,msgpos);
%   getdialog(msgtxt,msgpos,delay); getdialog(msgtxt,[],delay);
% INPUTS
%   msgtxt - text to display
%   msgpos - position of message box - standard Matlab format (optional)
%   delay  - time delay for pausing display of message box (optional)
% OUTPUT
%   message displayed in a dialog box for a short period (default is 2s)
% NOTES
%   Dialogue WindowStyle is normal
% SEE ALSO
%   setdialog.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    if nargin<2
        msgpos = [0.42,0.52,0.16,0.08];
        delay = 2;
    elseif nargin<3
        delay = 2;
    elseif isempty(msgpos)
        msgpos = [0.42,0.52,0.15,0.08];
    end
    hd = setdialog(msgtxt,msgpos,'normal');
    pause(delay)
    delete(hd)
end 