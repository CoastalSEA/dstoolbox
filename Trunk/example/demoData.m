classdef demoData < handle
    properties  
        Collection  %holds multiple dstables  
        MetaData   %used to hold additional information about DataSet:  <<REVIEW whether this is the best place for these variables???
        ClassIndex %index of class instance  
    end    
    
    methods (Access = private)
        function obj = demoData()
            %class constructor
        end
    end
%%    
    methods (Static)
        function obj = loadData(catobj)
            %initialise class object
            obj = demoData;
            dsp = dataDSproperties(obj);
            
            %load the data
 
            %load the results into a dstable
            
            dst = dstable(ut,'RowNames',modeltime,'DSproperties',dsp);
            dst.Dimensions.X = xy{:,1};
            dst.Dimensions.Y = xy{:,2};
            obj.Collection = dst;
            %add the run to the catalogue
            obj.ClassIndex = addCase(catobj,'demoModel','data');
        end 
    end
%%
    methods (Access = private)
        function dsp = dataDSproperties(~)
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
                'Format',{''});        
            dsp.Dimensions = struct(...    
                'Name',{'X','Y'},...
                'Description',{'X co-ordinate','Y co-ordinate'},...
                'Unit',{'m','m'},...
                'Label',{'X co-ordinate (m)','Y co-ordinate (m)'},...
                'Format',{'-','-'});  
        end
    end
end