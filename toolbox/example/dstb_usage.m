classdef dstb_usage < handle
%
%-------class help---------------------------------------------------------
% NAME
%   dstb_usage.m
% PURPOSE
%   Class to demonstrate use of dstoolbox
% USAGE
%   dm = dstb_usage;  %instantiate class object
%   run_a_model(dm);  %run model 
%   load_data(dm);    %load a data set 
%   plotCase(dm);     %plot results
%   displayProps(dm); %display DSproperties
% SEE ALSO
%   see test_dstoolbox.m for examples of usage of each class in toolbox
%
% Author: Ian Townend
% CoastalSEA (c)Nov 2020
%--------------------------------------------------------------------------
%   
    properties  
        Models  %holds multiple dstables of model results
        Data    %holds multiple dstables of imported data
        Cases   %case listing using dscatalogue
    end
%%
    methods
        function obj = dstb_usage
            %class constructor
            obj.Cases = dscatalogue; %assigns a new instance
        end
%%        
        function run_a_model(obj)
            %run models and add to the Cases catalogue
            if isempty(obj.Models)
                obj.Models = ds_demoModel.runModel(obj.Cases);
            else
                idx = length(obj.Models)+1;
                obj.Models(idx) = ds_demoModel.runModel(obj.Cases);
            end            
        end
%%
        function load_data(obj)
            %load an imported data set
            if isempty(obj.Data)
                obj.Data = ds_demoData.loadData(obj.Cases);
            else
                idx = length(obj.Data)+1;
                obj.Data(idx) = ds_demoData.loadData(obj.Cases);
            end             
        end
%%
        function plotCase(obj)
            %plot the results for a model or imported data
            [caserec,ok] = selectRecord(obj.Cases);
            if ok<1, return; end
            classrec = classRec(obj,caserec);
            casedef = getRecord(obj.Cases,caserec);                     
            switch casedef.CaseType
                case 'model'
                    mobj = obj.Models(classrec);
                    mobj.Collection.Description = casedef.CaseDescription;
                    modelPlot(mobj);
                case 'data'
                    dobj = obj.Data(classrec);
                    dobj.Collection.Description = casedef.CaseDescription;
                    dataPlot(dobj);
            end
        end
%%
        function displayProps(obj)
            %displeay the metadata properties of a selected case
            [caserec,ok] = selectRecord(obj.Cases);
            if ok<1, return; end
            classrec = classRec(obj,caserec);
            ctype = obj.Cases.Catalogue.CaseType(caserec);
            switch ctype
                case 'model'
                    lobj = obj.Models(classrec);
                case 'data'
                    lobj = obj.Data(classrec);
            end
            displayDSproperties(lobj.Collection.DSproperties);
        end
%%
        function classrec = classRec(obj,caserec)
            %find class record with classid that matches caserec
            casedef = getRecord(obj.Cases,caserec);
            switch casedef.CaseType
                case 'model'
                    lobj = obj.Models;                    
                case 'data'
                    lobj = obj.Data;
            end     
            classrec = find([lobj.ClassIndex]==casedef.CaseID);
        end
    end
end