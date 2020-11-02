%% dstable
% A dstable object is a collection of one or more datasets with one
% or more common dimension vectors. A dstable can contain different variable
% types, have row indexing of different types, and access multi-dimensional  
% arrays with dimension indexing
%
%% Syntax
%
%   dst = dstable(var1,...,varN)
%   dst = dstable('Size',sz,'VariableTypes',varTypes)
%   dst = dstable(___,'VariableNames',varNames)
%   dst = dstable(___,'RowNames',rowNames)
%   dst = dstable
%
%%
% This syntax is similar to the <matlab:doc('table') table> syntax and
% is used in the same manner. Additional options for a _dstable_ include
% the following:
%%
%   dst = dstable(___,'DimensionNames',dimNames)
%   dst = dstable(___,'DSproperties',dsProps)
%%
% where dimNames are the field names of the dimensions of the table. The
% key word DSproperties is used to load a <matlab:doc('dsproperties') dsproperties> object, dsProps.
% This allows Variable, Row and Dimensions metat-data properties to added
% and is an alternative to using VariableNames and DimensionNames (i.e. cannot
% use both in the same call).
% 
%% Description
% A dstable holds a table in the property DataTable. This table retains
% all the properties and methods of a Matlab <matlab:doc('table') table>.
% Once initialised a dstable can be used to access and use the table 
% by using the following assignment:
%%
%   T = dst.DataTable;
%% 
% The additional properties used by dstable are all assigned to the
% CustomProperties object that is a property of _table_. However, all
% properties can be set and accessed using the dstable directly. For
% example:
%%
%   dst.(variableName)
%   dst.RowNames
%   dst.Dimensions.(dimensionName)
%   etc
%
% Alternatively, the properties of the _table_ can be set and accessed 
% using the standard _table_ <matlab:doc('access-data-in-a-table') Access Data in a Table> syntax, such as: 
%% 
%   T.Properties.(variableName)
%   T.Properties.CustomProperties.(propertyName)
% 

%% Input arguments
% These are the same as for <matlab:doc('table') table> with the exception
% of _rowNames_ and the addition of dimNames and dsProps.
%%
% *rowNames* <br>
% Names of the rows in the output table, specified as a cell array of 
% character vectors, a string array, a datetime array, a duration array, or 
% a numeric vector. The number of names in rowNames must equal the number
% of rows for the variables being added. rowNames must define each row 
% using distinct, non-empty values.
%
% *dimNames* <br>
% Names of the dimensions to be included with the table, specified as a cell 
% array of character vectors or a string array, whose elements are nonempty 
% and distinct. Dimension names must be valid MATLAB identifiers. 
%
% *dsProps* <br>
% a struct or a <matlab:doc('gdsproperties') dsproperties> object defining
% the metadata for the Variables, Row and Dimensions of the _table_.
%

%% Assign and access Variables and Dimensions
% Variables and dimensions can be assigned and accessed using dot syntax, as follows:
%%
%   dst.variableName = vardata;        %assign vardata to the variable
%   dst.variableName = [];             %clear the variable
%   vardata = dst.variableName;        %assign the variable to vardata
%
%   dst.Dimensions.dimName = dimdata;  %assign dimdata to the dimension
%   dst.Dimensions.dimName = [];       %clear the dimension
%   dimdata = dst.Dimensions.dimName;  %assign the dimension to dimdata
%

%% Assign and access Metadata Properties
% The metadata for Variables, Row and Dimenions can be assigned and
% accessed using a <matlab:doc('dsproperties') dsproperties> object. 
% A dsproperties object or struct can be assigned to a dstable and this
% overwrites any existing metadata that may have been assigned (including
% all Variable, Row and Dimension names), The dsproperties struct array
% should match the numbeer of variables and number of dimensions that havbe
% been loaded into _dstable_.
%%
%   dst.DSproperties = dsprop;   %assigns struct or dsproperties object to the dstable 
%%
% To examine the current dsproperties pass the DSproperties property of a
% dstable to the display UI for dsproperties, as follows:
%%
%   displayDSproperties(dst.DSproperties);  %UI table of the dstable properties
%   
%%
% Individual metadata properties for variables and dimensions are accessed
% with the variable or dimension index as follows:
%%
%   dst.variableProperty(index) = value  %variableProperty is any dstable metadata property
%   dst.rowProperty = value              %rowProperty is any dstable metadata property
%   dst.dimensionProperty(index) = value %dimensionProperty is any dstable metadata property
%%
% The assigned _value_ should be the same as any existing assignments or
% be specified in accordance with the Metatdata Property specification.
%

%% dstable Properties
% *DataTable* <br> This property holds the _table_ object.
%%
% *Dimensions* <br> Addional dimensionns are equivalent to additional Rows.
% They allow multi-dimensional variables (e.g an [x, y, z, t] dataset) to be
% indexed using any of the dimensions (see section on *Indexing Methods*).
%%
% The default is one set of _Dimensions_ applicable to all variables in the table. 
%
% Dimensions must also apply to all row values of a variable. For example
% if Rows are assigned as the time dimension, with two further dimensions
% for X and Y, the variable will be an (_k_ x _m_ x _n_) array, where _k_, _m_,
% and _n_ are the t, X, Y dimensions. If the X and Y dimensions vary with
% time (e.g. sampling intervals in X or Y change with time) then the X and 
% Y dimensionsshould be added as time dependent variables.
%  

%% dstable Metadata Properties
% *Access Table Metadata Properties* <br>
% A dstable contains metadata properties that describe the table, its
% variables and the 'dimensions' in the Row and Dimensions properties.
%%
% Access these properties using the syntax
% _dstableName_. _PropertyName_ , where _PropertyName_ is the 
% name of a property. For example, you can access the names of the 
% variables in dstable, dst, using the syntax dst.VariableNames, or 
% using the table syntax T.Properties.VariableNames (where T = dst.DataTable).
%%
% You can return a summary of all the metadata properties using the syntax
% _dstableName_ or _tableName_.Properties.
%%
% dstable provides direct access to metadata because the table is 
% assigned to the DataTable property (necessary because it cannot be a
% Superclass). In contrast tables access metadata through the Properties property, 
% allowing the table data to be accessed directly using dot syntax. 
% For example, if table T has a variable named Var1, then you can access 
% the variable as an array using the syntax T.Var1. For a dstable the
% equivalent syntax would be dst.Var1, or dst.DataTable.Var1.

%% table Metadata Properties
% These are the same as for <matlab:doc('table') table> with the exception
% of _RowNames_ (see *Input Arguments* above). 

%% Variable Metadata Properties
% These are the same as for <matlab:doc('table') table> with the addition
% of VariableLabels and VariableQCflags.
%%
% *VariableLabels* <br>
% Variable labels, specified as a cell array of character vectors, or 
% a string array. This property can be an empty cell array, which is the default. 
% If the array is not empty, then it must contain as many elements as there 
% are variables. You can specify an individual empty character vector, or 
% empty string, for a variable that does not have a label. These are
% typicaly used to provide a more generic short desctiption that might be
% used to label several variables of the same type (e.g. 'Velocity').
%
% *VariableQCflags* <br>
% VAriable quality control flags, specified as a cell array of character vectors, or 
% a string array. This property can be an empty cell array, which is the default. 
% If the array is not empty, then it must contain as many elements as there 
% are variables. You can specify an individual empty character vector, or 
% empty string, for a variable that does not have a label.  

%% Row Metadata Properties
% *RowDescription* <br>
% Row descriptions, specified as a cell array of character vectors or 
% a string array This property can be an empty cell array, which is the 
% default.
%
% *RowUnit* <br>
% Row units, specified as a cell array of character vectors or a string 
% array. This property can be an empty cell array, which is the default.
%
% *RowLabel* <br>
% Row labels, specified as a cell array of character vectors or a string 
% array. This property can be an empty cell array, which is the default.
%
% *RowFormat* <br>
% Row format is specified as a <matlab:doc('datetime') datetime> or 
% <matlab:doc('duration') duration> format string. 
% This property can be an empty cell array, which is the default.

%% Dimension Metadata Properties
% *DimensionNames* <br>
% Dimension names, specified as a cell array of character vectors or 
% a string array, whose elements are nonempty and distinct. Variable names 
% must be valid MATLAB identifiers. You can determine valid variable names 
% using the function <matlab:doc('isvarname') isvarname> . MATLAB removes 
% any leading or trailingwhitespace from the variable names. The number 
% of names must equal the number of dimensions defined. However
% Dimensions can be added using dot indexing with a DimensionField name, as
% explained below.
% 
% *DimensionDescriptions* <br>
% Dimension descriptions, specified as a cell array of character vectors or 
% a string array This property can be an empty cell array, which is the 
% default. The number of descriptions must equal the number of dimensions defined. 
% You can specify an individual empty character vector or empty string for 
% a variable that does not have a description.
%
% *DimensionUnits* <br>
% Dimension units, specified as a cell array of character vectors or a string 
% array. This property can be an empty cell array, which is the default.
% The number of descriptions must equal the number of dimensions defined. 
% You can specify an individual empty character vector or empty string for 
% a variable that does not have a description.
%
% *DimensionLabels* <br>
% Row labels, specified as a cell array of character vectors or a string 
% array. This property can be an empty cell array, which is the default.
% The number of descriptions must equal the number of dimensions defined.
% You can specify an individual empty character vector or empty string for 
% a variable that does not have a description.
%
% *DimensionFormats* <br>
% Row format is specified as a <matlab:doc('datetime') datetime> or 
% <matlab:doc('duration') duration> format string. 
% This property can be an empty cell array, which is the default.
% The number of descriptions must equal the number of dimensions defined. 
% You can specify an individual empty character vector or empty string for 
% a variable that does not have a description.
%

%% Custom Properties
% These can be added to the _table_ held in the dst.DataTable property 
% as detailed in <matlab:doc('table') table>.
%%
% In a dstable a number of properties are added to the CustomPoperties
% object by default. These are detailed in the sections below. 
%%
% To add or remove Custom Properties in a dstable use the following
% two functions:
%%
%   dst = addCustomProperties(dst,'propertyName','propertyType'); %to add a property
%   dst = rmCustomProperties(dst,'propertyName');                 %to remove a property
% 
%%
% These incoke the _table_ equivalents of addprop and rmprop - see
% <matlab:doc('addprop') addprop> and <matlab:doc('rmprop') rmprop>.
%
%%
% To add or remove dynamic properties on a dstable use:
%%
%   p = addprop(dst, propertyName);  %adds property and returns meta.DynamicProperty object
%   rmprop(obj,propertyName);        %removes propertyName from the dstable
%  

%% dstable methods
% Methods that can be used for a table can be used on T = dst.DataTable.
%%
% A subset of these methods have specific implementations for a _dstable_
% that ensures that the properties defining Variable, Row and Dimension
% meta-data are preserved. These functions are as follows:
%%
% *addvars* syntax is the same as <matlab:doc('addvars') addvars>. Updates metadata properties for new variable
%%
%   addvars(dst, varargin)  
%%
% *removevars* syntax is the same as <matlab:doc('removevars') removevars>
%%
%   dst2 = removevars(dst,'varNames')   
%%
% *movevars* syntax is the same as <matlab:doc('movevars') movevars>. varName is the
% variable to be moved, position is 'Before' or 'After' and location is
% the name of the reference variable to use for the move.
%%
%   movevars(dst,'varName','position','location)            
%%
% *vercat* vertically concatenates the two dstables, variable names
% must match and RowNames in the two dstables must be unique.
% Sorts new table into ascending order, and updates RowRange property
%%
%   dst3 = vertcat(dst1, dst2)     
%% 
% *horzcat* horizontally concatenates the two dstables, variable names 
% must be unique. Retains the meta-data of both tables
%%
%   dst3 = horzcat(dst1, dst2)     
%%
% *plot* overloads plot to extract the RowNames and the values for varName
% and passes thes to plot with any additional input variables 
% accepted by <matlab:doc('plot') plot>. Returns the plot handle, h.
%%
%   h = plot(dst,'varName',varargin) 
%

%%
% The following functions are specific to a _dstable_.
%%
% *sortrows* sort table into ascending order of RowNames
%
%   sortrows(dst)                         %sort table into ascending order of RowNames 
%
% *dst2tsc* and *tsc2dst* convert between dstable and tscollection objects 
% (see <matlab:doc('dst2tsc') dst2tsc> and <matlab:doc('tsc2dst') tsc2dst> for further
% details).
%
%   tsc = dst2tsc(dst,idxtime,idxvars)    %converts a dstable object to a tscollection object
%   dst = tsc2dst(tsc,idxtime,idxvars)    %converts a tscollection to a dstable object
%%
% idxtime - index vector for the subselection of time <br>
% idxvars - index vector for the subselection of variables, or the variable
% names as a cell array of character vectors  
%%
% When creating tscollection the DSproperties of the dstable are passed and
% stored in tsc.TimeInfo.UserData. If a tscollection has DSproperties defined,
% these are restored when a dstable object is created from a tscollection object.
% 

%% dstable Indexing Methods
% Data held in a dstable can be accessed by rows, variables and/or
% dimensions.

%%
% Using the _table_, T = dst.DataTable, the syntax to extract rows 
% and variables is the same as summarised in 
% <matlab:doc('access-data-in-a-table') Access Data in a Table>.
%
% To access a subset of values using the dimension indices the syntax can
% be any of the following:

%%  
%   extracted_data = T.DataTable{rows,vars}(dim1,dim2,...,dimN)
%   extracted_data = T.var(dim1,dim2,...,dimN)
%   extracted_data = T.(varindex)(dim1,dim2,...,dimN)
%   extracted_data = T.var(rows)(dim1,dim2,...,dimN)
%%
% where rows, vars, dim1,...dimN are indices specified as a colon, 
% numeric indices, or logical expressions.  dim1 is the row dimension and
% can either be set to : or a subselection of the array returned wnen rows are
% included in the call.
%%
% Using a dstable there is also the option to use the dimension values 
% (including rows) to access data in the table. The syntax is as follows:

%%
%   newT = getData(dst,'Name','Value'); 
%   newdst = getDStable(dst,'Name','Value')
%%
% where the 'Name', 'Value' pairs can be any of the following combinations:
%%
% 'VariableNames', varnames - where varnames is a subset of the variable names to be used, 
% specified as a cell array of character vectors, or a string array.  
%%
% 'RowNames', rowames - where rownames is a subset of the rows to be used, specified in the
% format used for RowNames
%%
% 'Dimensions.dimName', dimnames - where dimnames is a subset of the dimension dimName to be
% used, specified in the format used for the dimension.

%% See Also
% <matlab:doc('dsproperties') dsproperties>, <matlab:doc('dscatalogue') dscatalogue>, 
% <matlab:doc('dscollection') dscollection>, <matlab:doc('dstoolbox') dstoolbox>.







