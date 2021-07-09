function h_but = setactionbutton(parent,butext,position,callback,...
                                 tag,tooltip,userdata)
%
%-------function help------------------------------------------------------
% NAME
%   setactionbutton.m
% PURPOSE
%   add an action button with callback to graphical object
% USAGE
%   h_but = setactionbutton(parent,butxt,position,callback,userdata,tooltip)
% INPUTS
%   parent   - handle to graphics object to be used as Parent
%   butext   - text to appear on button
%   position - position of button on parent (units as per parent)
%   callback - callback function to be called on button press
%   tag      - uitag
%   tooltip  - a tip on button usage (optional)
%   userdata - any data to be passed with callback (optional)
% OUTPUT
%   h_but - handle to uicontrol for the action button
% NOTES
%   To find all buttons on figure use: findobj(parent,'Tag','ActionButton')
%   To find individual button use: 
%       findobj(parent,'Tag','ActionButton','-and','String',butext)
% SEE ALSO
%   used in tablefigure.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    if nargin<6
        tooltip = '';
        userdata = [];        
    elseif nargin<7        
        userdata = [];
    end
    %
    h_but = uicontrol('Parent', parent,...
                      'Tag',tag,...
                      'Style', 'pushbutton',...
                      'String', butext,...
                      'Units', parent.Units, ...
                      'Position', position,... 
                      'Callback', callback,...
                      'UserData', userdata,...
                      'ToolTip', tooltip);
    if length(butext)<5
        if all(isstrprop(butext,'alphanum') + isstrprop(butext,'wspace'))
            h_but.FontName = 'FixedWidth';
        else
            h_but.FontName = 'Symbol';
        end
    end
end