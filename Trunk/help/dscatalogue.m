%% dscatalogue
% dscatalogue manages a catalogue of data sets

%% Syntax
%%
%   dsc = dscatalogue;             %creates an empty dscatalogue
%

%% Description
% Maintains a catalogue of cases that can be a mix of data types (e.g.
% model and measured data) and created by different classes. Each record is
% given and unique case identifier (CaseID), which is distinct from the
% number (row) of the record (CaseRec). 

%% Properties
% *Catalogue* holds a <matlab:doc('table') table> of the case definition.
% The Catalogue includes the following fields: <br>
% _CaseID_ - unique identifier for each record <br>  
% _CaseDescription_ - data set specific record description <br>
% _CaseClass_ - class of data set to be catalogued <br>
% _CaseType_ - type of data set (e.g. keywords: model, data)
%%
% The Catalogue table fields can be accessed using standard table notation, e.g:
%%
%   dst.Catalogue.CaseClass(rowidx)  %rowidx is the index of the row(s) to be returned
%   
%%
%% dscatalogue methods
% the dscatalogue methods allow cases to be added, removed and the case
% description to be edited

%%
% *addCase* - add a case definition to the catalogue
%%
%   recnum = addCase(dsc,caseclass,casetype,casename); %casename is optional

%%
% *removeCase* - select one or more records and delete records from catalogue 
%%
%   caserec = removeCase(dsc,caserec)'; %returns list of deleted records (caserec)
%                                       %uses list dialogue selection if caserec is not supplied
                                     
%%
% *getCase* - return case for the caserec record 
%%
%   casedef = getCase(dsc,caserec);     %casedef is a table of the selected record
%                                       %uses list dialogue selection if caserec is not supplied

%%
% *editDescription* - edit case description of the caserec record
%%
%   [caserec,newdesc] = editDescription(dsc,caserec);   %caserec is optional 
%                                       %uses list dialogue selection if caserec is not supplied

%%
% *selectCase* - list dialogue box of the cases in the catalogue
%%
%   [caserec,ok] = selectCase(dsc,Name,Value);
%%
% Name, Value pairs are specified as comma-separated pairs and include the following options: <br>
% 'CaseClass', {'class'} - cell array of classes to include in the list <br>
% 'CaseType', {'type'} - cell array of types to include in the list <br>
% 'PromptText', 'prompt_text' - defines the user prompt in the list dialogue <br>
% 'ListSize', [width,height] - defines the dimensions of the list dialogue <br>
% 'SelectionMode', 'mode' - list selection mode, either 'multiple' or 'single'
%%
% _selectCase_ outputs: <br>
% caserec - the record number of the selected case or cases <br> 
% ok - The selection logical value indicates whether the user made a 
% selection. If the user clicks OK, double-clicks a list item, or presses 
% Return, then the ok return value is 1. If the user clicks Cancel, presses 
% Esc, or clicks the close button (X) in the dialog box title bar, then the 
% ok return value is 0.

%%
% *caseRec* - find caserec using caseid
%%
%   caserec = caseRec(dsc,caseid);    

%%
% *caseID* - find caseid using caserec
%%
%   caseid = caseID(dsc,caserec)
