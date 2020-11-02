classdef demoModel < handle
    properties  
        Collection  %holds multiple dstables
        %dsTables   
        MetaData   %used to hold additional information about DataSet:  <<REVIEW whether this is the best place for these variables???
        %DataType          %type of data input (used to limit selection in listdlg)
        %   OutputStyle       %output style when writing data to Excel file
        %   DefaultDimension  %default dimension for plotting (row.Name or dim.Name) 
        %   ModelVersion
        %   ModelRunDate
        RunData    %instance of runproperties class with details of data used
        ClassIndex %index of class instance  
    end    
    
    methods (Access = private)
        function obj = demoModel()
            %class constructor
        end
    end
%%    
    methods (Static)
        function obj = runModel(catobj)
            %initialise class object
            obj = demoModel;
            dsp = modelDSproperties(obj);
            
            %run the diffusion2Dmodel
            [ut,xy,modeltime] = diffusion2Dmodel();
            modeltime = seconds(modeltime);  %durataion data for rows
            modeltime.Format = dsp.Row.Format;
            %load the results into a dstable            
            dst = dstable(ut,'RowNames',modeltime,'DSproperties',dsp);
            dst.Dimensions.X = xy{:,1};   %grid x-coordinate
            dst.Dimensions.Y = xy{:,2};   %grid y-coordinate
            obj.Collection = dst;
            %add the run to the catalogue
            obj.ClassIndex = addCase(catobj,'demoModel','model');
        end 
    end
%%
    methods
        function modelPlot(obj)
            %generate plot for display on Plot tab
            %data is retrieved by GUIinterface.getTabData            
            src = figure;
            
            dst = obj.Collection;
            t = dst.RowNames;
            u = dst.u;            
            x = dst.Dimensions.X;
            y = dst.Dimensions.Y;

            ax = axes('Parent',src,'Tag','Surface');
            ui = squeeze(u(1,:,:))';
            h = surf(ax,x,y,ui,'EdgeColor','none'); 
            shading interp
            axis ([0 max(x) 0 max(y) 0 max(u,[],'all')])
            h.ZDataSource = 'ui';
            xlabel('X co-ordinate'); 
            ylabel('Y co-ordinate');  
            zlabel('Transport property')  
            hold(ax,'on')
            ax.ZLimMode = 'manual';
            for i=2:length(t)
                ui = squeeze(u(i,:,:))'; %#ok<NASGU>
                refreshdata(h,'caller')
                txt1 = sprintf('2-D Diffusion');
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
                'Format',{'hh:mm:ss.SSS'});        
            dsp.Dimensions = struct(...    
                'Name',{'X','Y'},...
                'Description',{'X co-ordinate','Y co-ordinate'},...
                'Unit',{'m','m'},...
                'Label',{'X co-ordinate (m)','Y co-ordinate (m)'},...
                'Format',{'-','-'});  
        end
    end
end