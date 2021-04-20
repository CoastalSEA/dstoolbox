classdef ds_demoData < handle
%
%-------class help------------------------------------------------------===
% NAME
%   ds_demoData.m
% PURPOSE
%   Class to illustrate importing a data set, adding the results to dstable
%   and a record in a dscatlogue with a method to plot the output
% USAGE
%   obj = ds_demoData.loadData(catobj) %where catobj is a handle to a dscatalogue
% SEE ALSO
%   uses dstable and dscatalogue
%
% Author: Ian Townend
% CoastalSEA (c)Oct 2020
%--------------------------------------------------------------------------
%    
    properties  
        Collection  %holds multiple dstables  
    end
    
    properties (Hidden, SetAccess = private)
        ClassIndex %index of class instance  
    end      
    
    methods (Access = private)
        function obj = ds_demoData()
            %class constructor
        end
    end
%%    
    methods (Static)
        function obj = loadData(catobj)
            %read and load a data set from a file
            obj = ds_demoData;               %initialise class object
            [data,~,filename] = readInputData(obj);             
            if isempty(data), obj = []; return; end
            dsp = dataDSproperties(obj);  %initialise dsproperties for data
            
            %load the data
            [data,time] = getData(obj,data,dsp);
            %load the results into a dstable            
            dst = dstable(data{:},'RowNames',time,'DSproperties',dsp);
            %assign metadata about dagta
            dst.Source = filename;
            
            %assign dstable to demoModel Collection property
            obj.Collection = dst;
            %add the run to the catalogue
            obj.ClassIndex = addRecord(catobj,'demoData','data');
        end 
    end
%%
    methods
        function dataPlot(obj)
            %generate plot for display         
            figure;
            
            %get data for variables u10 and dir and dimension t
            dst = obj.Collection;
            t = dst.RowNames;
            u10 = dst.Speed10min;      
            dir = dst.Dir10min;
            %metatdata for model and run case description
            filename = regexp(dst.Source,'\\','split');
            titletext = sprintf('%s\nfile: %s',dst.Description,filename{end});
            
            %generate plot            
            yyaxis left
            plot(t,u10);
            ylabel(dst.VariableLabels{1})
            yyaxis right
            plot(t,dir);
            ylabel(dst.VariableLabels{2})
            title(titletext)
        end   
    end
%%
    methods (Access = private)
        function [data,header,filename] = readInputData(~)
            %read wind data (read format is file specific).
            [fname,path,~] = getfiles('FileType','*.txt');
            filename = [path fname];
            dataSpec = '%d %d %s %s %s %s'; 
            nhead = 1;     %number of header lines
            [data,header] = readinputfile(filename,nhead,dataSpec);
        end     
%%        
        function [varData,myDatetime] = getData(~,data,dsp)
            %format data from file
            mdat = data{1};       %date
            mtim = data{2};       %hour 24hr clock
            idx = mtim==24;
            mdat(idx) = mdat(idx)+1;
            mtim(idx) = 0;
            mdat = datetime(mdat,'ConvertFrom','yyyymmdd');
            mtim = hours(mtim);
            % concatenate date and time
            myDatetime = mdat + mtim;            %datetime for rows
            myDatetime.Format = dsp.Row.Format;
            %remove text string flags
            data(:,3:6) = cellfun(@str2double,data(:,3:6),'UniformOutput',false);
            %reorder to be speed direction speed direction
            temp = data(:,3);
            data(:,3) = data(:,4);
            data(:,4) = temp;
            temp = data(:,5);
            data(:,5) = data(:,6);
            data(:,6) = temp;
            varData = data(1,3:end);             %sorted data to be loaded
        end  
%%        
        function dsp = dataDSproperties(~)
            %define the metadata properties for the demo data set
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
            dsp.Variables = struct(...   %cell arrays can be column or row vectors
                'Name',{'Speed10min','Dir10min','Speed1hr','Dir1hr'},...
                'Description',{'Mean wind speed 10min','Mean wind direction 10min',...
                   'Mean wind speed 1hr','Mean wind direction 1hr'},...
                'Unit',{'m/s','deg','m/s','deg'},...
                'Label',{'Wind speed (m/s)','Wind direction (deg)',...
                   'Wind speed (m/s)','Wind direction (deg)'},...
                'QCflag',{'raw','raw','raw','raw'}); 
            dsp.Row = struct(...
                'Name',{'Time'},...
                'Description',{'Time'},...
                'Unit',{'h'},...
                'Label',{'Time'},...
                'Format',{'dd-MM-uuuu HH:mm:ss'});        
            dsp.Dimensions = struct(...    
                'Name',{''},...
                'Description',{''},...
                'Unit',{''},...
                'Label',{''},...
                'Format',{''});  
        end
    end
end