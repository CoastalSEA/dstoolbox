function h_box = statictextbox(parent,nlines,boxpos,boxtext,boxunits)
%
%-------function help------------------------------------------------------
% NAME
%   statictextbox.m
% PURPOSE
%   create static text box with wrapped text to fit the number of lines
%   if greater that nlines make box scrollable
% USAGE
%   h_box = statictextbox(parent,boxpos,boxtext)
% INPUT
%   parent  - handle to graphical object parent (eg figure/tab)
%   nlines - number of lines of wrapped text before scroll bar is required
%   boxpos - position of box in graphical object (default is pixel units)
%   boxtext  - text string to be used in box
%   boxunits - units to be used for uicontrol (optional)
% OUTPUT
%   h_box     - handle to uicontrol
% SEE ALSO
%   used in tablefigure.m and
%
% Author: Ian Townend
% CoastalSEA (c)March 2021
%--------------------------------------------------------------------------
%
    if nargin<5
        boxunits = 'pixels';
    end
    boxpos(3) = boxpos(3)*0.95; %reduce width to allow for scroll bar when wrapping
    h_box = uicontrol('Parent',parent,'Style','text','String',boxtext,...
                       'Units',boxunits,'Position',boxpos,...
                       'HorizontalAlignment','left','Tag','statictextbox'); 
    boxtext = string(boxtext);
    [wrappedtext,wrappedpos] = textwrap(h_box,boxtext); 
    if size(wrappedtext,1)>nlines
        delete(h_box)
        boxpos(3) = boxpos(3)/0.95; %restore width
        uicontrol('Parent',parent,'Style','edit','String',boxtext,...
                'Units',boxunits,'Position',boxpos,...
                'min',0,'max',2,'enable','inactive',...
                'HorizontalAlignment','left',...
                'BackgroundColor',[0.96,0.96,0.96],'Tag','statictextbox');
    else
        h_box.String = wrappedtext;
        h_box.Position = wrappedpos;        
    end      
end