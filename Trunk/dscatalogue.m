classdef dscatalogue < handle
%
%-------class help---------------------------------------------------------
% NAME
%   dscatalogue.m
% PURPOSE
%   Class to manage catalogue of records held
% NOTES
%   Requires R2018a for syntax to create empty table in catalogueTable
%   Uses strings and double quotes which requires R2017a
% SEE ALSO
%   Called by models and data import functions to save results as a Case
%   see test_dstoolbox.m for examples of usage
%
% Author: Ian Townend
% CoastalSEA (c)Sep 2020
%--------------------------------------------------------------------------
% 
    properties        
        Catalogue    %table of case definition. Table holds records for:        
                     %  CaseID           %unique identifier for each record  
                     %  CaseDescription  %data set specific record description
                     %  CaseClass        %class of data set to be catalogued
                     %  CaseType         %type of data set (e.g. keywords: model, data)
    end
    
    methods
        function obj = dscatalogue
            %constructor to initialise object
            catalogueTable(obj);
        end
%% ------------------------------------------------------------------------
% functions to add, get and remove Cases
%--------------------------------------------------------------------------
        function recnum =addCase(obj,caseclass,casetype,casename)
            %add a Case record to the catalogue   
            % caseclass - class of data set to be catalogued
            % casetype  - type of data set (e.g. keywords: model, data)
            % casename  - description of case (optional)
            if nargin<4
                casename = {''};
            end  

            SupressPrompts = false;
            [recnum,caseid,casedesc] = addRecord(obj,SupressPrompts,casename);
            newrec = {caseid,casedesc,caseclass,casetype};
            obj.Catalogue = [obj.Catalogue;newrec];            
        end
%%        
        function casedef = getCase(obj,caserec)
            %find case record using caserec
            %caserec - index in current Catalogue
            %returns a table with the definition for the selected record
            casedef = obj.Catalogue(caserec,:);
        end    
%%
        function caserec = removeCase(obj,caserec)
            %select one or more records and delete records from catalogue 
            if nargin<2 || isempty(caserec)
                [caserec,ok] = selectCase(obj,'PromptText','Select case:',...
                              'ListSize',[250,200],'SelectionMode','multiple');
                if ok<1, return; end 
            end
            %delete selected records
            obj.Catalogue(caserec,:) = [];
        end   
%%      
        function [caserec,newdesc] = editDescription(obj,caserec)
            %edit case description of the caserec record
            if nargin<2 ||  isempty(caserec)
                [caserec,ok] = selectCase(obj,'PromptText','Select case:',...
                                                'ListSize',[250,200]);
                if ok<1, return; end
            end
            %now allow user to edit existing description            
            intext = obj.Catalogue.CaseDescription(caserec);
            promptxt = 'Edit case description';
            dlgtxt = 'Edit Case';
            dlgopt.Resize = 'on';
            newdesc = inputdlg(promptxt,dlgtxt,1,intext,dlgopt);  
            if isempty(newdesc), return; end
            obj.Catalogue.CaseDescription(caserec) = newdesc;
        end
%%
       function [caserec,ok] = selectCase(obj,varargin)  %was ScenarioList
            %generate a list dialogue box of the cases available
            % varargin - options for subselection from full catalogue
            %  'CaseClass' - cell array of classes to select
            %  'CaseType'  - cell array of data types to select
            %  'PromptText'- text string to use for dialogue prompt
            %  'ListSize;  - size of dialogue figure, default is [100,200]
            %  'SelectionMode' - 'single' (default) or 'multiple' selections allowed
            % returns caserec - the selected record number(s) and the 
            % ok flag. ok = 
            
            caserec = []; ok = 0; idc = []; idt = [];
            if isempty(obj.Catalogue), noCases(obj); return; end
            v.CaseClass = {};
            v.CaseType  = {};
            v.PromptText = 'Select Scenario'; %default if not set by input
            v.ListSize = [100,200];           %default if not set by input
            v.SelectionMode = 'single';       %default if not set by input
            fnames = fieldnames(v);
            if nargin>1
                for k=1:2:length(varargin) %unpack values for varargin to v
                    if any(strcmp(fnames,varargin{k}))
                        v.(varargin{k}) = varargin{k+1};
                    end
                end
            end
            caselist = obj.Catalogue.CaseDescription;
            caseclass = obj.Catalogue.CaseClass;
            casetype = obj.Catalogue.CaseType;
            
            if ~isempty(v.CaseClass)
                idc = find(strcmp(v.CaseClass,caseclass));
            end
            %
            if ~isempty(v.CaseType)
                idt = find(strcmp(v.CaseType,casetype));
            end
            
            idx = union(idc,idt);
            if ~isempty(idx)
                caselist = caselist(idx);
            end
            if isempty(caselist), return; end
            
            [subrecnum,ok] = listdlg('Name','Case List', ...
                'ListSize',v.ListSize,...
                'PromptString',v.PromptText, ...
                'SelectionMode',v.SelectionMode, ...
                'ListString',caselist);
            
            if ~isempty(subrecnum) && ~isempty(idx)                
                caserec = idx(subrecnum);
            else
                caserec = subrecnum;
            end
       end
%%
        function caserec = caseRec(obj,caseid)
            %find caserec given caseid
            caserec = find(obj.Catalogue.CaseID==caseid);
        end
%%
        function caseid = caseID(obj,caserec)
            %find caseid given caserec
            caseid = obj.Catalogue.CaseID(caserec);
        end        
    end
%% ------------------------------------------------------------------------
% functions to handle Record lists, editing, save and delete
%--------------------------------------------------------------------------    
    methods (Access = private)  
        function [recnum,caseid,casedesc] = addRecord(obj,SupressPrompts,casename)
            %add a Case and get user to provide a description
            % SupressPrompts is a logical flag to supress UI call if true
            % casename is a cell character vector to be used as casedesc
            % recnum is the number of the record in the current list
            % caseid is the unique id for the record
            % casedesc is the user or default case desctiption
            recnum = height(obj.Catalogue)+1; %number of cases
            if isempty(obj.Catalogue)
                caseid = 1;
            else
                CaseID = obj.Catalogue.CaseID;                
                caseid =max(CaseID)+1;   %next case id number-can be different
            end                          %to nrec if cases have been deleted
%             obj.CaseID(recnum) = caseid; 
            %
            if nargin<3
                casename = {''};
            elseif any(strcmp(obj.Catalogue.CaseDescription,casename))
                nval = sum(strcmp(obj.Catalogue.CaseDescription,casename));
                casename = {sprintf('%s_%d',casename{1},nval)};
            end
            %
            if SupressPrompts  %supress prompt if true
                answer = casename;
            else
                answer = inputdlg('Case Description','Case',1,casename);
            end
            %
            if isempty(answer) || strcmp(answer,'')
                casedesc = sprintf('Case no: %g',caseid);
            else
                casedesc = answer{1};
            end
        end           
%%
        function noCases(~)
            warndlg('No cases available');
        end
%%     
        function catalogueTable(obj)
            %set up empty table for catalogue           
            variable_names_types = [["CaseID", "int32"]; ...
                                    ["CaseDescription", "string"]; ...
                                    ["CaseClass", "string"]; ...
                                    ["CaseType", "string"]];
            
            % Make table using fieldnames & value types from above (requires R2018a)
            obj.Catalogue = table('Size',[0,size(variable_names_types,1)],...
                'VariableNames', variable_names_types(:,1),...
                'VariableTypes', variable_names_types(:,2));
        end
    end 
end