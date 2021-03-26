classdef dsproperties < matlab.mixin.Copyable
%
%-------class help------------------------------------------------------
% NAME
%   dsproperties.m
% PURPOSE
%   Class to manage the meta-data properties defined in dstable for
%   variables, row and dimensions
% NOTES
%   Options to load data as a nested struct of Variables, Row and Dimensions
%   as a struct array, or single struct of cell arrays when there are
%   multiple variables or dimensions. Variabels, Row and Dimensions can be
%   added, removed and moved as with a table and the 'set' function
%   includes an option to interactively edit each set of properties 
% SEE ALSO
%   see test_dstoolbox.m for examples of usage
%
% Author: Ian Townend
% CoastalSEA (c)Sep 2020
%--------------------------------------------------------------------------
%        
    properties
        DSPdescription %name given to a dsproperty set
        Variables      %struct to hold the metadata properties for a Variable
                       %dstable which are loaded into the
                       %CustomProperties property of a Matlab table 
        % struct includes the following fields            
        % Name  - name used in table to label variable
        % Description - description of variable used in data access UIs
        % Unit  - variable units 
        % Label - axis label for results
        % QCflag - flag to indicate any quality control of data 
        Row           %struct to hold the metadata properties for a Row
        % Name - name for datatype used in table rows
        % Description - description for RowNames in table (usually Time but
        %             rows can be any unique descriptor)              
        % Unit   - units of row data 
        % Label  - axis labels for use with row data 
        % Format - time format to use when saving time data
        %             formats can be durations: y,d,m,s 
        %             or datetime: dd-MMM-uuuu HH:mm:ss 
        Dimensions    %struct to hold the metadata properties for a Dimension
        % Name - stuct name used for dimensions
        % Description - description to be used for x, y and z co-ordinates
        % Unit  - units for the defined co-ordinates
        % Label - axis labels for use with XYZ data  
        % Format - data format to use when saving the dimension
        errmsg        %holds an error message
                      %1) if struct supplied is invalid
                      %2) if variable or dimension names & descriptions are
                      %   not unique
    end
    
    properties (Hidden, Access=private)
        dsPropFields = struct(...
            'Variables',{{'Name','Description','Unit','Label','QCflag'}},...
            'Row',{{'Name','Description','Unit','Label','Format'}},...
            'Dimensions',{{'Name','Description','Unit','Label','Format'}})        
    end
    
    methods
        function obj = dsproperties(dsprops,dsdesc)
            %constructor initialises DSCproperties
            if nargin<2
                dsdesc = '';
            end
                
            if nargin>0 && strcmp(dsprops,'set')
                setDSproperties(obj,[],dsdesc);
            elseif nargin>0 && isstruct(dsprops)
                setDSproperties(obj,dsprops,dsdesc);
            else
                setDSpropsStruct(obj);
            end
        end  
%% ------------------------------------------------------------------------
% Set and Get class properties and add, remove and move methods
%--------------------------------------------------------------------------
        function set.DSPdescription(obj,dspdesc)
            if strcmp(dspdesc,'set')
                existingdesc = obj.DSPdescription;
                obj.DSPdescription  = setDSPdescription(obj,existingdesc);
            else
                obj.DSPdescription = dspdesc;
            end
        end         
%--------------------------------------------------------------------------
%% Variables
%--------------------------------------------------------------------------
        function set.Variables(obj,varprops)  
            %overload set method to allow set to handle varprops as a
            %struct, [] to clear and call using 'set' to intialise UI
            if isstruct(varprops)  
                isvalid = checkPropertyStruct(obj,'Variables',varprops);
                isoknames = checkPropertyNames(obj,'Variables',varprops);
                if isvalid && isoknames
                    obj.Variables = varprops;
                else
                    warndlg('Invalid Variable struct. Properties not loaded');
                end
            elseif isempty(varprops)  %request to clear all properties
                idrec = 1:length(obj.Variables);
                clearDSproperty(obj,'Variables',idrec);
            else                      %call using 'set' but can be anything
                varprops = obj.Variables;
                obj.Variables = setPropertyInput(obj,'Variables',varprops);
            end
        end              
%%
        function rmVariables(obj,varnames)
            %varnames: character vector, cell array of character vectors,
            %string array, numeric array, logical array of the variable to
            %be removed
            clearDSproperty(obj,'Variables',varnames)
        end
%%
        function addVariables(obj,varprops)
            %varprops is a Variables struct, cell array, or just the
            %name of the variable to be added
            if nargin<2 || isempty(varprops)
                obj.Variables = setPropertyInput(obj,'Variables',...
                                                            obj.Variables);
            else
                addPropertyInput(obj,'Variables',varprops);
            end
        end
%%
        function moveVariable(obj,varname,position,location)
            %varname is character vector,string scalar,integer,logical array
            %position is 'Before' or 'After'
            %location is character vector,string scalar,integer,logical array
            moveProperty(obj,'Variables',varname,position,location)
        end
%--------------------------------------------------------------------------
%% Row
%--------------------------------------------------------------------------
        function set.Row(obj,rowprops)
            %overload set method to allow set to handle varprops as a
            %struct, [] to clear and call using 'set' to intialise UI
            if isstruct(rowprops)
                isvalid = checkPropertyStruct(obj,'Row',rowprops);
                if isvalid
                    obj.Row = rowprops;
                else
                    warndlg('Invalid Row struct. Properties not loaded')                    
                end 
            elseif isempty(rowprops)  %request to clear all properties
                clearDSproperty(obj,'Row',obj.Row.Name);
            else                      %call using 'set' but can be anything
                rowprops = obj.Row;
                obj.Row = setPropertyInput(obj,'Row',rowprops);  
            end
        end             
%--------------------------------------------------------------------------
%% Dimensions
%--------------------------------------------------------------------------
        function set.Dimensions(obj,dimprops)
            %overload set method to allow set to handle varprops as a
            %struct, [] to clear and call using 'set' to intialise UI
            if isstruct(dimprops) 
                isvalid = checkPropertyStruct(obj,'Dimensions',dimprops);
                isoknames = checkPropertyNames(obj,'Dimensions',dimprops);
                if isvalid && isoknames
                    obj.Dimensions = dimprops;
                else
                    warndlg('Invalid Dimensions struct. Properties not loaded') 
                end
            elseif isempty(dimprops)  %request to clear all properties
                idrec = 1:length(obj.Dimensions);
                clearDSproperty(obj,'Dimensions',idrec);   
            else                      %call using 'set' but can be anything
                dimprops = obj.Dimensions;
                obj.Dimensions = setPropertyInput(obj,'Dimensions',dimprops);
            end
        end           
%%
        function rmDimensions(obj,dimnames)
            %dimnames: character vector, cell array of character vectors,
            %string array, numeric array, logical array of the dimension to
            %be removed
            clearDSproperty(obj,'Dimensions',dimnames)
        end
%%
        function addDimensions(obj,dimprops)
            %dimprops is a Dimensions struct, cell array, or just the
            %name of the dimension to be added
            if nargin<2 || isempty(dimprops)
                obj.Dimensions = setPropertyInput(obj,'Dimensions',...
                                                          obj.Dimensions);
            else
                addPropertyInput(obj,'Dimensions',dimprops);
            end
        end
%%
        function moveDimension(obj,varname,position,location)
            %varname is character vector,string scalar,integer,logical array
            %position is 'Before' or 'After'
            %location is character vector,string scalar,integer,logical array
            moveProperty(obj,'Dimensions',varname,position,location)
        end
%% --------------------------------------------------------------------------
% dsproperties UI functions
%--------------------------------------------------------------------------
        function setDSproperties(obj,dsprops,dsdesc,isset)
            %interactive UI to define the inputs needed for DSproperties
            if nargin<3
                dsdesc = ''; isset = false;
            elseif nargin<4
                isset = false;
            end
            %
            if ~isstruct(obj.Variables)
                setDSpropsStruct(obj);
            end
            %
            subvars = {'Variables','Row','Dimensions'};
            if nargin>1 && isstruct(dsprops)
                %check that input is a valid struct
                isvalid = validDSproperties(obj,dsprops);
                if ~isvalid
                    warndlg('Input to DSproperties is not a valid struct')
                    return;
                end
                %
                for i=1:3
                    propstruct = dsprops.(subvars{i});
                    if isempty(propstruct)
                        continue;
                    elseif length(propstruct)>1
                        %a struct array has been provided
                        obj.(subvars{i}) = propstruct;
                    else    
                        %assume a struct of cell arrays
                        obj.(subvars{i}) = cellstruct2structarray(propstruct);               
                    end
                end
            else                
                for i=1:3
                    substruct = obj.(subvars{i});
                    obj.(subvars{i}) = setPropertyInput(obj,subvars{i},...
                                                         substruct,isset);
                end
            end
            %
            if isempty(dsdesc)
                obj.DSPdescription = 'set';
            else
                obj.DSPdescription = dsdesc;
            end
        end 
%%
        function displayDSproperties(obj)
            %display the current properties in a tabtablefigure
            tabnames = {'Variables','Row','Dimensions'};
            tabtxt = sprintf('Current definition of DSproperties for %s',obj.DSPdescription);
            
            %generate tables to be displayed
            ntables = length(tabnames);
            tables = cell(ntables,1);
            tabtxts = cell(ntables,1);
            for i=1:ntables
                substruct = obj.(tabnames{i});
                tables{i,1} = struct2table(substruct,'AsArray',true);
                %output summary to tablefigure
                tabtxts{i,1} = tabtxt;
            end            
            
            h_fig = tabtablefigure('DSproperties',tabnames,tabtxts,tables);
            %adjust position on screen            
            h_fig.Position(1)=  h_fig.Position(3)*3/2; 
            h_fig.Visible = 'on';
        end
%%
        function editDSproperty(obj,propname)
            %edit an existing property set of Variables, Row, Dimensions
            props = obj.(propname);
            obj.(propname) = setPropertyInput(obj,propname,props,true);
        end
    end
%% ------------------------------------------------------------------------
% Methods to generate blank struct, set the inputs for any property, 
% check struct is valid, UI for dsp description, id and name of the 
% selected elements in the property struct array, clear, add and move
% fields for element in the struct array of a property (variable, row,
% dimension)
%--------------------------------------------------------------------------
    methods (Access=private)
        function setDSpropsStruct(obj)
            fnames = {'Variables','Row','Dimensions'};
            datacell = cell(5,1);             
            for i=1:length(fnames)
                varnames = obj.dsPropFields.(fnames{i});
                obj.(fnames{i}) = cell2struct(datacell,varnames,1);   
            end             
        end        
%%
        function structdata = setPropertyInput(obj,propname,propstruct,isset)
            %set the inputs for a component of the DSproperties struct
            % propname - Property of class: Variables, Row or Dimensions
            % propstruct - existing structure for Property being set
            % isset - logical flag to indicate whether to prompt for the
            % number of variables or dimensions. No prompt if true. See
            % muiUserModel.setdsp2save for an example of usage.
            if nargin<4, isset = false; end
            structdata = propstruct;              %return same struct if cancelled
            fnames = fieldnames(propstruct);      %substruct fieldnames
            nfields = length(fnames);             %number of fields
            firstfield = propstruct.(fnames{1});
            if length(propstruct)>1
                nexvars = length(propstruct);     %struct array passed in
            elseif iscell(firstfield)             %struct with cell array
                if isempty(firstfield{1})         %empty struct
                    nexvars = 0;
                else                              %cell array
                    existingvars = propstruct.(fnames{1});%values in first field
                    nexvars = length(existingvars);       %number of existing values
                end
            elseif isempty(firstfield)            %empty struct  
                nexvars = 0;
            else                                  %character vector or empty
                nexvars = 1;
            end
            %
            if strcmp(propname,'Row')
                numvars = 1;
            elseif isset
                numvars = length(obj.(propname));
                if isempty(obj.(propname)(1).Name), numvars = 0; end
            else
                %get user to define number of variables or dimensions
                promptxt = sprintf('Number of %s:',propname);
                default = {num2str(nexvars)};
                numvars = inputdlg(promptxt,'DSproperties',1,default);
                if isempty(numvars) || strcmp(numvars{1},'0')
                    %Cancelled or zero variables or dimensions 
                    %check that set to default empty strings
                    return; 
                end
                numvars = str2double(numvars{1});
            end
            %
            for i=1:numvars
                %for each variable/dimension to be included
                if nexvars<i
                    defaults = repmat({''},nfields,1);
                else
                    defaults = struct2cell(propstruct(i));
                    idd = cellfun(@isempty,defaults);
                    defaults(idd)= repmat({''},sum(idd),1);
                    if size(defaults,2)>1
                        defaults = cellfun(@(x) x{i},defaults,'UniformOutput',false); 
                    end
                end
                
                if strcmp(propname,'Row')
                    addtype = @(x) sprintf('%s %s',propname,x);
                else
                    %strip 's' from Variables and Dimensions and 
                    %include variable number in prompt
                    addtype = @(x) sprintf('%s no.%d: %s',propname(1:end-1),i,x);                    
                end
                fprompts = cellfun(addtype,fnames,'UniformOutput',false);
                answers = inputdlg(fprompts,'DSproperties',1,defaults);
                if isempty(answers), answers = defaults; end
                for j=1:nfields
                    %assign each value in struct
                    structdata(i).(fnames{j}) = answers{j};
                end
            end
        end
%%
        function isvalid = validDSproperties(obj,dsprops)
            %check that the input dsprops is a valid DSproperties struct
            %compare input against default struct not existing instance
            objprops = {'Variables';'Row';'Dimensions'};           
            dspnames = fieldnames(dsprops);
            
            if length(dspnames)==3
                isvalid = all(strcmp(objprops,dspnames));
                if ~isvalid, return; end
                %
                for i=1:3
                    varprops = dsprops.(dspnames{i});
                    isvalid = checkPropertyStruct(obj,objprops{i},varprops);
                    if ~isvalid, return; end  %quit when any property fails
                end
            else
                isvalid = false;
            end            
        end
%%
        function isvalid = checkPropertyStruct(obj,propname,varprops)
            %check that property structure is valid
            objfnames = obj.dsPropFields.(propname)'; %required struct fieldnames
            inpfnames = fieldnames(varprops);         %input struct fieldnames
            if length(objfnames)==length(inpfnames)
                isvalid = all(strcmp(objfnames,inpfnames));  
            else
                isvalid = false;
                errtxt = sprintf('Invalid %s in struct in dsproperties',propname);
                obj.errmsg = errtxt;
            end                  
        end
%%
        function isnd = checkPropertyNames(obj,propname,varprops)
            %check that property names and descriptions are unique
            isnd = true;
            varnames = {varprops(:).Name};
            if ~isempty(varnames) && length(varnames)>1
                isnames = isunique(varnames);
                isdesc = isunique({varprops(:).Description});
                isnd = isnames & isdesc;
                if ~isnd
                    errtxt = sprintf('%s names or descriptions are not unique in dsproperties',propname);
                    obj.errmsg = errtxt;
                end
            end
        end
%%
        function dsp_desc = setDSPdescription(~,defaultxt)
        %prompt user for name to use fo the dsproperties object
            if nargin<2 || isempty(defaultxt)
                defaultxt = {''};
            elseif char(defaultxt)
                defaultxt = {defaultxt};
            end
            Prompt = {'DSproperty description'};
            Title = 'DSproperty';
            NumLines = 1;
            %use updated properties to call inpudlg and return new values
            answer=inputdlg(Prompt,Title,NumLines,defaultxt);
            if isempty(answer)
                dsp_desc = defaultxt{1};
            else
                dsp_desc = answer{1};
            end
        end   
%%
        function [selection,msg] = findVarInput(obj,propname,invar)
            %return logical or id array of selection based on inputs that
            %can be character vector, cell array of character vectors,
            %string array, numeric array, logical array
            % propname - dsproperties Property name to search on
            % invar - the var names or indices to be used
            % selection - logical or numeric vector of selected elements
            % msg - cell array of Name fields of the selected elements
            selection = []; msg = [];
            errtxt = sprintf('Could not find selected names in %s',propname);
            
            P = obj.(propname); 
            varnames = arrayfun(@(x) x.Name,P,'UniformOutput',false);
            if isempty(invar)
                return;
            elseif ischar(invar) || iscell(invar) || isstring(invar)
                if isempty(varnames{1})
                    warndlg(errtxt)                    
                    return;
                end
                selection = ismember(varnames,invar); %true if A found in B
                if ~any(selection)                    
                    warndlg(errtxt)
                end
            else
                selection = invar;  %input is numeric or logical
            end
            msg = varnames(selection);     
        end
%%
        function clearDSproperty(obj,propname,varnames)
            %clear all struct properties of selected name/field
            % propname - dsproperties Property name to use
            % varnames - the var names or indices to be deleted
            [selection,msg] = findVarInput(obj,propname,varnames);  
            obj.(propname)(selection) = [];
            %check that cell array is not empty (required for
            % setPropertyInput indexing)
            if isempty(obj.(propname))
                fnames = fieldnames(obj.(propname));
                obj.(propname) = cell2struct(cell(length(fnames),1),fnames);
            end
            %
            if ~isempty(msg)
                getdialog(sprintf('Successfully removed %s\n',string(msg)))
            end
        end
%%
        function addPropertyInput(obj,propname,varnames)
            %add new instances to the struct array of a class Property
            %if varnames is a struct this is added, if it is a cell or 
            %string array of property names these are are added as additional
            %array elements to the propname stuct array.
            % propname - dsproperties Property name to use
            % varnames - the var names or struct to be added
            ndim = length(obj.(propname));
            if ndim==1 && isempty(obj.(propname).Name)
                ndim = 0;    %empty struct
            end
            fnames = fieldnames(obj.(propname));
            nvars = length(varnames);
            if ischar(varnames)
%                 obj.(propname)(ndim+1) = cell2struct(cell(nfields,1),fnames); 
                obj.(propname)(ndim+1).Name = varnames;
            elseif iscell(varnames) || isstring(varnames)
                varnames = convertStringsToChars(varnames);
                if ischar(varnames)
                    obj.(propname)(ndim+1).Name = varnames;
                else
                    for i=1:nvars
                        obj.(propname)(ndim+i).Name = varnames{i};
                    end
                end
            elseif isstruct(varnames)
                isvalid = all(strcmp(fnames,fieldnames(varnames)));
                if isvalid
                    for i=1:nvars
                        obj.(propname)(ndim+i) = varnames(i);
                    end
                else
                    warndlg('Invalid struct. Properties not loaded')
                end
            else
                warndlg('Unknown input format')
            end             
        end
%%
        function moveProperty(obj,propname,varname,position,location)
            %change the position of varname in the propname struct array
            %to the be position/location eg Before 'Var2'
            % propname - dsproperties Property name to use
            % varname - the name of the set of fields to be moved
            % position - before or after
            % locations - the reference name to use for the move
            options = {'Before','After'};
            if ~strcmpi(options,position)
                warndlg('Unknown position')
                return
            end
            %find index of variable to be moved and marker for new location
            [varsel,~] = findVarInput(obj,propname,varname); 
            if islogical(varsel), varsel = find(varsel); end
            [locsel,~] = findVarInput(obj,propname,location); 
            if islogical(locsel), locsel = find(locsel); end
            %determine offset to be used
            offset = 1;
            if strcmpi(position,'Before'), offset = 0; end
            %offset changes depending where new location is relative 
            %to existing position
            if locsel>varsel, offset = offset-1; end
            %save the variable to be moved
            lobj = obj.(propname);
            movestruct = lobj(varsel);
            lobj(varsel) = []; %check that this removes rather than add blank
            %copy the struct to the right of the new location and remove
            tailstruct = lobj(locsel+offset:end);
            lobj(locsel+offset:end) = [];
            obj.(propname) = [lobj,movestruct,tailstruct];
        end
    end
end