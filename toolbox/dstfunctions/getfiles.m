function [fname,path,nfiles] = getfiles(varargin)
%
%-------function help------------------------------------------------------
% NAME
%   getfiles.m
% PURPOSE
%  prompt user to select file, or multiple files if mflag='on'
% USAGE
%   [fname,path,nfiles] = getfiles(Name,Value)

% INPUT
%  Name, Value options are specified as comma-separated pairs including:
%  'MultiSelect', mflag, where mflag can be 'on' or 'off' and determines
%                        whether multi file selection is allowed. The 
%                        default is off.
%  'FileType', filetype, where filetype can be a character vector (default)
%                        character vector,cell array of character vectors,
%                        string array specifying. The default is '*.*'
%   'PromptText', ptext  where ptext is a text string (optional).
% OUTPUT
%   fname - selected files, cell array if mflag='on', else character array
%   path - folder location of files
%   nfiles - number of files selected
% NOTES
%   default with no input argument is single selection of *.* files 
%   to check if user cancelled:
%   (i) single selection:   if fname==0, outputs = []; return; end
%   (ii) multi selection:   if isnumeric(fname) && fname==0, outputs = []; return; end
% SEE ALSO
%  Matlab uigetfile
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2020
%--------------------------------------------------------------------------
%
    % ask for filename(s)-multiple selection allowed if mflag='on'
    mflag = 'off';
    filetype = '*.*';
    userprompt = 'Select data file(s)>';
    if nargin>1
        for k=1:2:length(varargin) %unpack values for varargin to v
            if strcmp(varargin{k},'MultiSelect')
                mflag = varargin{k+1};
            elseif strcmp(varargin{k},'FileType')
                filetype = varargin{k+1};
            elseif strcmp(varargin{k},'PromptText')
                userprompt = varargin{k+1};
            end
        end
    end

    [fname, path]=uigetfile(filetype,userprompt,'MultiSelect',mflag);
    %get number of files if multiple selection
    if iscell(fname)
        nfiles = length(fname);
    else
        if fname==0 %user has cancelled - no file selected
            nfiles = 0;
        elseif strcmp(mflag,'on')   %if multiple select
            nfiles = 1;
            fname = cellstr(fname); %return fname as a cell array
        else
            nfiles = 1;             %fname is a character array
        end
    end
end