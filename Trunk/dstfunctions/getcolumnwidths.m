function [rowwidth,colwidth,tableheight] = getcolumnwidths(datatxt,coltxt,rowtxt)
%
%-------function help------------------------------------------------------
% NAME
%   getcolumnwidths.m
% PURPOSE
%   Find the extent of text in each column (including the header), and the
%   row text (if included)
% USAGE
%   [rowwidth,colwidth,tableheight] = getcolumnwidths(datatxt,coltxt)
% INPUTS
%   datatxt  - cell array of default data strings or table
%   coltxt   - cell array of column header text (optional)
%   rowtxt   - cell array of row label text (optional)
% OUTPUT
%   rowwidth - width required for text in row column in pixels
%   colwidth - width required for text in each column in pixels
%   tableheight - height of datatxt table (nrows x textheight in pixels).
% SEE ALSO
%   used in tablefigure.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    if nargin<2
        if istable(datatxt)
            coltxt = datatxt.Properties.VariableNames;
            rowtxt = datatxt.Properties.RowNames;
        else
            coltxt = [];
            rowtxt = [];
        end
    elseif nargin<3
        rowtxt = [];
    end
    %     
    if iscell(datatxt)
        datatxt = cell2table(datatxt);
        if isempty(coltxt)
            coltxt = datatxt.Properties.VariableNames;
        else
            datatxt.Properties.VariableNames = coltxt;
        end
    end
    
    %use text uicontrol and Extent to find size of text in points
    h_fig = figure('Tag','uicFig','MenuBar','none','Visible','off');                       
    uic = uicontrol(h_fig,'Style','text','Units','pixels');
    minwidth = getstringextent(uic,num2str(pi()))*2;             %3.1416
    [maxwidth,rh] = getstringextent(uic,repmat('X',1,100)); %100 characters
    tableheight = rh*height(datatxt);
    tablefunc = @(x) getstringextent(uic,x);
    
    %scroll through columns finding maximum size then check limits
    ncol = length(coltxt);
    nrow = height(datatxt);
    colwidth = zeros(1,ncol);
    for j=1:ncol
        lenvar = zeros(1,nrow);
        for i=1:nrow
            lenvar(i) = getstringextent(uic,datatxt{i,j});
        end
        colwide = getstringextent(uic,coltxt{j});
        colwidth(j) = ceil(max([colwide,max(lenvar)]));
    end   
    colwidth(colwidth<minwidth) = minwidth;
    colwidth(colwidth>maxwidth) = maxwidth;
    
    %check row text for maximum width
    if isempty(rowtxt)
        rowtxt = cellstr(num2str((1:height(datatxt))'));
    end    
    funcel = @(x) max(cellfun(tablefunc,x));
    rowwidth = funcel(rowtxt);
    delete(h_fig);
end

function [varlen,varhght] = getstringextent(uic,strvar)
    %return the size of the text string in the units of uic
    if ischar(strvar)
        uic.String = strvar;
    elseif iscell(strvar)
        if islogical(strvar{1})
            uic.String =  num2str(strvar{1});
        elseif isstruct(strvar{1})
            fnames = fieldnames(strvar{1});
            flen = cellfun(@length,fnames);
            [~,imax] = max(flen);
            uic.String = fnames{imax};
        else
            uic.String = strvar{1};
        end
    elseif isnumeric(strvar)
        uic.String = num2str(strvar);
    end
    varlen = uic.Extent(3);
    varhght = uic.Extent(4);
end
    
    