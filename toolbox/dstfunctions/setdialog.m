function hd = setdialog(msgtxt,msgpos,msgstyle)
%
%-------function help------------------------------------------------------
% NAME
%   setdialog.m
% PURPOSE
%   generate a dialogue with message and no buttons. Definition of
%   Position and WindowStyle are optional
% USAGE
%   setdialog(msgtxt,msgpos,msgstyle)    
%   Call options: setdialog(msgtxt); setdialog(msgtxt,msgpos);
%   setdialog(msgtxt,msgpos,msgstyle); setdialog(msgtxt,[],msgstyle);
% INPUTS
%   msgtxt - text to display
%   msgpos - position of message box - standard Matlab format (optional)
%   msgstyle - dialogue WindowStyle (eg modal), default is normal (optional)
% OUTPUT
%   message displayed in a dialog box
%   hd - handle to the dialogue
% SEE ALSO
%   getdialog.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    if nargin<2
        msgpos = [0.5,0.5,0.15,0.08];
        msgstyle = 'normal';
    elseif nargin<3
        msgstyle = 'normal';
    elseif isempty(msgpos)
        msgpos = [0.5,0.5,0.15,0.08];
    end
    
    %create dialog and add text uic
    hd = dialog('Units','Normalized','WindowStyle',msgstyle,...
        'Position',msgpos,'Name','Notification','Visible','off','Resize','on');
    hs = uicontrol('Parent',hd,...
        'Style','text',...
        'HorizontalAlignment','center',...
        'Units','Normalized',...
        'Position',[0.05 0.05 0.9 0.8],...   %was [0.05 0.3 0.9 0.9]
        'String',msgtxt);
    
    %check that text fits the default box
    if length(msgtxt)>100 
        hs.HorizontalAlignment = 'left';
        hs.Position(2) = 0.05;
        hd.Units = 'pixel'; 
        hs.Units = 'pixel';
        [wrappedtext,wrappedpos] = textwrap(hs,string(msgtxt)); 
        hs.String = wrappedtext;
        if wrappedpos(4)>hs.Position(4)
            %text bigger than dialog so make dialog bigger
            hd.Position(4) = wrappedpos(4)/0.9;   
        end
%         hs.Position = wrappedpos;
    end
    hd.Visible = 'on';
end 