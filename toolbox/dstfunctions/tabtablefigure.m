function varargout = tabtablefigure(figtitle,tabnames,tabtxts,tables,isvis)
%
%-------function help------------------------------------------------------
% NAME
%   tabtablefigure.m
% PURPOSE
%   generate figure with tabs to show set of tables 
% USAGE
%   h_fig = tabtablefigure(figtitle,tabnames,tabtxts,tables)  
% INPUT
%   figtitle  - figure title
%   tabnames - labels assigned to each tab 
%   tabtxts - descriptive text that preceeds table
%   tables - cell array of tables to be assigned to the tabs
%   isvis  - true sets figure Visible to on, default is off
% OUTPUT
%   varargout: user defined output 
%       h_fig     - handle to figure (handle can be used to modify layout)
% NOTES
%   requires tablefigure.m
%   uses cell array of tables so that tables can vary in size
% SEE ALSO
%   used in muiModelUI.caseCallback and dsproperties.displayDSproperties
%
% Author: Ian Townend
% CoastalSEA (c)Dec 2020
%--------------------------------------------------------------------------
%
    if nargin<5, isvis = false; end  
    h_fig = figure('Name',figtitle,'Tag','TableFig',...
                       'NextPlot','add','MenuBar','none',...
                       'Visible','off');
    h_tab = uitabgroup(h_fig,'Tag','GuiTabs');  
    h_tab.Position = [0 0 1 0.94]; 
    
    ntables = length(tables);
    panpos = zeros(ntables,4); tablepos = panpos;
    for i=1:ntables
        padtabname = sprintf('  %s  ',tabnames{i});
        ht = uitab(h_tab,'Title',padtabname,'Tag',tabnames{i});
        h_tab.SelectedTab = ht;                                 
        tablefigure(h_fig,tabtxts{i},tables{i}); 
        panpobj = findobj(ht,'Tag','TableFig_panel');
        panpos(i,:) = panpobj.Position;
        tableobj = findobj(ht,'Type','uitable');
        tablepos(i,:) = tableobj.Position; 
    end
    h_tab.SelectedTab = h_tab.Children(1);
    
    %adjust size of figure
    maxpanelwidth = max(panpos(:,3));
    maxpanelheight = max(panpos(:,4));
    header = panpos(1,2);
    figwidth = maxpanelwidth+panpos(1,1)+2*tablepos(1,1);
    figheight = maxpanelheight+3.2*header; %header+footer+tab
    h_fig.Position(3) = figwidth;
    h_fig.Position(4) = figheight;   
    if isvis
        h_fig.Visible = 'on';
    end

    output = h_fig; %handles to cross and and circle
    nout = max(nargout,1) - 1;
    for k=1:nout
        varargout{k} = output(k); %#ok<AGROW> 
    end
end