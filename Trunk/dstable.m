classdef dstable < handle
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
    
    properties (Hidden)
        RowType   %records the data type - used by RowNames set and get
        DimType   %records the data type - used by Dimensions set and get
    end
    
    properties (Hidden)
        VariableRange        %min and max values of variable (auto loaded)
        RowRange             %min and max values of row (auto loaded)
        DimensionRange       %min and max values of dimension (auto loaded)
    end
    
    properties (Dependent=true)
        %properties defined in tablename.Properties.PropertyName are
        %defined as Dependent to provide short syntax access for
        %dstables (e.g. dst.PropertyName)
        %Standard matlab(c) table properties
        TableRowName         %labels row column
        RowNames             %distinct non-empty values to define each row
        Description          %summary description of dstable
        UserData             %free for user assignment        
        VariableNames        %name of each variable (checked for variable compliance)
        VariableDescriptions %text to describe each variable
        VariableUnits        %units used for each variable   
        VariableQCflags      %flag to indicate any quality control of data 
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
        
        %Additional Row metadata
        RowDescription        %text to describe row usage
        RowUnit               %unit used for row data (if used)
        RowLabel              %label for generic outputs
        RowFormat             %datetime or duration format (if used)         
        
        %Dimensions propety metatdata
        DimensionNames       %duplicates property in table, so use:       
%         DimensionFields       %names to define fieldname for each dimension
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
            nrows = size(varargin{1},1);

            if strcmp(varargin{1},'Size')
                %syntax to preallocate space in a table
                obj.DataTable = table('Size',varargin{3},'VariableTypes',varargin{4});
                startprops = 5;
            elseif ~isempty(idr) || ~isempty(idv)
                %either RowNames or VariableNames have been defined
                if isempty(idr)
                    startprops = idv;
                elseif isempty(idv)
                    startprops = idr;
                else
                    startprops = min([idr,idv]);
                end
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
                if strcmp(varargin{j},'MetaData')
                    %provision to add metadata using DSCproperties object
                    %create DSCproperties class with options to load data
                    %using DSproperties struct or interactively as row
                    %definition, variable definition, dimension definition.
                    %Use the DSCproperties to set and get DSproperties.
                else
                    obj.(varargin{j}) = varargin{j+1};
                end
            end     
            
            %define variable ranges
            varnames = obj.VariableNames;
            for i=1:length(varnames)
                varname = varnames{i};
                obj.VariableRange.(varname) = getVariableRange(obj,varname);
            end
            
        end  
%%
        function addDefaultProperties(obj)
            %add default properties used by dstable
            obj.DataTable = addprop(obj.DataTable,'Dimensions','table');
            %additonal variable properties
            obj.DataTable = addprop(obj.DataTable,'VariableLabels','variable');
            obj.DataTable = addprop(obj.DataTable,'VariableQCs','variable');
            %additional row properties
            obj.DataTable = addprop(obj.DataTable,'RowDescription','table');
            obj.DataTable = addprop(obj.DataTable,'RowUnit','table');
            obj.DataTable = addprop(obj.DataTable,'RowLabel','table');
            obj.DataTable = addprop(obj.DataTable,'RowFormat','table');
            %additional dimension properties
            obj.DataTable = addprop(obj.DataTable,'DimensionNames','table');
            obj.DataTable = addprop(obj.DataTable,'DimensionDescriptions','table');
            obj.DataTable = addprop(obj.DataTable,'DimensionUnits','table');
            obj.DataTable = addprop(obj.DataTable,'DimensionLabels','table');
            obj.DataTable = addprop(obj.DataTable,'DimensionFormats','table');
            %additional metadata properties
            obj.DataTable = addprop(obj.DataTable,'Source','table');
            obj.DataTable = addprop(obj.DataTable,'MetaData','table');   
        end
%--------------------------------------------------------------------------
% Standard Table Metadata Properties
%--------------------------------------------------------------------------
        function set.TableRowName(obj,name)
            existingvals = obj.DataTable.Properties.DimensionNames;
            newvals = {name{1},existingvals{2}};
            obj.DataTable.Properties.DimensionNames = newvals;
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
                    obj.RowFormat = {inrows.Format};
                end
                obj.DataTable.Properties.DimensionNames{1} = 'Time'; %#ok<*MCSUP>                
            elseif isduration(inrows)
                obj.DataTable.Properties.RowNames = cellstr(inrows);
                obj.RowType = 'duration';
                if isempty(obj.RowFormat)
                    obj.RowFormat = {inrows.Format};
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
            elseif isnumeric(inrows)      
                if isrow(inrows), inrows = inrows'; end %make column vector
                obj.DataTable.Properties.RowNames = cellstr(num2str(inrows));
                obj.RowType = 'numeric';
                obj.DataTable.Properties.DimensionNames{1} = 'Identifier';
            else
                warndlg('Unknown data type for RowNames');
            end
            %add range limits
            firstrec = obj.DataTable.Properties.RowNames{1};
            lastrec = obj.DataTable.Properties.RowNames{end};
            obj.RowRange = {firstrec,lastrec};         
        end
        %
        function outrows = get.RowNames(obj)
            %get RowNames and return values in original format
            switch obj.RowType
                case 'datetime'
                    outrows = datetime(obj.DataTable.Properties.RowNames,...
                                            'InputFormat',obj.RowFormat{1});
                    outrows.Format = obj.RowFormat{1};                    
                case 'duration'
                    outrows = duration(obj.DataTable.Properties.RowNames,...
                                            'InputFormat',obj.RowFormat{1});
                    outrows.Format = obj.RowFormat{1};                    
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
            userdata = obj.DataTable.Properties.Description;
        end        
%% 
%--------------------------------------------------------------------------
% Standard Table Variable Properties
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
%%
%--------------------------------------------------------------------------
% Standard Table Custom Properties - used for Dimensions and MetaData
%-------------------------------------------------------------------------- 
        function set.CustomProperties(obj,propvals)
            obj.DataTable.Properties.CustomeProperties = propvals;
        end
        %
        function propvals = get.CustomProperties(obj)
            propvals = obj.DataTable.Properties.CustomProperties;
        end
%-------DataTable------------------------------------------------------------
%%
        function obj = getDStable(obj,varargin)
            %extract data from a dstable using the dimension data
            %and return a dstable based on the selected dimension 
            %values. Update dimensions and preserve metadata
            datatable = getDataTable(obj,varargin{:});
            obj.DataTable = datatable;  
            %if varargin includes 'Dimensions' amend arrays
            vars = varargin(1:2:end);
            idx = find(contains(vars,'Dimensions'));
            idv = idx*2-1;
            if ~isempty(idx)
                for i=1:length(idv) 
                    parts = split(varargin{idv(i)},'.');
                    obj.(parts{1}).(parts{2}) = varargin{idv(i)+1};
                end
            end
        end
%%
        function datatable = getDataTable(obj,varargin)
            %extract data from a dstable using the dimension data
            %and return a 'table' based on the selected dimension values
            %optionally also returns           
            nvarargin = length(varargin);    
            %initialise cell arrays
            propnames = cell(nvarargin/2,1); %input property list
            ids = propnames;                 %index of Dimensions field names
            ds = ids;                        %property values in DataTable            
            in = ids;                        %requested values for input property 
            index = ids;                     %indices for input values
            dimfields = obj.DimensionNames;
%             k = 1;
            %unpack the input variables, varargin
            for j=1:2:nvarargin  
                k = ceil(j/2);                         %variable count
                propnames{k} = varargin{j};            %property name
%                 md.(propnames{k}) = obj.(varargin{j+1}); %assign to metadata
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
                    in{k}.Format = obj.RowFormat{1};
                elseif isdatetime(in{k}) || isduration(in{k})
                    %if datetime or duration force match dimensions format
                    idx = strcmp(parts{2},obj.DimensionNames);
                    in{k}.Format = obj.DimensionFormats{idx};
                end
                %convert input selection to indices of values in DataTable
                index{k} = getDimensionIndices(obj,ds{k},in{k});
%                 k = k+1;                
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
%%
        function index = getDimensionIndices(~,dsvals,invals)
            %find the indices of the selected values of a dimension
            % dsvals - reference values for index
            % invals - values requested 
            %intersect does not work with datetime (despite inclusion in
            %manual)
            if isdatetime(invals)
                dsvals = cellstr(dsvals);
                invals = cellstr(invals);
            end
            [~,index,~] = intersect(dsvals,invals,'stable');
        end
%%
        function outdata = extractIndexDimensions(~,data,ind)              
            %extract the dimesions based on the selected values
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
%-------Variables----------------------------------------------------------          
%%
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
%%
        function clearVariable(obj,varnum)
            %remove the metadata for a Variable if deleted (set = [])
            obj.VariableLabels(varnum) = [];
            obj.VariableQC(varnum) = [];
        end   
%%
        function addvars(obj,vars,varnames)
            %add variable to table and update properties
            obj.DataTable = addvars(obj.DataTable,vars); 
            addVariables(obj.DSproperties,varnames)
            %add range of data set to obj.VariableRange struct
            for i=1:length(varnames)
                varname = varnames{i};
                obj.VariableRange.(varname) = getVariableRange(obj,varname);
            end
        end
%%
        function removevars(obj,varnames)
            %remove variable from table and update properties
            obj.DataTable = removevars(obj.DataTable,varnames); 
            %****************************************************
            %check that this updates dstable properties automatically
            rmVariables(obj.DSproperties,varnames)
        end
%%
        function movevars(obj,varname,position,location)
            %move variable in table and update properties
            %varname is character vector,string scalar,integer,logical array
            %position is 'Before' or 'After'
            %location is character vector,string scalar,integer,logical array
            obj.DataTable = movevars(obj.DataTable,varname,position,location);
            %use function in dsproperties to adjust properties to align
            %with table
            moveVariable(obj,varname,position,location)
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
%-------Row----------------------------------------------------------------                      
  %%
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
%-------Dimensions---------------------------------------------------------
%%
        function set.Dimensions(obj,vals)
            %set Dimensions - Dimensions must be unique. Can be datetime, 
            %duration, char arrays, strings or numeric vectors 
            %set RowNames - requires a DataTable to exist. Rows must be unique
            %can be datetime, duration, char arrays, strings or numeric vectors            
            isnew = true;
            if isstruct(vals)
                %vals uses struct indexing               
                fname = fieldnames(vals);
                dimnum = length(fname);
                numprev = length(obj.DimensionNames);
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
                            [setval,dimtype,strange] = setDimensionType(obj,oneval);
                            dimvals.(fname{i}) = setval;
                            range.(fname{i}) = strange;
                        end
                    end 
                end
                %
                if numprev~=dimnum 
                    %field is new and not in existing DimensionNames list                    
                    obj.DimensionNames{dimnum,1} = fname{dimnum};
                    vals = vals.(fname{dimnum});
                else
                    %selection is one of the existing DimensionNames
                    isnew = false; 
                end
            else
                %array and no struct indexing
                dimnum = 1;
                if isempty(vals)
                    clearDimension(obj,dimnum)
                else
                    [dimvals,dimtype,range] = setDimensionType(obj,vals);   
                end
            end
            
            if isnew
                %add type and format if a new Dimension
                obj.DimType{dimnum} = dimtype;
                if (isempty(obj.DimensionFormats)  || ...
                                  isempty(obj.DimensionFormats{dimnum})) && ...
                                  (isdatetime(vals) || isduration(vals))
                    obj.DimensionFormats{dimnum} = vals.Format;
                end
            end
            
            obj.DataTable.Properties.CustomProperties.Dimensions = dimvals;
            %add range limits
            obj.DimensionRange = range; 
        end        
%%
        function [dimvals,dimtype,range] = setDimensionType(~,indims)
            %check dimension type and return values as a char array
            % dimvals - char array version of values in indims
            % dimtype - variable type used for indims
            if isrow(indims), indims = indims'; end %make column vector
            idrange = [1,length(indims)];           %default index for range
            if isdatetime(indims)
                dimvals = cellstr(indims);
                dimtype = 'datetime';                
            elseif isduration(indims)
                dimvals = cellstr(indims);
                dimtype = 'duration';                
            elseif iscellstr(indims) || ischar(indims)             
                dimvals = indims;
                dimtype = 'char';
            elseif isstring(indims) 
                dimvals = indims;
                dimtype = 'string';
            elseif isnumeric(indims)                      
                dimvals = cellstr(num2str(indims));
                dimtype = 'numeric';
                idrange = [min(indims),max(indims)];  %index for range
            else
                warndlg('Unknown data type for RowNames');
            end
            range = dimvals(idrange)';
        end
%%
        function clearDimension(obj,dimnum)
            %remove the metadata for a Dimension if deleted (set = [])
            obj.DimensionNames(dimnum) = [];
            obj.DimType(dimnum) = [];
            obj.DimensionDescriptions(dimnum) = [];
            obj.DimensionUnits(dimnum) = [];       
            obj.DimensionLabels(dimnum) = [];       
            obj.DimensionFormats(dimnum) = [];
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
                    getvals = getDimensionType(obj,oneval,i);
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
        function outdims = getDimensionType(obj,source,dimnum)
            %check dimension type and return Dimension using input format
            % source - saved Dimension values
            % dimnum - the index of the Dimenion based on DimensionNames
            dimtype = obj.DimType{dimnum};
            switch dimtype
                case 'datetime'
                    outdims = datetime(source,'InputFormat',...
                                            obj.DimensionFormats{dimnum});
                    outdims.Format = obj.DimensionFormats{dimnum};
                case 'duration'
                    outdims = duration(source,'InputFormat',...
                                            obj.DimensionFormats{dimnum});
                    outdims.Format = obj.DimensionFormats{dimnum};
                case 'char'
                    outdims = source;
                case 'string'
                    outdims = string(source);
                case 'numeric'
                    outdims = str2double(source);
                otherwise
                    warndlg('Error in get.RowNames')
                    outdims = [];
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
%-------Metadata-----------------------------------------------------------
%%
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
        function addCustomProperty(obj,propname,proptype)
            %add a custom property to the DataTable table
            % propname is the struct 'fieldname' for the new property
            % proptype - 'table' or 'variable'
            obj.DataTable = addprop(obj.DataTable,propname,proptype);
        end
        %
        function rmCustomProperty(obj,propname)
            %remove a custom property from the DataTable table
            % propname is the struct 'fieldname' for the property to be removed
            obj.DataTable = rmprop(obj.DataTable,propname);
        end
        %
        function setDimensions2Table(obj)
            %modify the propertyTypes of a CustomProperty to 'table' value
            %Dimensions data then applies to all variables in table
            
        end
        %
        function setDimensions2Variable(obj)
            %modify the propertyTypes of a CustomProperty to 'variable' value
            %Dimensions data can then be defined independently for each
            %variable in the table
            
        end
%%
%-------DSproperties functions------------------------------------------ 
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
%%
        function dsdesc = nullDescription(obj)
            %set default description in no table description defined
            if isempty(obj.Description)
                dsdesc = 'dstable properties';
            else
                dsdesc = obj.Description;
            end
        end
%%
%--------------------------------------------------------------------------
% Other functions
%--------------------------------------------------------------------------  
        function answer = isunique(~,usevals)
            %check that all values in usevals are unique
            if isdatetime(usevals) || isduration(usevals)
                usevals = cellstr(usevals);
            end
            [~,idx,idy] = unique(usevals,'stable');
            answer = numel(idx)==numel(idy);
        end
%%
        function tsc = dst2tsc(obj,rows,variables)
            %convert dstable object to a tscollection if dstable has more than one
            %variable and a timeseries if only one variable
            T = obj.DataTable;
            if nargin<2
                rows = 1:height(T);
                variables = 1:width(T);
            elseif nargin<3 || strcmp(variables,'all')                
                variables = 1:width(T);
            end
            %
            T = obj.DataTable(rows,variables);
            tsc = table2tscollection(T);    %see TSDataSet????******
            %include option transfer any existing metadata
            warndlg('Under development')
        end
    end 
    
    methods (Access=private)
%         function dsprops = assignProperties(obj,dsprops)
%             %assign properties to table or extract properties to dsprops
%             isget = false;
%             if nargin<2
%                 isget = true;
%             end
%             dsp = obj.DSproperties;
%             dspnames = fieldnames(dsp);
%             propnames = getPropertyNames(obj);
%             if isget
%                 dsprops = getDSprops(obj);
%             else
%                 setDSprops(obj,dsprops);
%             end
%         end
%% 
% Not used but kept in case needed (not tested)
%         function propnames = getPropertyNames(obj)
%             %construct fields names from DSproperties struct
%             dsprops = dsproperties;
%             dspnames = {'Variables','Row','Dimensions'};            
%             propnames{3,5} = [];       %NB: assumes 5 fields in struct
%             for i=1:3
%                 fnames = fieldnames(dsp.(dspnames{i}));
%                 for j=1:length(fnames)
%                     if strcmp(dspnames{i},'Row') && strcmp(fnames{j},'Name')
%                         %Row Name is singular in dsp and plural in table
%                         propnames{i,j} = [dspnames{i},fnames{j},'s'];
%                     elseif strcmp(dspnames{i},'Row')
%                         %Row field names are all singular
%                         propnames{i,j} = [dspnames{i},fnames{j}];
%                     else
%                         %Variable and Dimension names are plural
%                         %e.g. Dimenions.Name becomes DimensionNames
%                         propnames{i,j} = [dspnames{i}(1:end-1),fnames{j},'s'];
%                     end
%                 end
%             end            
%         end
%%
        function dsp = setgetDSprops(obj,dsprops)
            %set or get the dstable properties 
            % dsprops is a dsproperties object
            % dsp returns a structure of cell arrays that can be passed to
            % dsproperties
            if nargin<2
                isget = true;
                dsprops = dsproperties;
            else
                isget = false;
            end
            
            dspnames = {'Variables','Row','Dimensions'};           
            for i=1:3
                fnames = fieldnames(dsprops.(dspnames{i}));
                for j=1:length(fnames)
                    if strcmp(dspnames{i},'Row') && strcmp(fnames{j},'Name')
                        %Row Name is singular in dsp and plural in table
                        propname = ['Table',dspnames{i},fnames{j}];
                        if ~isget && isempty(dsprops.(dspnames{i}).(fnames{j}))
                            %avoid overwriting default Row name when loading
                            %properties from a stuct or dsproperties object
                            dsp.(dspnames{i}).(fnames{j}) = obj.(propname);
                        end
                    elseif strcmp(dspnames{i},'Row')
                        %Row field names are all singular
                        propname = [dspnames{i},fnames{j}];                       
                    else
                        %Variable and Dimension names are plural
                        %e.g. Dimenions.Name becomes DimensionNames
                        propname = [dspnames{i}(1:end-1),fnames{j},'s'];
                    end
                    %
                    if isget
                        if isempty(obj.(propname))
                            %pad empty fields to the number of variables
                            if ischar(dsp.(dspnames{i}).Name)
                                nvar = 1;
                            else
                                nvar = length(dsp.(dspnames{i}).Name);
                            end
                            dsp.(dspnames{i}).(fnames{j}) = repmat({''},1,nvar);
                        else
                            dsp.(dspnames{i}).(fnames{j}) = obj.(propname);
                        end
                    else
                        obj.(propname) = {dsprops.(dspnames{i}).(fnames{j})};
                    end
                end
            end            
        end       
%%
%         function setDSprops(obj)
%             %construct fields names from DSproperties struct
%             dsprops = dsproperties;
%             dspnames = {'Variables','Row','Dimensions'};               
% %             propnames{3,5} = [];       %NB: assumes 5 fields in struct
%             for i=1:3
%                 fnames = fieldnames(dsprops.(dspnames{i}));
%                 for j=1:length(fnames)
%                     if strcmp(dspnames{i},'Row') && strcmp(fnames{j},'Name')
%                         %Row Name is singular in dsp and plural in table
%                         propname = [dspnames{i},fnames{j},'s'];
%                     elseif strcmp(dspnames{i},'Row')
%                         %Row field names are all singular
%                         propname = [dspnames{i},fnames{j}];
%                     else
%                         %Variable and Dimension names are plural
%                         %e.g. Dimenions.Name becomes DimensionNames
%                         propname = [dspnames{i}(1:end-1),fnames{j},'s'];
%                     end
%                 end
%                 obj.(propname){k} = {dsprops.(dspnames{i}).(fnames{j})};
%             end            
%         end        
    end
end