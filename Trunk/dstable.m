classdef (ConstructOnLoad) dstable < dynamicprops & matlab.mixin.SetGet & matlab.mixin.Copyable
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
%   NB: dynamic properties are not saved when dstable is saved to a mat
%   file. To reinitialise these properties to enable direct access to
%   variables (eg. using obj.VariableName) call 
%      dst = activatedynamicprops(dst);   %eg called in muiCatalogue.getDataset
%   dstable uses ConstructOnLoad so this should no longer be needed but it
%   is!
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
        LastModified          %date table created or modified
        Source                %source of dst - model name or input file name
        MetaData              %detailed description of dstable (eg how derived)
    end
    
    properties (Transient)
        %a dsproperties object is used to define metadata for a dstable
        DSproperties = dsproperties
    end
   
%% CONTENTS
%   constructor methods
%   dstable property Set and Get methods
%   dstable functions:
%       getDStable, getDataTable, getData, 
%       getVarAttributes, getVarAttRange, selectAttribute, updateRange
%       addvars, removevars,    
%       movevars, horzcat, vertcat, sortrows, mergerows, plot
%       setDimensions2Table, setDimensions2Variable, rmprop
%       get and set DSproperties, dst2tsc, allfieldnames

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
                %either RowNames, VariableNames, DimensionNames or 
                %DSproperties have been defined
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
            if istable(varargin{1})
                obj.DataTable = varargin{1};
            else
                obj.DataTable = table(varargin{1});
                for i=2:startprops-1
                    if size(varargin{i},1)==nrows %check has same number of rows
                        obj.DataTable = addvars(obj.DataTable,varargin{i}); 
                    else
                        warndlg(sprintf('Variable No %d has different number of rows',i))
                        return;
                    end                
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
            
            %add default row and variable descriptions if not defined
            %dimension descriptions are handled in set.DimensionNames
            if isempty(obj.RowDescription)
                obj.RowDescription = obj.DataTable.Properties.DimensionNames(1);
            end
            %
            if isempty(obj.VariableDescriptions)
                obj.VariableDescriptions = obj.VariableNames;
            end
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
            p.Transient = true;       %ensures dynamic properties update

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
                obj.LastModified = datetime('now');
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
            elseif ~isunique(inrows)
                warndlg('Values used for RowNames must be unique');
                return;
            end
            
            %var2str handles the following data types
            %  'logical','int8','int16','int32','int64','uint8','uint16',
            %  'uint32','uint64','single','double','char','string',
            %  'categorical','ordinal','datetime','duration'
            [rowstr,rtype,rformat] = var2str(inrows);
            
            if ~isempty(rowstr)
                obj.DataTable.Properties.RowNames = rowstr;
                obj.RowType = rtype;
                if isempty(obj.RowFormat)
                    obj.RowFormat = rformat;
                end
            end
            
            %assign Row DimensionNames{1} as one of following based on type
            %  'Time','Names','Order','Category','Identifier','Rows','None'            
            if isdatetime(inrows) || isduration(inrows)
                dimname = 'Time';
            elseif iscategorical(inrows)
                if isordinal(inrows)
                    dimname = 'Order';
                else
                    dimname = 'Category';
                end
            elseif strcmp(rtype,'unknown')
                dimname = 'Rows';
            elseif ~isempty(rowstr)
                dimname = 'Names';
            else
                dimname = 'None';
            end
            obj.DataTable.Properties.DimensionNames{1} = dimname;    
            
            %add range limits
            if ~isempty(obj.DataTable.Properties.RowNames)
                obj.RowRange = inrows;
                obj.LastModified = datetime('now');
            end
        end
%%
        function outrows = get.RowNames(obj)
            %get RowNames and return values in original format
            outdata = obj.DataTable.Properties.RowNames;
            if isempty(outdata)
                outrows = [];
            else
                type = obj.RowType;
                format = obj.RowFormat;
                outrows = str2var(outdata,type,format,true);
            end
        end
%%     
        function set.RowRange(obj,inrows)
            %set the RowRange checking whether cell or array
            if iscell(inrows(1))
                firstrec = inrows{1};
                lastrec = inrows{end};
            else
                firstrec = inrows(1);
                lastrec = inrows(end);
            end
            obj.RowRange = {firstrec,lastrec};    
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
        function set.VariableNames(obj,varnames)
            obj.DataTable.Properties.VariableNames = varnames;
            updateVarNames(obj); %update dynamic properties 
        end
        %
        function varnames = get.VariableNames(obj)
            varnames = obj.DataTable.Properties.VariableNames;
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
                fname = fieldnames(vals);  %fields used in vals struct
                dimnum = length(fname);    %number of fields == dimensions
                for i=1:dimnum
                    %vals is a struct with data in the defined input format. 
                    oneval = vals.(fname{i});
                    if ~isunique(oneval)                        
                        msg1 = 'Values for Dimension';
                        msg2 = 'were not set';
                        msg3 = 'Dimension values must be unique';
                        msgtxt = sprintf('%s %s %s\n%s',msg1,fname{i},msg2,msg3);
                        warndlg(msgtxt);
                        dimvals.(fname{i}) = [];
                        obj.DataTable.Properties.CustomProperties.Dimensions = dimvals;
                        return;
                    else
                        if isempty(oneval)
                            clearDimension(obj,i)                         
                        else
                            [dvals,drange,dtype,dformat] = ...
                                            setDimensionType(obj,oneval);
                            dimvals.(fname{i}) = dvals;
                            dimrange.(fname{i}) = drange;
                            dimtype.(fname{i}) = dtype;
                            dimformat.(fname{i}) = dformat;
                            dimnames.(fname{i}) = fname{i};
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
                                        setDimensionType(obj,vals);
                    dimnames = {'Dim1'};               
                end
            end

            %update dstable object properties
            obj.DataTable.Properties.CustomProperties.Dimensions = dimvals;
            obj.DimensionRange = dimrange; 
            obj.DimType = dimtype;
            obj.DimensionFormats = struct2cell(dimformat)';
            obj.DimensionNames = struct2cell(dimnames)';
            addDimensionPropFields(obj);
            obj.LastModified = datetime('now');
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
            localObj = obj.DataTable.Properties.CustomProperties;
            if isempty(localObj.DimensionDescriptions)
                obj.DataTable.Properties.CustomProperties.DimensionDescriptions = fields;
            end
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
        function set.LastModified(obj,setdate)
            obj.DataTable.Properties.CustomProperties.LastModified = setdate;
        end        
        %
        function dateset = get.LastModified(obj)
            dateset = obj.DataTable.Properties.CustomProperties.LastModified;
        end
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
        function newdst = getDSTable(obj,varargin)
            %extract data from a dstable using the dimension data
            %and return a 'dstable' based on the selected dimension 
            %values. Update dimensions and preserve metadata
            % varargin can include
            [idr,idv,idd] = getInputIndices(obj,varargin{:});
            datatable = getDataUsingIndices(obj,idv,idr,idd);
            if isempty(datatable), newdst = []; return; end
            
            newdst = copy(obj);
            newdst.DataTable = datatable;  
            %if height of table has changed update Row range
            if height(datatable)~=height(obj.DataTable)
                inrows = newdst.RowNames;
                newdst.RowRange = {inrows(1),inrows(end)};                 
            end
            %if width of table has changed update Variable range            
            if width(datatable)~=width(obj.DataTable)
                newdst.VariableRange = [];              
            end
            updateVarNames(newdst);
            
            %if varargin includes 'Dimensions' amend arrays
            if ischar(varargin{1})                
                %dimension values defined by input vector
                %only updates the dimensions included in the input
                vars = varargin(1:2:end);
                idx = find(contains(vars,'Dimensions'));            
                if ~isempty(idx)
                    idv = idx*2-1;
                    for i=1:length(idv) 
                        parts = split(varargin{idv(i)},'.');
                        newdst.(parts{1}).(parts{2}) = varargin{idv(i)+1};
                    end
                end
            elseif length(varargin)>2  && ~isempty(varargin{3}) && ...
                                          ~isempty(newdst.Dimensions)
                %dimensions defined by index to existing values
                dimnames = newdst.DimensionNames;
                for i=1:length(idd)
                    oldims = newdst.Dimensions.(dimnames{i});
                    %set.Dimensions updates DimensionRange
                    newdst.Dimensions.(dimnames{i}) = oldims(idd{i});
                end
            end
            newdst.LastModified = datetime('now');
        end
%%
        function datatable = getDataTable(obj,varargin)
            %extract data from a dstable using the row,var,dim values or
            %indices and return a 'table' based on the selected values        
            [idr,idv,idd] = getInputIndices(obj,varargin{:});
            datatable = getDataUsingIndices(obj,idv,idr,idd);
        end
%%
        function dataset = getData(obj,varargin)
            %returns a cell array containing an array for each variable
            [idr,idv,idd] = getInputIndices(obj,varargin{:});
            [~,dataset] = getDataUsingIndices(obj,idv,idr,idd);
        end
%%
        function newdst = getsampleusingtime(obj,startime,endtime)
            %find the rows between the start and end times and return a
            %subsampled dstable
            dstime = isbetween(obj.RowNames,startime,endtime);
            newdst = getDSTable(obj,dstime,':');
            
            %tested following but also slow finding indeices            
            % idr = find(ismember(obj.RowNames,startime,'rows')); 
            % ide = find(ismember(obj.RowNames,endtime,'rows')); 
            % newdst = getDSTable(obj,idr:ide,':');
        end
%%
        function obj = activatedynamicprops(obj,varargin)
            updateVarNames(obj,varargin{:});
        end
%%
        function [names,desc,label,idv] = getAllAttributes(obj,idv)
            %find the names, descriptions  and labels of a selected variable 
            %its row and dimensions. Also returns idv as numeric index value
            % idv - numeric index, or a variable name
            if ~isnumeric(idv)
                idv = strcmp(obj.VariableNames,idv);
            end
            %return names (including RowNames) so that property can be
            %called using obj.(names{i})
            names = [obj.VariableNames(idv),{'RowNames'},obj.DimensionNames(:)'];
            %return descriptions for use in UIs etc
            desc = [obj.VariableDescriptions(idv),obj.RowDescription,...
                                        obj.DimensionDescriptions(:)'];
            varlabels = getLabels(obj,'Variable');
            label = [varlabels(idv),getLabels(obj,'Row'),...
                                            getLabels(obj,'Dimension')];                                              
            %should always be at least one variable and rows, or one dimension
            %remove unused "dimensions" and add undefined dimensions
            [vdim,~,vsze] = getvariabledimensions(obj,idv);
            setdims = sum(~cellfun(@isempty,names))-1;
            missingdims = vdim-setdims; 
            
            if vsze(1)==1
                if all(vsze(2:end)==1)         %variable with no rows and no dims                        
                    names = names(1);  desc = desc(1);  label = label(1);
                elseif isempty(obj.RowNames)   %single row with dims
                    names = names([1,3]);  desc = desc([1,3]);  label = label([1,3]);
                    if missingdims>0           %add missing if undefined
                        [names,desc,label] = addDimIndex(obj,names,desc,label,missingdims);
                    end
                elseif isempty(obj.Dimensions) %no dimensions for vector/array variable
                    nodefdims()
                else                           %row is a dimension
                    if all(vsze(2:end)==1)     %variable with rows but no dims
                        
                        names = names(1:2);  desc = desc(1:2);  label = label(1:2);
                    elseif isempty(obj.Dimensions) %no dimensions for vector/array variable
                        nodefdims()
                    else                       %variable with rows and dims
                        if missingdims>0       %add missing if undefined
                            [names,desc,label] = addDimIndex(obj,names,desc,label,missingdims);
                        end
                    end
                end
            else                               %multiple rows
                if all(vsze(2:end)==1) && isempty(obj.Dimensions)       
                    %variable with rows single dimension and no dims defined                    
                    names = names(1:2);  desc = desc(1:2);  label = label(1:2);
                elseif isempty(obj.Dimensions) %no dimensions for vector/array variable 
                   nodefdims()
                else                           %variable with rows and dims
                    if missingdims>0           %add missing if undefined
                        [names,desc,label] = addDimIndex(obj,names,desc,label,missingdims);
                    end
                end
            end
            %
            function nodefdims()
                %set default names for undefined dimensions (variables that
                %for any row are vectors or arrays, with no defined dimensions)
                idd = find(cellfun(@isempty,names));
                for ii=1:length(idd)
                   names{idd(ii)} = sprintf('noDim%d',ii);
                   desc{idd(ii)} = sprintf('Undefined dimension %d',ii);
                   label{idd(ii)} = 'Undefined dimension';
                end
            end
        end
%%
        function [names,desc,label,idv] = getVarAttributes(obj,idvar)
            %alternate to getVatAttributes to get the attribute lists when
            %a variable does not use all of the dimensions
             % idv - numeric index, or a variable name
            [names,desc,label,idv] = getAllAttributes(obj,idvar);
            %check that all assigned dimensions are being used for variable
            [~,cdim,vsze] = getvariabledimensions(obj,idv); 
            isrow = ~isempty(obj.RowNames);     %true if rows are being used
            nrowdim = isrow+cdim;               %number of rows and dimensions
            if length(names)-1>nrowdim  && ...  %-1 excludes variable
                  ~any(contains(names,'noDim')) %ignore if undefined dims used
                isdim = vsze(2:end)>1;          %active Dimensions ie n>1
                if isrow
                    isused = [true,true,isdim]; %variable,row,dimensions
                else
                    isused = [true,isdim];      %variable,diemsnions
                end
                names = names(isused);          %update lists
                desc = desc(isused);
                label = label(isused);
            end           
        end
%%
        function range = getVarAttRange(obj,list,selected)
            %return the range of the selected variable attribute
            % list - list of attributes or variable index (idvar)
            % selected - attibute to be used
            % range - min/max or start/end values for selected attribute
            if isnumeric(list)
                %if idvar is used in call (as list value) then use this
                %variable id to get the attribute descriptions
                [~,list] = getVarAttributes(obj,list);
            end
            %
            idvar = strcmp(obj.VariableDescriptions,list{1});  
            switch selected
                case list{1}            %Variable                  
                    varname = obj.VariableNames{idvar};
                    range = obj.VariableRange.(varname);
                case list{2}            %Row
                    if height(obj.DataTable)==1 && isempty(obj.RowNames)
                        dimname = obj.DimensionNames{1};
                        range = obj.DimensionRange.(dimname);
                    else
                        range = obj.RowRange;
                    end
                otherwise               %Dimension
                    %ensure offset is correct
                    if isempty(obj.RowNames), nr=2; else, nr=3; end 
                    idd = strcmp(list(nr:end),selected);                    
                    if isempty(obj.DimensionRange) && any(idd)
                        [~,~,vsze] = getvariabledimensions(obj,idvar);
                        range = {int16(1),int16(vsze(idd+1))};
                    else
                        dimname = obj.DimensionNames{idd};
                        range = obj.DimensionRange.(dimname);
                    end
            end            
        end
%%
        function [atname,atidx] = selectAttribute(obj,option)
            %propmpt user to select a dstable variable, or dimension
            % option - 1 or 'Variable'; 2 or 'Row'; 3 or 'Dimension'
            atidx = [];
            switch option             %get selection list for chosen option
                case {1,'Variable'}
                    selist = obj.VariableNames;
                case {2,'Row'}
                    atname = obj.TableRowName;
                    atidx = 1;
                    return;
                case {3,'Dimension'}
                    selist = obj.DimensionNames;
            end
            %
            if ~isempty(selist) && length(selist)>1
                [atidx,ok] = listdlg('Name','Variables', ...
                            'PromptString','Select a variable:', ...
                            'ListSize',[200,100],...
                            'SelectionMode','single', ...
                            'ListString',selist);
                if ok<1              %user cancelled no selection
                    atname = [];
                else                 %user selection from selist
                    atname = selist{atidx};
                end
            elseif ~isempty(selist)  %only one attribute in list
                atname = selist{1};
                atidx = 1;
            end                     
        end
%% ------------------------------------------------------------------------   
% Manipulate Variables - add, remove, move, variable range, horzcat,
% vertcat, sortrows, height, width, plot, mergerows
%--------------------------------------------------------------------------
        function newdst = addvars(obj,varargin)
            %add variable to table and update properties
            newdst = copy(obj);
            oldvarnames = newdst.VariableNames;
            %check if user is updating DSproperties
            iscmp = @(x) strcmp(x,'NewDSproperties');
            isdsp = cellfun(iscmp ,varargin,'UniformOutput' ,false);
            if any([isdsp{:}])              %modify varargin if using NewDSproperties
                idx = find([isdsp{:}]);
                varprops = varargin{idx+1}; %extract properties to use for NewDSproperties
                varargin(idx:idx+1) = [];   %remove NewDSproperties from varargin
            else
                varprops = [];
            end
            %update the table using Matlab addvars function
            newdst.DataTable = addvars(newdst.DataTable,varargin{:});
            if ~isempty(varprops)
                [newdsp,ok] = addDSproperties(obj.DSproperties,'Variables',varprops);
                if ok==1
                    newdst.DSproperties = newdsp;  %update the DSproperties property in the dstable     
                end
            end
            
            newvarnames = newdst.VariableNames;
            varnames = setdiff(newvarnames,oldvarnames);
            updateVarNames(newdst,varnames)              %active new dynamic variables and update ranges
            newdst.VariableRange = orderfields(newdst.VariableRange,newvarnames);
        end
%%
        function newdst = removevars(obj,varnames)
            %remove variable from table and update properties
            newdst = copy(obj);
            if ~iscell(varnames), varnames = {varnames}; end
            for i=1:length(varnames)
                newdst.(varnames{i}) = [];
            end
        end
%%
        function newdst =  movevars(obj,varname,position,location)
            %move variable in table and update properties
            %varname is character vector,string scalar,integer,logical array
            %position is 'Before' or 'After'
            %location is character vector,string scalar,integer,logical array
            newdst = copy(obj);
            newdst.DataTable = movevars(newdst.DataTable,varname,position,location);
            newvarnames = newdst.VariableNames;
            newdst.VariableRange = orderfields(newdst.VariableRange,newvarnames);
        end
%%
        function newdst = horzcat(obj1,varargin)
            %horizontal concatenation of two or more dstables
            %number of rows in each dstable must match and variable names
            %must be unique
            newdst = copy(obj1);  %new instance of dstable retaining existing properties
            for i=1:length(varargin)
                dst2 = varargin{i};
                if ~isa(dst2,'dstable'), newdst = issueWarning(1); return; end  %not a dstable
                %
                [table1,table2,chx] = getCatChecks(newdst,dst2);
                %number of rows must be same in both tables
                if ~chx.isheight, newdst = issueWarning(2); return; end
                %variable names in the two tables must be unique
                if any(chx.isvar), newdst = issueWarning(3); return; end
                %variable descriptions in the two tables must be unique
                if any(chx.isdsc), newdst = issueWarning(4); return; end
                %rownames in the two tables must be the same
                if ~all(chx.isrow), newdst = issueWarning(5); return; end
                %
                newdst.DataTable = horzcat(table1,table2);
            end
            
            %--------------------------------------------------------------
            function newdst = issueWarning(idx)
                newdst = [];
                msg = @(txt) sprintf('Invalid dstable objects: %s',txt); 
                switch idx
                    case 1
                        warndlg(msg,'not a dstable')
                    case 2
                        warndlg(msg('different number of rows'))
                    case 3
                        warndlg(msg('variable names  not unique'))
                    case 4
                        warndlg(msg('variable descriptions not unique'))
                    case 5
                        warndlg(msg('rownames do not match'))
                end
            end            
        end               
%%
        function newdst = vertcat(obj1,varargin)
            %vertical concatenation of two or more dstables
            %number and name of variables should be the same but can be in
            %different order
            %rows are sorted after concatenation into ascending order for
            %the source data type of the RowNames data 
            %metadata of dstable is derived from obj1
            newdst = copy(obj1);  %new instance of dstable retaining existing properties
            for i=1:length(varargin)
                dst2 = varargin{i};
                if ~isa(dst2,'dstable'), newdst = issueWarning(1); return; end  %not a dstable
                %
                [table1,table2,chx] = getCatChecks(newdst,dst2);
                %number of variables must be same in both tables
                if ~chx.iswidth, newdst = issueWarning(2); return; end
                %variable names in the two tables must be the same
                if ~all(chx.isvar), newdst = issueWarning(3); return; end
                %check for duplicates in rownames
                if any(chx.isrow), newdst = issueWarning(4); return; end
                %
                newdst.DataTable = vertcat(table1,table2);
            end

            %sort rows to be in ascending order 
            if ~isempty(newdst.RowNames)
                newdst = sortrows(newdst);
                newdst.RowRange = newdst.RowNames; 
            elseif isempty(newdst.RowNames) && height(newdst.DataTable)>1                
                newdst.RowNames = (1:height(newdst.DataTable))';
            end
            
            %update VariableRange
            updateVarNames(newdst,newdst.VariableNames)
            %--------------------------------------------------------------
            function newdst = issueWarning(idx)
                newdst = [];
                msg = @(txt) sprintf('Invalid dstable objects: %s',txt); 
                switch idx
                    case 1
                        warndlg(msg('not a dstable'))
                    case 2
                        warndlg(msg('number of variable do not match'))
                    case 3
                        warndlg(msg('different variable names'))
                    case 4
                        warndlg(msg('duplicate row names'))
                end
            end
        end          
%%
        function tableheight = height(obj)
            %map table height function to a dstable
            tableheight = height(obj.DataTable);
        end
%%
        function tablewidth = width(obj)
            %map table height function to a dstable
            tablewidth = width(obj.DataTable);
        end        
%%
        function h = plot(obj,variable,varargin)
            %overload plot function to plot variable against RowNames
            x = obj.RowNames;
            y = obj.(variable);
            h = plot(x,y,varargin{:});
        end
%%
        function obj = addrows(obj,rownames,varargin)
            %add rows to all variales in a dstable and sort into row order
            idw = width(obj)==length(varargin);          %check number of variables
            nvar = length(varargin);
            varnames = obj.VariableNames;
            idr = false(1,nvar); idv = idr;
            for i=1:nvar 
                [~,~,vsze] = getvariabledimensions(obj,varnames{i});
                newsze = size(varargin{i});
                idr(i) = length(rownames)==newsze(1);    %check number of rows of variable
                idv(i) = all(vsze(2:end)==newsze(2:end));%check other dimensions of variable
            end
            %
            if idw && all(idr) && all(idv) %add variables if all tests passed
                newrows = dstable(varargin{:},'RowNames',rownames);
                obj = vertcat(obj,newrows);
                updateVarNames(obj,varnames)
            else
                warndlg('Number of variables, or dimensions of variables, do not match table')
            end
        end
%%
        function obj = removerows(obj,rows2use)
            %remove rows from all variables in a dstable and update RowRange
            % rows2use can be index or RowNames values. The latter can be
            % in source data type format, or a string array or cell array 
            % as used by The RowNames property for a table.
            if ~isnumeric(rows2use) && ~iscell(rows2use)
                rows2use = cellstr(rows2use);
            end
            obj.DataTable(rows2use,:) = [];    %delete rows
            obj.RowRange = obj.RowNames;
            %re-assign VaraibleRange for each variable
            updateVarNames(obj,obj.VariableNames)
        end
%%
        function newdst = sortrows(obj)
            %sort the rows in the dstable DataTable and return updated obj
            %RowNames in a table are char and sortrows does not sort time
            %formats correctly. Sort in ascending order
            types = {'char','string','categorical','ordinal'};
            newdst = copy(obj);
            rowdata = newdst.RowNames;
            dtype = getdatatype(rowdata);
            if ismember(dtype,types)  
                %use sort_nat to sort numbered character RowNames
                if ismember(dtype,{'categorical','ordinal'})
                    rowdata = cellstr(rowdata);
                end
                [~,idx] = sort_nat(rowdata);
                newdst.DataTable = newdst.DataTable(idx,:);
            else
                %use dummy variable to sort numeric and time RowNames
                newdst.DataTable = addvars(newdst.DataTable,rowdata,...
                                                'NewVariableNames',{'sxTEMPxs'});
                newdst.DataTable = sortrows(newdst.DataTable,'sxTEMPxs');
                newdst.DataTable = removevars(newdst.DataTable,'sxTEMPxs');
            end
        end
%%
        function dst = mergerows(dst1,dst2) 
            %insert new timeseries, dst2, in correct position in dst1
            %table RowNames
            if ~strcmp(dst1.RowType,'datetime') || ~strcmp(dst1.RowType,'datetime')
                warndlg('One or more of the dstables does not use datetime Rows')
                dst = []; return;
            end
            oldrange = dst1.RowRange;
            addrange = dst2.RowRange;
            txt1 = sprintf('The range for the existing data is from %s to %s',datestr(oldrange{1}),datestr(oldrange{2}));
            txt2 = sprintf('The range for the new data is from %s to %s',datestr(addrange{1}),datestr(addrange{2}));            
            
            if addrange{1}>oldrange{2}      %new data is after existing record
                 dst = vertcat(dst1,dst2);
            elseif oldrange{1}>addrange{2}  %new data is before existing record
                dst = vertcat(dst2,dst1);
            elseif addrange{1}<=oldrange{1} && addrange{2}>=oldrange{2}
                %new data overlaps the entire existing date range
                txt3 = 'Do you want to add selected data? This will overwrite any existing data,';
                msg = sprintf('%s\n%s\n%s\n%s',txt1,txt2,txt3);
                answer = questdlg(msg,'Data input','Yes','No','No');
                if strcmp(answer,'No'), dst = dst1; return; end  %returns old dst                    
                dst = dst2;
            else  %new data overlaps one end, or sits within existing data range
                txt3 = 'The new data is, at least in part, within the time range of the existing data';
                msg = sprintf('%s\n%s\n%s\nDo you want to continue?',txt3,txt1,txt2);
                answer = questdlg(msg,'Data input','Yes','No','No');
                if strcmp(answer,'No'), dst = dst1; return; end  %returns old dst
                %add new data over interval addrange. Offset ensures no
                %duplicates. Existing data within interval is overwritten
                oldrows = dst1.RowNames;
                st_offset = addrange{1}-minutes(1);
                ts1 = isbetween(oldrows,oldrange{1},st_offset);

                se_offset = addrange{2}+minutes(1);
                ts2 = isbetween(oldrows,se_offset,oldrange{2});
   
                if ~any(ts1) && any(ts2)          
                    tsc2 = getDSTable(dst1,ts2);
                    dst = vertcat(dst2,tsc2);
                elseif any(ts1) && ~any(ts2)
                    tsc1 = getDSTable(dst1,ts1);
                    dst = vertcat(tsc1,dst2);
                elseif  any(ts1) && any(ts2)
                    tsc1 = getDSTable(dst1,ts1);
                    tsc2 = getDSTable(dst1,ts2);
                    dst = vertcat(tsc1,dst2,tsc2);
                else
                    %should not be here
                    dst = dst1;  %returns old dst
                end
            end  
        end
%%
        function obj = orderdims(obj,dimnames)
            %reorder the dimension fields in the order defined in dimnames.
            %the dimensions must exist            
            if length(obj.DimensionNames)==length(dimnames) && ...
                            all(ismember(obj.DimensionNames,dimnames))
                obj.Dimensions = orderfields(obj.Dimensions,dimnames);               
                obj.DimensionRange = orderfields(obj.DimensionRange,dimnames);
            else
                warndlg('Ordered dimension name do not match existing dimension names')
            end
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
            errtxt = 'Error in DSproperties. Unable to assign dsproperties';
            if isa(dsprops,'struct')
                dsprops = dsproperties(dsprops,nullDescription(obj));
                if ~isempty(dsprops.errmsg)
                    warndlg(sprintf('%s\n%s',errtxt,dsprops.errmsg))
                    return;
                end
            elseif ~isa(dsprops,'dsproperties')
                warndlg('Unrecognised input format')
                return;
            end
            %check that number of variables matches table
            isvalid = width(obj.DataTable)==length(dsprops.Variables);
            
            %check that the first variable has dimensions that match the
            %dimension properties and if not warn user
            [~,cdim,~] = getvariabledimensions(obj,1);     %number of dimensions for first variable (exc rows)
            dspdim = length({dsprops.Dimensions(:).Name}); %number of named dimensions
            if dspdim==1 && isempty(dsprops.Dimensions.Name)
                %the Dimensions struct is empty
            elseif dspdim>1 && cdim~=dspdim  %more than one named dimension but not equal to number of variable dimensions 
                txt1 = sprintf('The first variable has %d dimensions and %d property dimensions are defined',cdim,dspdim);
                txt2 = 'Select option:';
                qtext = sprintf('%s\n%s',txt1,txt2);
                answer = questdlg(qtext,'Dimensions',...
                    'Set to Variable size','Abort','Set to Variable size');
                switch answer
                    case 'Set to Variable size'
                        if cdim<dspdim
                            dsprops.Dimensions = dsprops.Dimensions(1:cdim);
                        else
                            txt2 = 'Not enough Dimension names defined';
                            warndlg(sprintf('%s\n%s',errtxt,txt2))
                            return;
                        end
                    case 'Abort'
                        return;
                end
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
        function tsc = dst2tsc(obj,varargin)
            %convert dstable object to a tscollection 
            % idxtime - index vector for the subselection of time
            % idxvars - index vector for the subselection of variables, or the 
            %           variable names as a cell array of character vectors 
            if nargin>1
                obj = getDSTable(obj,varargin{:});
            end
            
            T = obj.DataTable;
            tsTime = obj.RowNames;
            if isa(tsTime,'duration')
                tsTime = datetime(sprintf('01-Jan-%d 00:00:00',0))+tsTime; 
            end
            tsTime = cellstr(tsTime);  
            %
            tsc = tscollection(tsTime);
            for j=1:width(T)               
                tsobj = timeseries(T{:,j},tsTime);                
                tsobj.Name =obj.VariableNames{j};
                tsobj.QualityInfo.Code = [0 1];
                tsobj.QualityInfo.Description = {'good' 'bad'};
                if width(T)==1
                    tsc = tsobj;
                else
                    tsc = addts(tsc,tsobj);
                end
            end
            tsc.Name = obj.Description;
            tsc.TimeInfo.UserData = copy(obj.DSproperties);
        end
%%
        function fields = allfieldnames(obj)
            %return cell array of all field names in order
            %{variables,row,dimensions}
            fields = horzcat(obj.VariableNames,obj.TableRowName,...
                                                    obj.DimensionNames);
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
            addCustomProperties(obj,{'LastModified','Source','MetaData'},...
                                                {'table','table','table'});   
        end        
%% Variables
        function updateVarNames(obj,varnames)
            %define or update dynamic properties and variable ranges
            if nargin<2
                varnames = obj.VariableNames;
            end
            
            for i=1:length(varnames)
                varname = varnames{i};
                if ~isprop(obj,varname)  %variable added
                    obj.add_dyn_prop(varname, [], false);                    
                end
                obj.VariableRange.(varname) = getVariableRange(obj,varname);
            end 
            obj.LastModified = datetime('now');
        end
%%
        function range = getVariableRange(obj,varname)
            %find the minimum and maximum value of the data in varname 
            %if numeric otherwise return first and last value
            data = obj.DataTable.(varname);
            if isempty(data), range = []; return; end
            if isnumeric(data)   %vector and array data
                minval = (min(data,[],'all','omitnan'));
                maxval = (max(data,[],'all','omitnan'));
                range = {minval,maxval};
            elseif iscell(data)  %character arrays
                range ={data{1},data{end}};
            else                 %string arrays, datetime, duration, etc
                range = {data(1),data(end)};
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
                inputrow = obj.DataTable.Properties.RowNames{1}; %returns char
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
        function [dvals,drange,dtype,dformat] = setDimensionType(~,indims)
            %check dimension type and return values as a char array
            % indims - input dimension array
            % idx - index of dimension
            % dim.vals - char array of values in indims
            % dim.type - variable type used for indims
            % dim.format - char array of format for datetime and duration
            % range - min/max or start/end values
            if isrow(indims), indims = indims'; end %make column vector
            imin = 1;  imax = length(indims);       %default index for range
            dformat = [];
            [dvals,dtype] = var2str(indims);
            
            if isdatetime(indims) || isduration(indims)
                dformat = indims.Format;
            elseif isnumeric(indims)
                [~,imin] = min(indims);
                [~,imax] = max(indims);
            end
            
            if iscell(indims)  %character arrays
                drange ={indims{imin},indims{imax}};
            else                 %string arrays, datetime, duration, etc
                drange = {indims(imin),indims(imax)};
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
                dimformat = obj.DimensionFormats{1};
            else
                dimtype = obj.DimType.(dimname);                
                dimnum = strcmp(obj.DimensionNames,dimname);
                dimformat = obj.DimensionFormats{dimnum};
            end
            %
            outdims = str2var(source,dimtype,dimformat);
        end
%%
        function addDimensionPropFields(obj)
            %check that Dimension metadata properties have cell arrays that
            %are the same length as the number of Dimensions
            ndim = length(obj.DimensionNames);
            obj.DimensionDescriptions = checkProperty(obj.DimensionDescriptions,ndim);
            obj.DimensionUnits = checkProperty(obj.DimensionUnits,ndim);
            obj.DimensionLabels = checkProperty(obj.DimensionLabels,ndim);
            obj.DimensionFormats = checkProperty(obj.DimensionFormats,ndim);
            
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
        function [datatable,datacell] = getDataUsingIndices(obj,idv,idr,idd)
            %extract data from a table using variable, row and dimension
            %indices
            % idv - numerical or logical indices for variables
            % idr - numerical or logical indices for rows
            % idd - cell array fo numerical or logical indices for each
            %       dimension
            datatable = obj.DataTable(idr,idv);     %dstable table
            %assume that dims are in order x,y,z etc and that
            %the variable has at least as many dimensions as the
            %number of dimensions defined for the DataTable  
            numvar = length(idv);
            datacell = cell(1,numvar);
            for k=1:numvar             %for each selected variable
                data = datatable.(k);  %extract variable data from table
                data = data(:,idd{:}); %subsample data set
                datatable.(k) = data;  %assign sub-sampled data to table
                datacell{1,k} = data;
            end           
        end
%%
        function [idr,idv,idd] = getInputIndices(obj,varargin)
            %parse input to define row, variable and dimension indices
            %Note: native data type values for row or dimensions can only 
            %be input using thefull syntax of Name,Value, other formats 
            %are assumed to be indices
            idr = []; idv = []; idd = {};
            [~,cdim,vsze] = getvariabledimensions(obj,1);
            if ischar(varargin{1})  %unpack Name,Value input
                inputvargs = getDimensionInput(obj,cdim,varargin{:});
            else                     %unpack array of 1,2, or 3 index vectors
                inputvargs = getIndexInput(obj,cdim,varargin{:});
            end   
            if isempty(inputvargs), return; end

            %now assign indices to any unassigned row,var,dim indices
            nvar = width(obj.DataTable);  %number of variables
            nrow = vsze(1);               %number of rows
            ndim = vsze(2:end);           %length of each dimension

            if isempty(inputvargs{1})     %asign row indices
                idr = 1:nrow;
            else
                idr = inputvargs{1};
                %when input is a datatime 
                if isa(idr,'datetime')
                    idr = cellstr(idr);
                end
            end

            if isempty(inputvargs{2})     %aasign variable indices
                idv = 1:nvar;
            else
                idv = inputvargs{2};   
            end

            idd = inputvargs{3};
            if isempty(idd)               %aasign dimension indices
                for j=1:length(ndim)
                    idd{j} = 1:ndim(j);
                end
            else
                for j=1:length(idd)
                    if isempty(idd{j})
                        idd{j} = 1:ndim(j);
                    end
                end
            end
        end
%%
        function newvargin = getDimensionInput(obj,cdim,varargin)
            %unpack input provided in dimension format and return as indices
            idr = []; idv = []; idd = cell(1,cdim);
            narg = length(varargin);
            for i=1:2:narg
                if strcmp(varargin{i},'RowNames')
                    idr = find(ismember(obj.RowNames,varargin{i+1},'rows'));  
                    if isdatetime(idr) || isduration(idr)
                        %if input is datetime or duration force match to rows format
                        idr.Format = obj.RowFormat;
                    end
                elseif strcmp(varargin{i},'VariableNames')
                    idv = find(ismember(obj.VariableNames,varargin{i+1}));  
                elseif contains(varargin{i},'Dimensions')
                    parts = split(varargin{i},'.');
                    idx = ismember(obj.DimensionNames,parts{2}); %index to Dimensions field name
                    dimvals = obj.Dimensions.(parts{2});
                    idd{idx} = find(ismember(dimvals,varargin{i+1})); 
                    if isdatetime(idd{idx}) || isduration(idd{idx})
                        %if input is datetime or duration force match to rows format
                        idd{idx}.Format = obj.DimensionFormats{idx};
                    end
                else
                    warndlg(sprintf('Unknown input type: %s',varargin{i}))
                    newvargin = {};
                    return;
                end
            end
            newvargin = {idr,idv,idd};
        end
%%
        function newvargin = getIndexInput(~,cdim,varargin)
            %unpack input provided in index format
            narg = length(varargin);
            if narg<3
                newvargin = cell(1,3);
                newvargin(1:narg) = varargin;
            elseif narg==3 && length(varargin{3})==cdim
                %dimension indices with a cell for each dimension
                newvargin = varargin;
            elseif narg==3 && cdim==0
                %dimension specified but is single valued (variable is a row vector)
                newvargin = [varargin{1:2},varargin(3:end)];
            elseif narg==3 && length(varargin{3})==cdim-1
                %dimension specified but also uses row as a single valued dimension
                newvargin = [varargin{1:2},varargin(3:end)];    
            elseif narg-2==cdim 
                %dimension indices specified individually
                newvargin = [varargin{1:2},varargin(3:end)];
            else
                msgtxt = sprintf('%s\n%s','Invalid number of indices specified',...
                                 'Error in call to dstable.getIndexInput');
                warndlg(msgtxt);
                newvargin = {};
            end  
        end
%%
        function [names,desc,label] = addDimIndex(~,names,desc,label,missingdims)
            %some dimensions are undefined so add dummy names and labels
            nrec = length(names);
            for i=1:missingdims
                names{nrec+i} = sprintf('Index%d',i);
                desc{nrec+i} = sprintf('Index %d',i);
                label{nrec+i} = sprintf('Index %d',i);
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
            dsp = [];
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
                        dsp = geta_DSprop(obj,dsp,dspnames{i},fnames{j},...
                                                          propname);
                    else
                        seta_DSprop(obj,dsprops,dspnames{i},fnames{j},...
                                                          propname,isrow);
                    end
                end
            end            
        end
%%
        function dsp = geta_DSprop(obj,dsp,dspname,fname,propname)
            %check propname format and add propname value to dsp field
            if isempty(obj.(propname))  %dstable property
                %pad empty fields to the number of variables
                if contains(propname,'Names')
                    %no variables/row/dimension names defined
                    nvar = 1;
                elseif ischar(dsp.(dspname).Name)
                    %just a single variable/row/dimension
                    nvar = 1;
                else
                    %multiple variables/row/dimension
                    nvar = length(dsp.(dspname).Name);
                end
                dsp.(dspname).(fname) = repmat({''},1,nvar);
            else
                dsp.(dspname).(fname) = obj.(propname);
            end   
        end
%%
        function seta_DSprop(obj,dsprops,dspname,fname,propname,isrow)
            %extract value from dsprops and assign to propame of obj
            if isrow %handle row fields to avoid nesting cells
                if strcmp(propname,'RowFormat')
                    if strcmp(obj.RowType,'datetime') || ...
                                strcmp(obj.RowType,'duration')                        
                       dsprops.(dspname).(fname) = ...
                           checkRowDimFormat(obj,dsprops,dspname);
                    end                                                                                              
                end
                obj.(propname) = dsprops.(dspname).(fname); 
            else
                if length(dsprops.(dspname))>1 || ...      %--added 24/2/21
                            (length(dsprops.(dspname).(fname))>=1 && ...
                             ~iscell(dsprops.(dspname).(fname)))  
                    propvalues = {dsprops.(dspname).(fname)};                                    
                elseif isempty(dsprops.(dspname).(fname))                    
                    propvalues = {''};                     
                else
                    propvalues = dsprops.(dspname).(fname);
                end
                %                                          %-^------------^
                if strcmp(propname,'VariableNames')      
                    obj.(propname) = propvalues;
                    updateVarNames(obj)
                elseif strcmp(propname,'DimensionFormats')
                    if strcmp(obj.DimType,'datetime') || ...
                                strcmp(obj.DimType,'duration')                        
                       dsprops.(dspname).(fname) = ...
                          checkRowDimFormat(obj,dsprops,dspname);
                    end 
                    obj.(propname) = propvalues;
                else
                    obj.(propname) = propvalues;
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
            %variable descriptions in the two tables must be the same
            dscnames1 = table1.Properties.VariableDescriptions;
            dscnames2 = table2.Properties.VariableDescriptions;
            chx.isdsc = ismember(dscnames1,dscnames2);
            %check for duplicates in rownames
            rownames1 = table1.Properties.RowNames;
            rownames2 = table2.Properties.RowNames;
            chx.isrow = ismember(rownames1,rownames2);
        end
 %%
        function labels = getLabels(obj,fieldname)
            %construct a label from description and unit fields
            f1 = sprintf('%sLabel',fieldname);
            f2 = sprintf('%sDescription',fieldname);
            f3 = sprintf('%sUnit',fieldname);
            if ~strcmp(fieldname,'Row')
                f1 = [f1,'s']; f2 = [f2,'s']; f3 = [f3,'s'];
            end
            
            labels = obj.(f1);  
            desc = obj.(f2);
            unit = obj.(f3);
            if ~iscell(labels), labels = {labels}; end
            if ~iscell(desc), desc = {desc}; end
            if ~iscell(unit), unit = {unit}; end
            for i=1:length(labels)                
                if isempty(labels{i}) 
                    labels{i} = '';
                    if ~isempty(desc) && ~isempty(unit)
                        labels{i} = sprintf('%s (%s)',desc{i},unit{i});
                    end
                end
            end
        end       
    end
end