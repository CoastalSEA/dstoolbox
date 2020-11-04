classdef dstable < dynamicprops & matlab.mixin.SetGet & matlab.mixin.Copyable
%
%-------class help------------------------------------------------------
% NAME
%   dstable.m
% PURPOSE
%   A dstable object is a collection of one or more datasets with one
%   or more common dimension vectors. Collections of datasets are useful 
%   for storing, manipulating and analyzing model and measured datasets.
%   The data can be multi-dimensional and is held in a Matlab(c) table with
%   additional metadata to define variables, rows and dimensions.
% NOTES
%   The DataTable property holds the Matlab(c) table 
%   All additional properties are added as CustomProperties to the table in
%   a dsproperties struct or a dsproperties object
% SEE ALSO
%   see test_dstoolbox.m for examples of usage
%
% Author: Ian Townend
% CoastalSEA (c)Sep 2020
%--------------------------------------------------------------------------
%     
    properties
        %Extend default table properties to include dimensions and
        %additional metadata as defined by dsproperties class
        
        DataTable    %table with properties assigned using Dependent properties
    end
    
    properties (Hidden, SetAccess = private)
        RowType         %records the data type - used by RowNames set and get
        DimType         %records the data type - used by Dimensions set and get
        DimPropsType    %dimension properties assigned as table or variable
        VariableRange   %min and max values of variable (auto loaded)
        RowRange        %min and max values of row (auto loaded)
        DimensionRange  %min and max values of dimension (auto loaded)                
    end
    
    properties (Dependent=true)
        %properties defined in tablename.Properties.PropertyName are
        %defined as Dependent to provide short syntax access for
        %dstables (e.g. dst.PropertyName)
        %Standard matlab(c) table properties
        
        Description          %summary description of dstable
        TableRowName         %labels row column
        RowNames             %distinct non-empty values to define each row
        UserData             %free for user assignment        
        VariableNames        %name of each variable (checked for variable compliance)
        VariableDescriptions %text to describe each variable
        VariableUnits        %units used for each variable          
        CustomProperties     %object for table or variable metadata 
        %Additional dstable properties
        
        Dimensions %struct for each dimension included, with fieldnames 
                   % defined in DimensionNames
                   %use addCustomProperties to make Dimensions Table, or
                   % Variable specific        
        %All additional variables are cell arrays of character vectors, 
        %or string arrays
        %Labels can be used to define generic summaries of variables
        %e.g plotting different variables of the same type but labelling 
        %the axis with a common label. For example:
        %   variables: Vel1, Vel2, Vel2 all labelled 'Velocity (m/s)'
        
        %Additional Variable metatdata
        
        VariableLabels        %labels for generic outputs
        VariableQCflags       %flag to indicate any quality control of data 
        
        %Additional Row metadata
        
        RowDescription        %text to describe row usage
        RowUnit               %unit used for row data (if used)
        RowLabel              %label for generic outputs
        RowFormat             %datetime or duration format (if used)         
        
        %Dimensions propety metatdata
        
        DimensionNames        %name of each dimenions (distinct from property in table)      
        DimensionDescriptions %text to describe each dimension
        DimensionUnits        %units used for each dimension
        DimensionLabels       %labels for generic outputs
        DimensionFormats      %datetime or duration format (if used) 
                             
        %Additional metadata
        
        Source     %source of dst - model name or input file name
        MetaData   %detailed description of dstable (e.g. how derived)
    end
    
    properties (Transient)
        %a dsproperties object is used to define metadata for a dstable
        
        DSproperties = dsproperties   %to define call setDSproperties in class constructor
%         dspstruct = dsproperties      %empty DSP struct (defines fieldnames))
    end
   
%% CONTENTS
%   constructor methods
%   dstable property Set and Get methods
%   dstable functions getDStable, getDataTable, addvars, removevars,  
%       movevars, horzcat, vertcat, plot
%       get and set DSproperties, setDimensions2Table, setDimensions2Variable
%       dst2tsc
    
    methods
        function obj = dstable(varargin)  
            %constructor for the dstable class
            if nargin<1
                %empty dstable
                obj.DataTable = table;
                %add default properties used by dstables
                addDefaultProperties(obj);                
                return;
            end
            nvars = length(varargin);
            idr = find(strcmp(varargin,'RowNames'), 1);
            idv = find(strcmp(varargin,'VariableNames'), 1);
            idp = find(strcmp(varargin,'DSproperties'), 1);
            idd = find(strcmp(varargin,'DimensionsNames'), 1);
            nrows = size(varargin{1},1);
            
            if ~isempty(idv) && ~isempty(idp)
                warndlg('Use either VariableNames or DSproperties but not both')
                return;
            elseif ~isempty(idv) && ~isempty(idp)
                warndlg('Use either DimensionNames or DSproperties but not both')
                return;
            end

            if strcmp(varargin{1},'Size')
                %syntax to preallocate space in a table
                obj.DataTable = table('Size',varargin{3},'VariableTypes',varargin{4});
                startprops = 5;
            elseif ~isempty(idr) || ~isempty(idv) || ~isempty(idd) || ~isempty(idp)
                %either RowNames, VariableNames, DimensionNamed or 
                %DSpropertieshave been defined
                startprops = min([idr,idv,idd,idp]);
                %check that at least one variable has been included
                if startprops<2
                    warndlg('Need at least one variable to construct a dstable');
                    return;
                end               
            else
                %only variables defined
                startprops = nvars+1;
            end
            
            %build table
            obj.DataTable = table(varargin{1});
            for i=2:startprops-1
                if size(varargin{i},1)==nrows %check has same number of rows
                    obj.DataTable = addvars(obj.DataTable,varargin{i}); 
                else
                    warndlg(sprintf('Variable No %d has different number of rows',i))
                    return;
                end                
            end
            
            %add additional dstable properties as CustomProperties
            addDefaultProperties(obj) %add properties before row and variable names
            
            %handle other keywords such as RowNames and VariableNames
            for j=startprops:2:nvars   
                    obj.(varargin{j}) = varargin{j+1};
            end     
            
            %define dynamic properties and variable ranges
            updateVarNames(obj)          
        end 
%%
        function add_dyn_prop(obj, prop, init_val, isReadOnly)
            %modified from code by Amro on StackOverflow: 
            %https://stackoverflow.com/questions/18258805/dynamically-assign-the-getter-for-a-dependent-property-in-matlab
            % input arguments
            narginchk(2,4);
            if nargin < 3, init_val = []; end
            if nargin < 4, isReadOnly = true; end

            % create dynamic property
            p = addprop(obj, prop);   %p is a meta.DynamicProperty object 
            %p.Transient = true;

            % set initial value if present
            obj.(prop) = init_val;

            % define property accessor methods
            p.GetMethod = @get_method;
            p.SetMethod = @set_method;
            p.NonCopyable = false;
            
            % nested getter/setter functions with closure
            function set_method(obj,val)
                if isReadOnly
                    ME = MException('MATLAB:class:SetProhibited', sprintf(...
                      'You cannot set the read-only property ''%s'' of %s', ...
                      prop, class(obj)));
                    throwAsCaller(ME);
                end
                if isempty(val)
                    obj.DataTable = removevars(obj.DataTable,prop);
                    obj.VariableRange = rmfield(obj.VariableRange,prop);
                else
                    obj.DataTable.(prop) = val;
                    obj.VariableRange.(prop) = getVariableRange(obj,prop);
                end
            end
            %
            function val = get_method(obj)
                val = obj.DataTable.(prop);
            end
        end 
%% ------------------------------------------------------------------------
%% PROPERTY SET AND GET
%% ------------------------------------------------------------------------
% Standard table Metadata Properties
%--------------------------------------------------------------------------
        function set.TableRowName(obj,name)
            %update row of table DimensionNames
            if iscell(name), name = name{1}; end
            %use existing collective name for Variables in Table
            existingvals = obj.DataTable.Properties.DimensionNames;             
            if ~isempty(name) %avoid overwriting existing with empty name
                newvals = {name,existingvals{2}};
                obj.DataTable.Properties.DimensionNames = newvals;
            end
        end
        %
        function name = get.TableRowName(obj)
            name = obj.DataTable.Properties.DimensionNames{1};
        end
%%       
        function set.RowNames(obj,inrows)
            %set RowNames - requires a DataTable to exist. Rows must be unique
            %can be datetime, duration, char arrays, strings or numeric vectors            
            if isempty(obj.DataTable)
                warndlg('Add variables to table before adding RowNames');
                return;
            elseif ~isunique(obj,inrows)
                warndlg('Values used for RowNames must be unique');
                return;
            end
            if isdatetime(inrows)
                obj.DataTable.Properties.RowNames = cellstr(inrows);
                obj.RowType = 'datetime';
                if isempty(obj.RowFormat)
                    obj.RowFormat = inrows.Format;
                end
                obj.DataTable.Properties.DimensionNames{1} = 'Time'; %#ok<*MCSUP>                
            elseif isduration(inrows)
                obj.DataTable.Properties.RowNames = cellstr(inrows);
                obj.RowType = 'duration';
                if isempty(obj.RowFormat)
                    obj.RowFormat = inrows.Format;
                end
                obj.DataTable.Properties.DimensionNames{1} = 'Time';
            elseif iscellstr(inrows) || ischar(inrows)             
                obj.DataTable.Properties.RowNames = inrows;
                obj.RowType = 'char';
                obj.DataTable.Properties.DimensionNames{1} = 'Names';
            elseif isstring(inrows) 
                obj.DataTable.Properties.RowNames = inrows;
                obj.RowType = 'string';
                obj.DataTable.Properties.DimensionNames{1} = 'Names';
            elseif isnumeric(inrows) && ~isempty(inrows) 
                if isrow(inrows), inrows = inrows'; end %make column vector
                obj.DataTable.Properties.RowNames = cellstr(num2str(inrows));
                obj.RowType = 'numeric';
                obj.DataTable.Properties.DimensionNames{1} = 'Identifier';
            elseif isempty(inrows)
                obj.DataTable.Properties.RowNames = {};
                obj.RowType = 'none';
                obj.DataTable.Properties.DimensionNames{1} = 'None';
                obj.RowRange = [];
            else                
                warndlg('Unknown data type for RowNames');
            end
            %add range limits
            if ~isempty(obj.DataTable.Properties.RowNames)
                firstrec = obj.DataTable.Properties.RowNames{1};
                lastrec = obj.DataTable.Properties.RowNames{end};
                obj.RowRange = {firstrec,lastrec}; 
            end
        end
%%
        function outrows = get.RowNames(obj)
            %get RowNames and return values in original format
            switch obj.RowType
                case 'datetime'
                    outrows = datetime(obj.DataTable.Properties.RowNames,...
                                            'InputFormat',obj.RowFormat);
                    outrows.Format = obj.RowFormat;                    
                case 'duration'
                    outrows = str2duration(obj.DataTable.Properties.RowNames,...
                                                           obj.RowFormat);
                    outrows.Format = obj.RowFormat;                    
                case 'char'
                    outrows = obj.DataTable.Properties.RowNames;
                case 'string'
                    outrows = string(obj.DataTable.Properties.RowNames);
                case 'numeric'
                    outrows = str2double(obj.DataTable.Properties.RowNames);
                otherwise
                    warndlg('Error in get.RowNames')
                    outrows = [];
            end
        end
%%        
        function set.Description(obj,desc)
            obj.DataTable.Properties.Description = desc;
        end
        %
        function desc = get.Description(obj)
            desc = obj.DataTable.Properties.Description;
        end
%%        
        function set.UserData(obj,userdata)
            obj.DataTable.Properties.UserData = userdata;
        end
        %
        function userdata = get.UserData(obj)
            userdata = obj.DataTable.Properties.UserData;
        end        
%% ------------------------------------------------------------------------
% Standard table Variable Properties
%--------------------------------------------------------------------------
        function set.VariableNames(obj,varname)
            obj.DataTable.Properties.VariableNames = varname;
%             obj.DSproperties.Variables.Name;
        end
        %
        function varname = get.VariableNames(obj)
            varname = obj.DataTable.Properties.VariableNames;
        end
%%      
        function set.VariableDescriptions(obj,vardesc)
            obj.DataTable.Properties.VariableDescriptions = vardesc;
        end
        %
        function vardesc = get.VariableDescriptions(obj)
            vardesc = obj.DataTable.Properties.VariableDescriptions;
        end
%%        
        function set.VariableUnits(obj,varunits)
            obj.DataTable.Properties.VariableUnits = varunits;
        end
        %
        function varunits = get.VariableUnits(obj)
            varunits = obj.DataTable.Properties.VariableUnits;
        end  
%% ------------------------------------------------------------------------
% Standard table Custom Properties - used for Dimensions and MetaData
%-------------------------------------------------------------------------- 
        function set.CustomProperties(obj,propvals)
            obj.DataTable.Properties.CustomProperties = propvals;
        end
        %
        function propvals = get.CustomProperties(obj)
            propvals = obj.DataTable.Properties.CustomProperties;
        end
        
%% ------------------------------------------------------------------------
% Additional dstable Properties - Variables
%--------------------------------------------------------------------------
        function set.VariableLabels(obj,labels)
            obj.DataTable.Properties.CustomProperties.VariableLabels = labels;
        end        
        %
        function labels = get.VariableLabels(obj)
            labels = obj.DataTable.Properties.CustomProperties.VariableLabels;
        end       
%%
        function set.VariableQCflags(obj,qcflag)
            obj.DataTable.Properties.CustomProperties.VariableQCs = qcflag;
        end        
        %
        function qcflag = get.VariableQCflags(obj)
            qcflag = obj.DataTable.Properties.CustomProperties.VariableQCs;
        end    
%% ------------------------------------------------------------------------
% Additional dstable Properties - Row
%--------------------------------------------------------------------------        
        function set.RowDescription(obj,desctext)
            obj.DataTable.Properties.CustomProperties.RowDescription = desctext;
        end        
        %
        function desctext = get.RowDescription(obj)
            desctext = obj.DataTable.Properties.CustomProperties.RowDescription;
        end         
%%
        function set.RowUnit(obj,unit)
            obj.DataTable.Properties.CustomProperties.RowUnit = unit;
        end        
        %
        function unit = get.RowUnit(obj)
            unit = obj.DataTable.Properties.CustomProperties.RowUnit;
        end                   
%%
        function set.RowLabel(obj,label)
            obj.DataTable.Properties.CustomProperties.RowLabel = label;
        end        
        %
        function label = get.RowLabel(obj)
            label = obj.DataTable.Properties.CustomProperties.RowLabel;
        end   
 %%
        function set.RowFormat(obj,format)
            obj.DataTable.Properties.CustomProperties.RowFormat = format;
        end        
        %
        function format = get.RowFormat(obj)
            format = obj.DataTable.Properties.CustomProperties.RowFormat;
        end         
%% ------------------------------------------------------------------------
% Additional dstable Properties - Dimensions
%--------------------------------------------------------------------------        
        function set.Dimensions(obj,vals)
            %set Dimensions - Dimensions must be unique. Can be datetime, 
            %duration, char arrays, strings or numeric vectors 
            %set RowNames - requires a DataTable to exist. Rows must be unique
            %can be datetime, duration, char arrays, strings or numeric vectors            
            if ~strcmp(obj.DimPropsType,'table')
                warndlg('Dimensions as a ''variable'' Custom Property not yet implemented')
                return; 
            end
            %
            if isstruct(vals)
                %vals uses struct indexing so more than one dimension              
                fname = fieldnames(vals);  %fields usedin vals struct
                dimnum = length(fname);    %number of fields == dimensions
                for i=1:dimnum
                    %vals is a struct with data in the defined input format. 
                    oneval = vals.(fname{i});
                    if ~isunique(obj,oneval)                        
                        msg1 = 'Values for Dimension';
                        msg2 = 'were not set';
                        msg3 = 'Dimension values must be unique';
                        msgtxt = sprintf('%s %s %s\n%s',msg1,fname{i},msg2,msg3);
                        warndlg(msgtxt);
                        dimvals.(fname{i}) = [];
                    else
                        if isempty(oneval)
                            clearDimension(obj,i)                         
                        else
                            [dvals,drange,dtype,dformat] = ...
                                            setDimensionType(obj,oneval,i);
                            dimvals.(fname{i}) = dvals;
                            dimrange.(fname{i}) = drange;
                            dimtype.(fname{i}) = dtype;
                            dimformat.(fname{i}) = dformat;
                            
                        end
                    end 
                end
            else
                %array and no struct indexing so just a single dimension
                dimnum = 1;
                if isempty(vals)
                    clearDimension(obj,dimnum)
                else
                    [dimvals,dimrange,dimtype,dimformat] = ...
                                        setDimensionType(obj,vals,dimnum); 
                end
            end

            %update dstable object properties
            obj.DataTable.Properties.CustomProperties.Dimensions = dimvals;
            obj.DimensionRange = dimrange; 
            obj.DimType = dimtype;
            obj.DimensionFormats = struct2cell(dimformat)';
            addDimensionPropFields(obj);
        end              
%%
        function outdims = get.Dimensions(obj)
            %get Dimensions and return values in original format
            outdims = obj.DataTable.Properties.CustomProperties.Dimensions;          
            if isstruct(outdims)
                fnames = fieldnames(outdims);
                dimnum = length(fnames);
                for i=1:dimnum 
                    oneval = outdims.(fnames{i});
                    getvals = getDimensionType(obj,oneval,fnames{i});
                    outdims.(obj.DimensionNames{i}) = getvals;
                end
            else
                %can only be a single assignment
                if ~isempty(outdims)
                    outdims = getDimensionType(obj,outdims,1);
                end
            end
        end
%%
        function set.DimensionNames(obj,fields)
            obj.DataTable.Properties.CustomProperties.DimensionNames = fields;
        end        
        %
        function fields = get.DimensionNames(obj)
            fields = obj.DataTable.Properties.CustomProperties.DimensionNames;
        end
%%
        function set.DimensionDescriptions(obj,desctext)
            obj.DataTable.Properties.CustomProperties.DimensionDescriptions = desctext;
        end        
        %
        function desctext = get.DimensionDescriptions(obj)
            desctext = obj.DataTable.Properties.CustomProperties.DimensionDescriptions;
        end         
%%
        function set.DimensionUnits(obj,units)
            obj.DataTable.Properties.CustomProperties.DimensionUnits = units;
        end        
        %
        function units = get.DimensionUnits(obj)
            units = obj.DataTable.Properties.CustomProperties.DimensionUnits;
        end                         
%%
        function set.DimensionLabels(obj,labels)
            obj.DataTable.Properties.CustomProperties.DimensionLabels = labels;
        end        
        %
        function labels = get.DimensionLabels(obj)
            labels = obj.DataTable.Properties.CustomProperties.DimensionLabels;
        end        
%%
        function set.DimensionFormats(obj,formats)
            obj.DataTable.Properties.CustomProperties.DimensionFormats = formats;
        end        
        %
        function formats = get.DimensionFormats(obj)
            formats = obj.DataTable.Properties.CustomProperties.DimensionFormats;
        end 
%% ------------------------------------------------------------------------
% Additional dstable Properties - Metadata
%--------------------------------------------------------------------------
        function set.Source(obj,sourcename)
            obj.DataTable.Properties.CustomProperties.Source = sourcename;
        end        
        %
        function sourcname = get.Source(obj)
            sourcname = obj.DataTable.Properties.CustomProperties.Source;
        end
%%
        function set.MetaData(obj,metatext)
            obj.DataTable.Properties.CustomProperties.MetaData = metatext;
        end        
        %
        function metatext = get.MetaData(obj)
            metatext = obj.DataTable.Properties.CustomProperties.MetaData;
        end
%-------Custom Property functions------------------------------------------        
%%
        function addCustomProperties(obj,propnames,proptypes)
            %add a custom property to the DataTable table
            % propname is the new property name
            % proptype - 'table' or 'variable'
            obj.DataTable = addprop(obj.DataTable,propnames,proptypes);
        end
        %
        function rmCustomProperties(obj,propnames)
            %remove a custom property from the DataTable table
            % propname is the custom property of the DataTable to be removed
            obj.DataTable = rmprop(obj.DataTable,propnames);
        end      
%% ------------------------------------------------------------------------
%% PROPERTY FUNCTIONS
%% ------------------------------------------------------------------------   
% Subsample dstable using dimensions
%-------------------------------------------------------------------------- 
        function newdst = getDStable(obj,varargin)
            %extract data from a dstable using the dimension data
            %and return a dstable based on the selected dimension 
            %values. Update dimensions and preserve metadata
            newdst = copy(obj);
            datatable = getDataTable(obj,varargin{:});
            newdst.DataTable = datatable;  
            %if varargin includes 'Dimensions' amend arrays
            vars = varargin(1:2:end);
            idx = find(contains(vars,'Dimensions'));
            idv = idx*2-1;
            if ~isempty(idx)
                for i=1:length(idv) 
                    parts = split(varargin{idv(i)},'.');
                    newdst.(parts{1}).(parts{2}) = varargin{idv(i)+1};
                end
            end
        end
%%
        function datatable = getDataTable(obj,varargin)
            %extract data from a dstable using the dimension data
            %and return a 'table' based on the selected dimension values        
            nvarargin = length(varargin);    
            %initialise cell arrays
            propnames = cell(nvarargin/2,1); %input property list
            ids = propnames;                 %index of Dimensions field names
            ds = ids;                        %property values in DataTable            
            in = ids;                        %requested values for input property 
            index = ids;                     %indices for input values
            dimfields = obj.DimensionNames;
            %unpack the input variables, varargin
            for j=1:2:nvarargin  
                k = ceil(j/2);                         %variable count
                propnames{k} = varargin{j};            %property name
                if contains(propnames{k},'.')          %struct variable                    
                    parts = split(propnames{k},'.');
                    propnames{k} = parts{1};           %property name only
                    ids{k} = find(strcmp(dimfields,parts{2})); %index to Dimensions field name
                    ds{k} = obj.(parts{1}).(parts{2}); %values in DataTable
                else
                    ds{k} = obj.(varargin{j});         %values in DataTable
                end
                in{k} = varargin{j+1};                 %input selection
                if strcmp(propnames{k},'RowNames') && ...
                              isdatetime(in{k}) || isduration(in{k})
                    %if datetime or duration force match rows format
                    in{k}.Format = obj.RowFormat;
                elseif isdatetime(in{k}) || isduration(in{k})
                    %if datetime or duration force match dimensions format
                    idx = strcmp(parts{2},obj.DimensionNames);
                    in{k}.Format = obj.DimensionFormats{idx};
                end
                %convert input selection to indices of values in DataTable
                index{k} = getDimensionIndices(obj,ds{k},in{k});                
            end 
            
            %extract indices for rows, variables and dimensions
            %index of rows
            idx = strcmp(propnames,'RowNames');
            if any(idx)
                idr = index{idx};
            else
                idr = 1:length(obj.RowNames);
            end            
            %index of variables
            idx = strcmp(propnames,'VariableNames');
            if any(idx)
                idv = index{idx};
            else
                idv = 1:length(obj.VariableNames);
            end  
            %index of dimensions
            idx = find(strcmp(propnames,'Dimensions'));
            numdims = length(dimfields);
            idd = cell(1,numdims);
            for j=1:numdims                
                if any(idx)==j
                    %indices for each dimension used in call
                    idd{j} = index{idx(j)};
                else
                    %dimension not used in call - return all
                    idd{j} = 1:length(obj.Dimensions.(dimfields{j}));    
                end
            end
            %
            datatable = obj.DataTable(idr,idv);     %dstable table
            %assume that dims are in order x,y,z etc and that
            %the variable should have at least as many dimensions as the
            %number of dimension defined for the DataTable            
            for k=1:length(idv)         %for each selected variable
                varname = datatable.Properties.VariableNames{k};
                data = datatable{:,k};  %extract variable data from table
                lenold = size(data,2);
                if ndims(data)==numdims
                    %subsample valid data set
                    data = extractIndexDimensions(obj,data,idd);
                end
                lennew = size(data,2);
                if lennew<lenold
                    %need to split variable in table and rebuild
                    datatable = splitvars(datatable,varname);
                    datatable = removevars(datatable,(lennew+1:lenold));
                    datatable = mergevars(datatable,(1:lennew));                    
                end
                datatable{:,k} = data;  %assign sub-sampled data to table
            end  
            
        end
%% ------------------------------------------------------------------------   
% Manipulate Variables - add, remove, move, variable range, horzcat,
% vertcat, sortrows, plot
%--------------------------------------------------------------------------
        function addvars(obj,varargin)
            %add variable to table and update properties
            oldvarnames = obj.VariableNames;
            obj.DataTable = addvars(obj.DataTable,varargin{:});

            newvarnames = obj.VariableNames;
            varnames = setdiff(newvarnames,oldvarnames);
            
            for i=1:length(varnames)
                varname = varnames{i};
                obj.VariableRange.(varname) = getVariableRange(obj,varname);
            end
        end
%%
        function newdst = removevars(obj,varnames)
            %remove variable from table and update properties
            newdst = copy(obj);
            newdst.DataTable = obj.DataTable;            
            newdst.DataTable = removevars(newdst.DataTable,varnames); 
        end
%%
        function movevars(obj,varname,position,location)
            %move variable in table and update properties
            %varname is character vector,string scalar,integer,logical array
            %position is 'Before' or 'After'
            %location is character vector,string scalar,integer,logical array
            obj.DataTable = movevars(obj.DataTable,varname,position,location);
        end
%%
        function newdst = horzcat(obj1,obj2)
            %horizontal concatenation of two dstables
            %number of rows in obj1 and obj2 must match and variable names
            %must be unique
            newdst = [];
            msg = @(txt) sprintf('Invalid dstable objects: %s',txt);
            if ~isa(obj2,'dstable'), warndlg(msg,'not a dstable'); return; end  %not a dstable
            %
            [table1,table2,chx] = getCatChecks(obj1,obj2);
            %number of rows must be same in both tables
            if ~chx.isheight, warndlg(msg('different number of rows')); return; end
            %variable names in the two tables must be unique
            if any(chx.isvar), warndlg(msg('variable names not unique')); return; end
            %rownames in the two tables must be the same
            if ~all(chx.isrow), warndlg(msg('rownames do not match')); return; end
            %
            newdst = copy(obj1);  %new instance of dstable retaining existing properties
            newdst.DataTable = horzcat(table1,table2);
        end
%%
        function newdst = vertcat(obj1,obj2)
            %vertical concatenation of two dstables
            %number and name of variables should be the same but can be in
            %different order
            %rows are sorted after concatenation into ascending order for
            %the source data type of the RowNames data
            newdst = [];
            msg = @(txt) sprintf('Invalid dstable objects: %s',txt);
            if ~isa(obj2,'dstable'), warndlg(msg('not a dstable')); return; end  %not a dstable
            %
            [table1,table2,chx] = getCatChecks(obj1,obj2);
            %number of variables must be same in both tables
            if ~chx.iswidth, warndlg(msg('number of variable do not match')); return; end
            %variable names in the two tables must be the same
            if ~all(chx.isvar), warndlg(msg('different variable names')); return; end
            %check for duplicates in rownames
            if any(chx.isrow), warndlg(msg('duplicate row names')); return; end
            %
            newdst = copy(obj1);  %new instance of dstable retaining existing properties
            newdst.DataTable = vertcat(table1,table2);    
            %sort rows to be in ascending order 
            newdst = sortrows(newdst);
            %add range limits
            firstrec = newdst.DataTable.Properties.RowNames{1};
            lastrec = newdst.DataTable.Properties.RowNames{end};
            newdst.RowRange = {firstrec,lastrec};   
        end
%%
        function obj = sortrows(obj)
            %sort the rows in the dstable DataTable and return updated obj
            %RowNames in a table are char and sortrows does not sort time
            %formats correctly. Sort in ascending order
            rowdata = obj.RowNames;
            obj.DataTable = addvars(obj.DataTable,rowdata,...
                                            'NewVariableNames',{'sxTEMPxs'});
            obj.DataTable = sortrows(obj.DataTable,'sxTEMPxs');
            obj.DataTable = removevars(obj.DataTable,'sxTEMPxs');
        end
%%
        function h = plot(obj,variable,varargin)
            %overload plot function to plot variable against RowNames
            x = obj.RowNames;
            y = obj.(variable);
            h = plot(x,y,varargin{:});
        end
%% ------------------------------------------------------------------------   
% Manipulate Dimensions - make dimensions apply to table or variable
%--------------------------------------------------------------------------
        function setDimensions2Table(obj)
            %modify the propertyTypes of a CustomProperty to 'table' value
            %Dimensions data then applies to all variables in table
            %called from constuctor as the default setting
            propnames = {'Dimensions','DimensionNames',...
                         'DimensionDescriptions','DimensionUnits',...
                         'DimensionLabels','DimensionFormats'};
            proptypes = repmat({'table'},1,length(propnames));
            if isprop(obj,'Dimensions')
                %if already exits remove regardless of propertyType
                rmCustomProperties(obj,propnames); 
            end
            addCustomProperties(obj,propnames,proptypes); 
            obj.DimPropsType = 'table';
        end
%%
        function setDimensions2Variable(obj)
            %modify the propertyTypes of a CustomProperty to 'variable' value
            %Dimensions data can then be defined independently for each
            %variable in the table
            propnames = {'Dimensions','DimensionNames',...
                         'DimensionDescriptions','DimensionUnits',...
                         'DimensionLabels','DimensionFormats'};
            rmCustomProperties(obj,propnames);         
            proptypes = repmat({'variable'},1,length(propnames));         
            addCustomProperties(obj,propnames,proptypes);
            obj.DimPropsType = 'variable';
        end
%% ------------------------------------------------------------------------   
% Manipulate Dynamic Properties - rmprop to remove dynamic properties
%--------------------------------------------------------------------------
        function rmprop(obj,propertyName)
            %remove a dynamic property from a dstable object
            p = findprop(obj,propertyName); 
            delete(p);
        end
%% ------------------------------------------------------------------------   
% DSproperties functions
%--------------------------------------------------------------------------
        function set.DSproperties(obj,dsprops)
            %assign the data in dsprops to the dstable properties
            if isa(dsprops,'dsproperties')            
                %check that number of variables matches table
                isvalid = width(obj.DataTable)==length(dsprops.Variables);
            elseif isa(dsprops,'struct')
                dsprops = dsproperties(dsprops,nullDescription(obj));
                %check that number of variables matches table
                isvalid = width(obj.DataTable)==length(dsprops.Variables);
            else
                warndlg('Unrecognised input format')
                return;
            end
            %
            if isvalid
                %assign data to dstable properties
                setgetDSprops(obj,dsprops);
            else
                warndlg('Number of Properties does not match number of Variables in table')
            end           
        end
%%
        function dsprops = get.DSproperties(obj)
            %extract the dstable properties as a dsproperties object
            tableprops = setgetDSprops(obj);
            dsprops = dsproperties(tableprops,nullDescription(obj));
        end
%% ------------------------------------------------------------------------
% Other functions
%--------------------------------------------------------------------------  
        function tsc = dst2tsc(obj,idxrows,idxvars)
            %convert dstable object to a tscollection if dstable has more than one
            %variable and a timeseries if only one variable
            % idxtime - index vector for the subselection of time
            % idxvars - index vector for the subselection of variables, or the 
            %           variable names as a cell array of character vectors 
            T = obj.DataTable;
            nvar = width(T);
            nrow = height(T);
            if nargin<2
                idxrows = 1:nrow;
                idxvars = 1:nvar;
            elseif nargin<3               
                idxvars = 1:nvar;
            elseif isempty(idxrows)
                idxrows = 1:nrow;
            end
            %
            if ~isnumeric(idxvars) && ~islogical(idxvars)
                idxvars = find(contains(obj.VariableNames,idxvars));
            end
            %
            T = T(idxrows,:);             %subsample table to selected rows
            tsTime = obj.DataTable.Properties.RowNames(idxrows);
            if isa(tsTime,'duration')
                tsTime = datetime(sprintf('01-Jan-%d 00:00:00',0))+tsTime;                        
                tsTime = cellstr(tsTime);  
            end
            %
            tsc = tscollection(tsTime);
            for j=1:length(idxvars)               
                tsobj = timeseries(T{:,idxvars(j)},tsTime);                
                tsobj.Name = obj.VariableNames{idxvars(j)};
                tsobj.QualityInfo.Code = [0 1];
                tsobj.QualityInfo.Description = {'good' 'bad'};
                tsc = addts(tsc,tsobj);
            end
            tsc.Name = obj.Description;
            newdsp = copy(obj.DSproperties);
            newdsp.Variables = newdsp.Variables(idxvars);
            tsc.TimeInfo.UserData = newdsp;
        end
    end 
%% ------------------------------------------------------------------------
% Functions called by methods (private)`
%--------------------------------------------------------------------------      
    methods (Access=private)
%% dstable
        function addDefaultProperties(obj)
            %add additional properties used by dstable
            obj.DimPropsType = 'table';
            %additonal variable properties
            addCustomProperties(obj,{'VariableLabels','VariableQCs'},...
                                                {'variable','variable'});
            %additional row properties
            propnames = {'RowDescription','RowUnit','RowLabel','RowFormat'};
            proptypes = repmat({'table'},1,length(propnames));     
            addCustomProperties(obj,propnames,proptypes);
            %additional dimension properties
            setDimensions2Table(obj)
            %additional metadata properties
            addCustomProperties(obj,{'Source','MetaData'},...
                                                {'table','table'});   
        end        
%% Variables
        function updateVarNames(obj)
            %define or update dynamic properties and variable ranges
            varnames = obj.VariableNames;
            for i=1:length(varnames)
                varname = varnames{i};
                if ~isprop(obj,varname)
                    obj.add_dyn_prop(varname, [], false);
                    obj.VariableRange.(varname) = getVariableRange(obj,varname);
                end
            end 
        end
%%
        function range = getVariableRange(obj,varname)
            %find the minimum and maximum value of the data in varname 
            %if numeric otherwise return first and last value
            data = obj.DataTable.(varname);
            if isnumeric(data)   %vector and array data
                minval = num2str(min(data,[],'all'));
                maxval = num2str(max(data,[],'all'));
                range = {minval,maxval};
            elseif iscell(data)  %character arrays
                range ={data{1},data{end}};
            else                 %character strings, string arrays
                range = [data(1),data(end)];
            end
        end        
%% Row
        function newfmt = checkRowDimFormat(obj,dsprops,dimtype)
            %test to check that the new format works for the data in RowNames
            %or Dimension. dimtype is 'Row' or 'Dimensions'
            if strcmp(dimtype,'Row')
                oldfmt = obj.RowFormat;
            else
                oldfmt = obj.DimensionFormats;
            end
            newfmt = dsprops.(dimtype).Format;
            if isempty(newfmt)
                newfmt = oldfmt;
                return;
            end
            
            if ~isempty(oldfmt) && ~strcmp(oldfmt,newfmt)
                promptxt = sprintf('Format does not match existing format\nSelect format to use');
                newfmt = questdlg(promptxt,'Row format',...
                                oldfmt,newfmt,oldfmt);
            end 

            try
                inputrow = obj.DataTable.Properties.RowNames{1};
                switch obj.RowType
                    case 'datetime'
                        datetime(inputrow,'InputFormat',newfmt);                   
                    case 'duration'
                        str2duration(inputrow,newfmt);
                end
            catch
                newfmt = oldfmt;
                warndlg(sprintf('Cannot read RowNames with selected format\nOld format retained'));
            end
        end
%% Dimensions
        function [dvals,drange,dtype,dformat] = setDimensionType(obj,indims,idx)
            %check dimension type and return values as a char array
            % indims - input dimension array
            % idx - index of dimension
            % dim.vals - char array of values in indims
            % dim.type - variable type used for indims
            % dim.format - char array of format for datetime and duration
            % range - min/max or start/end values
            if isrow(indims), indims = indims'; end %make column vector
            idrange = [1,length(indims)];           %default index for range
            dformat = [];
            if isdatetime(indims)
                dvals = cellstr(indims);
                dtype = 'datetime';  
                dformat = addDimsFormat(obj,indims,idx);
            elseif isduration(indims)
                dvals = cellstr(indims);
                dtype = 'duration';      
                dformat = addDimsFormat(obj,indims,idx);
            elseif iscellstr(indims) || ischar(indims)             
                dvals = indims;
                dtype = 'char';
            elseif isstring(indims) 
                dvals = indims;
                dtype = 'string';
            elseif isnumeric(indims)                      
                dvals = cellstr(num2str(indims));
                dtype = 'numeric';
                [~,imin] = min(indims);
                [~,imax] = max(indims);
                idrange = [imin,imax];  %index for range
            else
                dvals = []; dtype = []; drange = [];
                return;
            end
            drange = dvals(idrange)';
        end
%%
        function dformat = addDimsFormat(obj,indims,idx)
            %add DimensionFormats to cell array (can be more than one dimension)
            % indims - dimension data set
            % idx - dimension being checked
            if length(obj.DimensionFormats)>1
                obj.DimensionFormats{1,idx} = indims.Format;
                dformat = obj.DimensionFormats;
            else
                dformat = indims.Format;
            end
        end
%%
        function outdims = getDimensionType(obj,source,dimname)
            %check dimension type and return Dimension using input format
            % source - saved Dimension values
            % dimnum - the index of the Dimension based on DimensionNames
            % outdims - dimension converted from char to input data format
            if isnumeric(dimname)
                dimtype = obj.DimType;
                dimnum = 1;
            else
                dimtype = obj.DimType.(dimname);
                dimnum = find(strcmp(obj.DimensionNames,dimname));
            end
            %
            switch dimtype
                case 'datetime'
                    outdims = datetime(source,'InputFormat',...
                                            obj.DimensionFormats{dimnum});
                    outdims.Format = obj.DimensionFormats{dimnum};
                case 'duration'
                    outdims = str2duration(source,obj.DimensionFormats{dimnum});
                    outdims.Format = obj.DimensionFormats{dimnum};
                case 'char'
                    outdims = source;
                case 'string'
                    outdims = string(source);
                case 'numeric'
                    outdims = str2double(source);
                otherwise
                    outdims = [];
            end
        end
%%
        function addDimensionPropFields(obj)
            %check that Dimension metadata properties have cell arrays that
            %are the same length as the number of Dimensions
            ndim = length(obj.DimensionNames);
            obj.DimensionDescriptions = checkProperty(obj.DimensionDescriptions,ndim);
            obj.DimensionUnits = checkProperty(obj.DimensionUnits,ndim);
            obj.DimensionLabels = checkProperty(obj.DimensionLabels,ndim);
            %DimensionFormats is set when checking in setDimensionType
            
            function paddedprop = checkProperty(prop,ndim)
                nfields = length(prop);
                if nfields<ndim
                    nadd=ndim-nfields;
                    paddedprop(nfields+1:nfields+nadd) = repmat({''},1,nadd);
                else
                    paddedprop = prop;
                end
            end           
        end
%%
        function clearDimension(obj,dimnum)
            %remove the metadata for a Dimension if deleted (set = [])
            dimname = obj.DimensionNames(dimnum);
            obj.DimensionNames(dimnum) = [];            
            obj.DimensionDescriptions(dimnum) = [];
            obj.DimensionUnits(dimnum) = [];       
            obj.DimensionLabels(dimnum) = [];       
            obj.DimensionFormats(dimnum) = [];
            %struct variables
            obj.DimType = rmfield(obj.DimType,dimname);
            obj.DimensionRange = rmfield(obj.DimensionRange,dimname);
        end 
%%
        function index = getDimensionIndices(~,dstDimVals,inVals)
            %find the indices of the selected values of a dimension
            % dstDimVals - reference values for index
            % inVals - values requested 
            %intersect does not work with datetime (despite inclusion in
            %manual)
            if isdatetime(inVals)
                dstDimVals = cellstr(dstDimVals);
                inVals = cellstr(inVals);
            end
            [~,index,~] = intersect(dstDimVals,inVals,'stable');
        end        
%%
        function outdata = extractIndexDimensions(~,data,ind)              
            %extract the dimensions based on the selected values
            %handles 3 dimensions in addition to rows 
            % data - source array of data
            % ind  - cell array of index values
            switch length(ind)
                case 1
                    outdata = data(:,ind{1});
                case 2
                    outdata = data(:,ind{1},ind{2});
                case 3
                    outdata = data(:,ind{1},ind{2},ind{3});
            end                
        end  
%% dsproperties       
        function dsp = setgetDSprops(obj,dsprops)
            %set or get the dstable properties 
            % dsprops is a dsproperties object used to set the properties
            % in a dstable object
            % dsp gets a structure of cell arrays using the properties
            % stored in the dstable in format that can be used to create
            % dsproperties object
            if nargin<2
                isget = true;
                dsprops = dsproperties;
            else
                isget = false;
            end
            
            dspnames = {'Variables','Row','Dimensions'};           
            for i=1:3
                isrow = strcmp(dspnames{i},'Row');
                fnames = fieldnames(dsprops.(dspnames{i}));
                %
                for j=1:length(fnames)
                    if isrow && strcmp(fnames{j},'Name')
                        %Row Name is singular in dsp and plural in table
                        propname = ['Table',dspnames{i},fnames{j}];
                        if ~isget && isempty(dsprops.(dspnames{i}).(fnames{j}))
                            %avoid overwriting default Row name when loading
                            %properties from a stuct or dsproperties object
                            dsp.(dspnames{i}).(fnames{j}) = obj.(propname);
                        end
                    elseif isrow
                        %Row field names are all singular
                        propname = [dspnames{i},fnames{j}];                       
                    else
                        %Variable and Dimension names are plural
                        %e.g. Dimenions.Name becomes DimensionNames
                        propname = [dspnames{i}(1:end-1),fnames{j},'s'];
                    end
                    %
                    if isget
                        if isempty(obj.(propname))  %dstable property
                            %pad empty fields to the number of variables
                            if contains(propname,'Names')
                                %no variables/row/dimension names defined
                            	nvar = 1;
                            elseif ischar(dsp.(dspnames{i}).Name)
                                %just a single variable/row/dimension
                                nvar = 1;
                            else
                                %multiple variables/row/dimension
                                nvar = length(dsp.(dspnames{i}).Name);
                            end
                            dsp.(dspnames{i}).(fnames{j}) = repmat({''},1,nvar);
                        else
                            dsp.(dspnames{i}).(fnames{j}) = obj.(propname);
                        end
                    else
                        if isrow %handle row fields to avoid nesting cells
                            if strcmp(propname,'RowFormat')
                                if strcmp(obj.RowType,'datetime') || ...
                                            strcmp(obj.RowType,'duration')                        
                                   dsprops.(dspnames{i}).(fnames{j}) = ...
                                       checkRowDimFormat(obj,dsprops,dspnames{i});
                                end                                                                                              
                            end
                            obj.(propname) = dsprops.(dspnames{i}).(fnames{j}); 
                        else
                            propvalues = dsprops.(dspnames{i}).(fnames{j});
                            if iscell(propvalues) && isempty(propvalues{1})
                                obj.(propname) = {''};
                            elseif strcmp(propname,'VariableNames')
                                obj.(propname) = {dsprops.(dspnames{i}).(fnames{j})};
                                updateVarNames(obj)
                            elseif strcmp(propname,'DimensionFormats')
                                if strcmp(obj.DimType,'datetime') || ...
                                            strcmp(obj.DimType,'duration')                        
                                   dsprops.(dspnames{i}).(fnames{j}) = ...
                                      checkRowDimFormat(obj,dsprops,dspnames{i});
                                end 
                                obj.(propname) = dsprops.(dspnames{i}).(fnames{j});
                            else
                                obj.(propname) = {dsprops.(dspnames{i}).(fnames{j})};
                            end
                        end
                    end
                end
            end            
        end

%%
        function dsdesc = nullDescription(obj)
            %set default description in no table description defined
            if isempty(obj.Description)
                dsdesc = 'dstable properties';
            else
                dsdesc = obj.Description;
            end
        end
%% functions
        function [table1,table2,chx] = getCatChecks(obj1,obj2)
            %checks needed for horzcat and vertcat
            table1 = obj1.DataTable;
            table2 = obj2.DataTable;
            chx.iswidth = width(table1)==width(table2);
            chx.isheight = height(table1)==height(table2);
            %variable names in the two tables must be the same
            varnames1 = table1.Properties.VariableNames;
            varnames2 = table2.Properties.VariableNames;
            chx.isvar = ismember(varnames1,varnames2);
            %check for duplicates in rownames
            rownames1 = table1.Properties.RowNames;
            rownames2 = table2.Properties.RowNames;
            chx.isrow = ismember(rownames1,rownames2);
        end
%%
        function answer = isunique(~,usevals)
            %check that all values in usevals are unique
            if isdatetime(usevals) || isduration(usevals)
                usevals = cellstr(usevals);
            end
            [~,idx,idy] = unique(usevals,'stable');
            answer = numel(idx)==numel(idy);
        end
%%
    end
end