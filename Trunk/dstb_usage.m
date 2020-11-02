classdef dstb_usage < handle
%
%-------class help---------------------------------------------------------
% NAME
%   dstb_usage.m
% PURPOSE
%   Class to demonstrate use of dstoolbox
% NOTES
%   
% SEE ALSO
%   see test_dstoolbox.m for examples of usage 
%
% Author: Ian Townend
% CoastalSEA (c)Sep 2020
%--------------------------------------------------------------------------
%   
    properties  
        Models  %holds multiple dstables - index using dsTableNames
        Data
        Cases = dscatalogue
    end
%%
    methods
        function obj = dstb_usage
            %class constructor
        end
%%        
        function run_a_model(obj)
            %run models and add to the Cases catalogue
            if isempty(obj.Models)
                obj.Models = demoModel.runModel(obj.Cases);
            else
                idx = length(obj.Models)+1;
                obj.Models(idx) = demoModel.runModel(obj.Cases);
            end            
        end
%%
        function load_data(obj)
            if isempty(obj.Data)
                obj.Models = demoData.loadData(obj.Cases);
            else
                idx = length(obj.Data)+1;
                obj.Models(idx) = demoData.loadData(obj.Cases);
            end             
        end
%%
        function plotCase(obj)
            [caserec,ok] = selectCase(obj.Cases);
            if ok<1, return; end
            ctype = obj.Cases.Catalogue.CaseType(caserec);
            switch ctype
                case 'model'
                    mobj = obj.Models(caserec);
                    modelPlot(mobj);
                case 'data'
                    
            end
        end
%%
        function displayProps(obj)
            [caserec,ok] = selectCase(obj.Cases);
            if ok<1, return; end
            mobj = obj.Models(caserec);
            displayDSproperties(mobj.Collection.DSproperties);
        end
    end
    
    
%setup data class derived from dscollection and add record to dscatalogue
%retrieve record
%subsample record using dimensions
%plot

end