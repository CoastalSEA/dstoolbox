classdef ds_demoModel < handle
%
%-------class help------------------------------------------------------===
% NAME
%   ds_demoModel.m
% PURPOSE
%   Class to illustrate running a model, adding the results to dstable and
%   a record in a dscatlogue with a method to plot the output
% USAGE
%   obj = ds_demoModel.runModel(catobj) %where catobj is a handle to a dscatalogue
% SEE ALSO
%   uses diffusion2Dmodel.m based on code by Suraj Shanka, (c) 2012,
%   (fileexchange/diffusion-in-1d-and-2d), and dstable and dscatalogue
%
% Author: Ian Townend
% CoastalSEA (c)Oct 2020
%--------------------------------------------------------------------------
%         
    properties  
        Collection  %holds dstables from multiple runs
    end
    
    properties (Hidden, SetAccess = private)
        ClassIndex %index of class instance  
        VersionNo = 1.0
    end    
    
    methods (Access = private)
        function obj = ds_demoModel()
            %class constructor
        end
    end
%%    
    methods (Static)
        function obj = runModel(catobj)
            %initialise class object
            obj = ds_demoModel;
            dsp = modelDSproperties(obj);
            
            %run the diffusion2Dmodel
            [inp,run] = ds_demo_inputprops();
            [ut,xy,modeltime] = diffusion2Dmodel(inp,run);
            modeltime = seconds(modeltime);  %durataion data for rows
            %load the results into a dstable            
            dst = dstable(ut,'RowNames',modeltime,'DSproperties',dsp);
            dst.Dimensions.X = xy{:,1};   %grid x-coordinate
            dst.Dimensions.Y = xy{:,2};   %grid y-coordinate
            %assign metadata about model
            dst.Source = 'diffusion2Dmodel';
            d = cellstr(datetime(now,'ConvertFrom','datenum'));
            dst.MetaData = sprintf('Run on %s, using v%.1f',d{1},obj.VersionNo);
            
            %assign dstable to demoModel Collection property
            obj.Collection = dst;
            %add the run to the catalogue
            obj.ClassIndex = addRecord(catobj,'demoModel','model');
        end 
    end
%%
    methods
        function modelPlot(obj)
            %generate plot for display         
            src = figure;
            %get data for variable and dimensions x,y,t
            dst = obj.Collection;
            t = dst.RowNames;
            u = dst.u;            
            x = dst.Dimensions.X;
            y = dst.Dimensions.Y;
            %metatdata for model and run case description
            txt1 = sprintf('%s using %s',dst.Description,dst.Source);
            
            %generate base plot
            ax = axes('Parent',src,'Tag','Surface');
            ui = squeeze(u(1,:,:))';
            h = surf(ax,x,y,ui,'EdgeColor','none'); 
            shading interp
            axis ([0 max(x) 0 max(y) 0 max(u,[],'all')])
            h.ZDataSource = 'ui';
            xlabel('X co-ordinate'); 
            ylabel('Y co-ordinate');  
            zlabel('Transport property') 
           
            %animate plot as a function of time
            hold(ax,'on')
            ax.ZLimMode = 'manual';
            for i=2:length(t)
                ui = squeeze(u(i,:,:))'; %#ok<NASGU>
                refreshdata(h,'caller')
                txt2 = sprintf('Time = %s', string(t(i)));
                title(sprintf('%s\n %s',txt1,txt2))
                drawnow; 
            end
            hold(ax,'off')
        end          
    end  
%%    
    methods (Access = private)
        function dsp = modelDSproperties(~)
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
            dsp.Variables = struct(...   %cell arrays can be column or row vectors
                'Name',{'u'},...
                'Description',{'Transport property'},...
                'Unit',{'m/s'},...
                'Label',{'Transport property'},...
                'QCflag',{'model'}); 
            dsp.Row = struct(...
                'Name',{'Time'},...
                'Description',{'Time'},...
                'Unit',{'s'},...
                'Label',{'Time (s)'},...
                'Format',{'s'});        
            dsp.Dimensions = struct(...    
                'Name',{'X','Y'},...
                'Description',{'X co-ordinate','Y co-ordinate'},...
                'Unit',{'m','m'},...
                'Label',{'X co-ordinate (m)','Y co-ordinate (m)'},...
                'Format',{'-','-'});  
        end
    end
end