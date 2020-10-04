classdef dscatalogue < handle
%
%-------class help------------------------------------------------------
% NAME
%   dscatalogue.m
% PURPOSE
%   Class to manage catalogue of cases held
% NOTES
%   Requires R2018a for syntax to create empty table in catalogueTable
%   Uses strings and double quotes which require R2017a
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
                     %  CaseID           %unique identifiers for each case
                     %  CaseDescription  %run specific case description
                     %  CaseClass        %class of data set to be catalogued
                     %  CaseType         %type of data set (keywords: model, data)
    end

    methods
        function obj = dscatalogue
            %constructor to initialise object
            catalogueTable(obj);
        end
%%
        function recnum =setCase(obj,caseclass,casetype,casename)
            %add a Case record to the catalogue           
            if nargin<4
                casename = {''};
            end  

            SupressPrompts = false;
            [recnum,caseid,casedesc] = addRecord(obj,SupressPrompts,casename);
            newrec = {caseid,casedesc,caseclass,casetype};
            obj.Catalogue = [obj.Catalogue;newrec];            
        end
%%        
        function casedef = getCase(obj,caserec,caseid)
            %find case record using either caseid or caserec
            %caseid - unique identifier of case 
            %caserec - index in current Cases list
            %returns a table with the definition for the selected record
            if isempty(caserec) && nargin>2
                caserec = find(obj.Catalogue.CaseID==caseid);
            elseif isempty(caserec)
                casedef = [];
                return;
            end
            %
            casedef = obj.Catalogue(caserec,:);
        end
% %%
%         function saveCase(obj)  %%not sure this is in the right class
%             %write the results for a selected case to an excel file
%             [caserec,ok] = selectRecord(obj,'PromptText','Select case:',...
%                                                     'ListSize',[250,200]);
%             if ok<1, return; end 
%         end          
% %%
        function caserec = deleteRecords(obj)
            %select one or more records and delete records from catalogue 
            %and class instances
            [caserec,ok] = selectRecord(obj,'PromptText','Select case:',...
                          'ListSize',[250,200],'SelectionMode','multiple');
            if ok<1, return; end            
            %sort in reverse order so that record ids do not change as deleted
            obj.Catalogue(caserec,:) = [];
        end       

% %%
%         function reloadCase(obj,mobj,caserec)  
%             %reload model input variables as the current settings
%             if nargin<3  %if case to reload has not been specified
%                 [caserec,ok] = selectRecord(obj,'PromptText','Select case:',...
%                                       'CaseType','model','ListSize',[250,200]);
%                 if ok<1, return; end  
%             end
%             
%             
%             
%         end
% %% 
%         function viewCaseSettings(obj,mobj,caserec)
%             %view the saved input data for a selected Case
%             if nargin<3  %if case to reload has not been specified
%                 [caserec,ok] = selectRecord(obj,'PromptText','Select case:',...
%                                       'CaseType','model','ListSize',[250,200]);
%                 if ok<1, return; end  
%             end
%             
%             retrieve details from selected data/model class for table
%             
%         end
%--------------------------------------------------------------------------
% functions to handle Record lists, editing, save and delete
%--------------------------------------------------------------------------
       function [caserec,ok] = selectRecord(obj,varargin)  %was ScenarioList
            %generate a list dialogue box of the cases available
            % casedef - table row record of the selected case
            % varargin - options for subselection from full catalogue
            %  'CaseClass' - cell array of classes to select
            %  'CaseType'  - cell array of data types to select
            %  'PromptText'- text string to use for dialogue prompt
            %  'ListSize;  - size of dialogue figure, default is [100,200]
            %  'SelectionMode' - 'single' (default) or 'multiple' selections allowed
            caserec = []; ok = 0; idc = []; idt = [];
            if isempty(obj.Catalogue), noCases(obj); return; end
            v.CaseClass = {};
            v.CaseType  = {};
            v.PromptText = 'Select Scenario'; %default if no varargin
            v.ListSize = [100,200];           %default if no varargin
            v.SelectionMode = 'single';       %default if no varargin
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
        function [caserec,newdesc] = editRecord(obj,caserec)
            %edit case record description
            if nargin<2
                [caserec,ok] = selectRecord(obj,'PromptText','Select case:',...
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
    end
%%    
    methods (Access = private)  
        function [recnum,caseid,casedesc] = addRecord(obj,SupressPrompts,casename)
            %add a Case and get user to provide a description
            %recnum is the number of the record in the current list
            %caseid is the unique id for the record
            %casedesc is the user or default case desctiption
            recnum = height(obj.Catalogue)+1; %number of cases
            if isempty(obj.Catalogue)
                caseid = 1;
            else
                CaseID = obj.Catalogue.CaseID;                
                caseid =max(CaseID)+1;   %next case id number-can be different
            end                         %to nrec if cases have been deleted
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
%         function deleteRecord(obj,caserec)
%             %delete selected record
%             obj.Catalogue(caserec,:) = [];
%         end    
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