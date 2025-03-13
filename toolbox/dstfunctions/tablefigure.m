function varargout = tablefigure(figtitle,headtext,atable,varnames,values)
%
%-------function help------------------------------------------------------
% NAME
%   tablefigure.m
% PURPOSE
%   generate plot figure to show table with a button to copy to clipboard
% USAGE
%   varargout = tablefigure(figtitle,headtext,atable,varnames,values);
%   e.g.   [hf,hp,ht] = tablefigure('Title','Descriptive text',atable);
%   or     tablefigure('Title','Descriptive text',rows,vars,data);
% INPUT
%   figtitle  - handle to figure/tab, or the figure title
%               if figure title option this can be a cell array where the 
%               figtitle{1} is used for the figure title and figtitle{2} is
%               used for the hidden axes plot title
%   headtext  - descriptive text that preceeds table (figtitle used as default)  
%   atable    - a table with rows and column names, or a cell array input
%               of row names. If rownames empty then numbered sequentially            
%   varnames  - cell array input of variable names if using cell arrays
%   values    - cell array of data values if using cell arrays (must 
%               match length of rownames and varnames)
% OUTPUT
%   varargout: user defined output 
%      1: h_fig - handle to figure (handle can be used to modify layout)
%      2: h_pan - handel to panel
%      3: ht    - handle to table
% NOTES
%   when passed a table then UserData can be used to pass additional information.
%   Uses currently included:
%   atable.Properties.UserData.List: Dropdown lists for some or all variables
%     pass the list as a cell in a cell array of same length as the number
%     of variables in the table. (Used in Asmita class: Element.eleTable).
%    
% SEE ALSO
%   used in tablefigureUI.m and tabtablefigure.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    msg = sprintf('Incorrect variable definition\nUse:(title,header,table) or (title,header,rownames,varnames,values)');
    if nargin==3          %table or dstable input
        if isa(atable,'dstable')
            atable = atable.DataTable;
        elseif ~isa(atable,'table')
            warndlg(msg); %return if 3 arguments and not a table or dstable
            return
        end
        rownames = atable.Properties.RowNames;
        varnames = atable.Properties.VariableNames;
    elseif nargin==5      %cell array input
        rownames = atable;
        atable = cell2table(values);
        atable.Properties.VariableNames = varnames;
        if ~isempty(rownames)
            atable.Properties.RowNames = rownames;
        end
    else        
        warndlg(msg);
        return
    end
 
    if isempty(rownames)
        rownames = 'numbered';
    end
    
    if isempty(headtext) 
        if ishandle(figtitle)
            if isgraphics(figtitle,'matlab.ui.container.Tab')
                headtext = figtitle.Title;
            else
                headtext = figtitle.Name;
            end
        else
            headtext = figtitle;
        end
    end

    %find the width required for each column and height of table
    nlines = 3;                %number of lines/rows in header and footer
    [~,colwidth,tabheight] = getcolumnwidths(atable);
    nrows = height(atable);
    rowheight = tabheight/nrows;
    headfootsize = nlines*rowheight;
    
    %create figure with a panel
    [h_fig,h_tab] = setFigure(figtitle);

    %add panel
    h_pan = uipanel('Parent',h_tab,'Units','pixels','Tag','TableFig_panel');           
    borders = h_pan.OuterPosition(3:4)-h_pan.InnerPosition(3:4);    

    %adjust panel dimensions to correct position on figure
    h_pan.Position(1) = rowheight/2;
    h_pan.Position(3) = h_tab.Position(3)-rowheight*0.9;
    h_pan.Position(2) = headfootsize;
    h_pan.Position(4) = h_tab.Position(4)-2*headfootsize;  

    %generate table of properties  
    colwidth = num2cell(colwidth,1); %format required by uitable
    %uitable cannot handle categoric data or strings so change to char
    iscat = varfun(@iscategorical,atable,'OutputFormat','uniform');
    if any(iscat)        
        atable = convertvars(atable,iscat,'cellstr');
    end   

    isstr = varfun(@isstring,atable,'OutputFormat','uniform');
    if any(isstr)        
        atable = convertvars(atable,isstr,'cellstr');
    end 

    %must be cell array not table when uitable used with figure
    uitableout = table2cell(atable);
    
    ht = uitable('Parent',h_pan,...
                 'ColumnName',varnames,...
                 'ColumnWidth', colwidth,...
                 'RowName',rownames,...
                 'Data',uitableout,...
                 'Tag','uitablefigure');

    %format numerical data
    % Use varfun to apply the class function to each variable
    variableTypes = varfun(@class, atable, 'OutputFormat', 'cell');
    idnum = find(strcmp(variableTypes,'double')); 
    ht.Data = formatNumeric(ht.Data,idnum);
  
    tabprop = atable.Properties.UserData;
    if ~isempty(tabprop) && isfield(tabprop,'List')
        %to use a drop down list of options pass the list as a cell in a 
        %cell array of same length as he number of variables in the table        
        idlist = ~cellfun(@isempty,tabprop.List); 
        ht.ColumnFormat{idlist} = tabprop.List{idlist};
    end  
    
    if ht.Extent(3)>h_pan.InnerPosition(3) || ...
                                    ht.Extent(4)>h_pan.InnerPosition(4)
       %table width wider or taller than panel - triggers scroll bars
       scrollbar = rowheight*1.1;
    else
       scrollbar = 0;
    end
    
    ht.Position(1:2) = borders/2;
    %adjust table to fit in panel
    if ht.Extent(3)>h_pan.InnerPosition(3)          %Width
        ht.Position(3) = h_pan.InnerPosition(3);
    else
        ht.Position(3) = ht.Extent(3)+scrollbar;
        if isgraphics(h_fig,'figure') %adjust figure panel but not tabs
            h_pan.Position(3) = ht.Position(3)+borders(1);  %add border around table
        end
        %
        if ~ishandle(figtitle) %adjust figure if created by tablefigure function              
            h_fig.Position(3) = h_pan.Position(3)+rowheight; 
        end
    end
    %
    if ht.Extent(4)>h_pan.InnerPosition(4) || ...     %Height
                                isa(figtitle,'matlab.ui.container.Tab')
        ht.Position(4) = h_pan.InnerPosition(4);
    else
        ht.Position(4) = ht.Extent(4)+scrollbar;
        %
        if isgraphics(h_fig,'figure') %adjust figure panel but not tabs
            h_pan.Position(4) = ht.Position(4)+borders(2); %add border around table
        end
        %
        if ~ishandle(figtitle) %adjust figure if created by tablefigure function             
            h_fig.Position(4) = h_pan.Position(4)+2*headfootsize; 
        end
    end
    
    %add header text
    headerpos = h_pan.Position(4)+headfootsize;
    headpos = [rowheight/2 headerpos h_pan.Position(3) headfootsize*0.95];   
    statictextbox(h_tab,nlines,headpos,headtext);
    
    %Create push button to copy data to clipboard
    setButton(h_tab,h_pan,rowheight,headfootsize,figtitle,atable)
    if ~ishandle(figtitle)
        hch = findobj(h_fig.Children);
        for i=1:length(hch)             %change units to normalized so that
            hch(i).Units = 'normalized';%components are resized when the
        end                             %figure is resized.
        h_fig.Visible = 'on';           %make figure visible
    else
        %h_pan.Units = 'normalized';
        ht.Units = 'normalized';
    end

    if nargout==1
        varargout{1} = h_fig; %handle to tablefigure
    elseif nargout==2
        varargout{1} = h_fig; %handle to tablefigure
        varargout{2} = h_pan; %handle to tablepanel
     elseif nargout==3 
        varargout{1} = h_fig; %handle to table figure
        varargout{2} = h_pan; %handle to table panel
        varargout{3} = ht;    %handle to table
    end
end
%%
function [h_fig,h_tab] = setFigure(figtitle)
    %create figure - with tabs if figure handle used in call
    if ishandle(figtitle)
        h_fig = figtitle;                                %graphic handle
        h_tabgroup = findobj(h_fig,'Type','uitabgroup');
        if isempty(h_tabgroup)                           %no tabgroup
            h_tab = h_fig; 
            isatab = findobj(h_fig,'Type','uitab');     
            if ~isempty(isatab)                          %handle is a tab
                h_fig.Units = 'pixels';                  
            end
        else
            h_tab = h_tabgroup.SelectedTab;
            h_tab.Units = 'pixels';
        end
    else
        if iscell(figtitle) 
            figt = figtitle{1};    
        else
            figt = figtitle;
        end

        h_fig = figure('Name',figt,'Tag','TableFig',...
                       'NextPlot','add','MenuBar','none',...
                       'Resize','on','HandleVisibility','on', ...
                       'NumberTitle','off',...
                       'Visible','off'); %NB should be off when not debugging   
        h_fig.Units = 'pixels';       

        if iscell(figtitle) && length(figtitle)>1  %plot title included in input            
            title(figtitle{2},'FontSize',9);
            axis off
        end
        %move figure
        screen = get(0,'ScreenSize');
        hpos = (screen(3)-h_fig.Position(3))/4;  %offcentre to left
        if hpos<1, hpos = 1; end
        vpos = (screen(4)-h_fig.Position(4))/1.5;  %middle
        if vpos<1, hpos = 1; end
        h_fig.Position(1) = hpos;
        h_fig.Position(2) = vpos;
        h_tab = h_fig;
    end
end
%% 
function setButton(h_tab,h_pan,rowheight,headfootsize,figtitle,tableout)
    %create action button to copy table data to clipboard
    if ishandle(figtitle)
        pos1 = h_pan.Position(3)+rowheight-100-rowheight/2;
    else
        pos1 = h_tab.Position(3)-100-rowheight/2;
    end
    position = [pos1 rowheight/2 100 headfootsize*0.6];%same units as figure
    setactionbutton(h_tab,'Copy to clipboard',position,...
               @copydata2clip,'uicopy','Copy table content to clipboard',tableout);
end
%%
function uidata = formatNumeric(uidata,idnum)
    %reformat numeric data in table
    nrow = size(uidata,1);
    for i=1:length(idnum)
        for j=1:nrow
            value = uidata{j,idnum(i)};
            val = abs(value);
            if val>999.9
                uidata{j,idnum(i)} = sprintf('%.3e',value); 
            elseif val>9.9
                uidata{j,idnum(i)} = sprintf('%.1f',value);
            elseif val>0.09
                uidata{j,idnum(i)} = sprintf('%.3f',value); 
            elseif val>1e-3
                uidata{j,idnum(i)} = sprintf('%.3e',value);
            end    
        end
    end
end