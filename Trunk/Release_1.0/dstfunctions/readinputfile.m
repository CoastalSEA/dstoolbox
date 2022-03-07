function [data,header] = readinputfile(filename,nhead,dataSpec)
%
%-------function help------------------------------------------------------
% NAME
%   readinputfile.m
% PURPOSE
%   read data from a file
% USAGE
%   [header,data] = readinputfile(filename,nhead,dataSpec)
% INPUT
%   filename - name of file to be read
%   nhead - number of header lines
%   dataSpec - defines read format (not required if defined in file header)
% OUTPUT
%   data - data set read using dataSpec
%   header - first nhead lines of file
%
% Author: Ian Townend
% CoastalSEA (c)Nov 2020
%--------------------------------------------------------------------------
%
    header = ''; data = [];

    if nhead==0 && (nargin<3 || isempty(dataSpec))
        warndlg('Define read format in call to readinputfile using dataSpec');
        return
    end
    %
    if nargin<3
        dataSpec = [];
    end

    %open file
    fid = fopen(filename, 'r');
    if fid<0
        errordlg('Could not open file for reading','File write error','modal')
        return;
    end

    %read header and data as required
    if nhead>0
        for i=1:nhead
            header{i} = fgets(fid); 
        end
    end

    if isempty(dataSpec)
        dataSpec = header{1}; %format spec MUST be on first line
    end
    %read numeric data            
    data = textscan(fid,dataSpec);
    if isempty(data)
        warndlg('No data. Check file format selected')
    end
    fclose(fid);
end  