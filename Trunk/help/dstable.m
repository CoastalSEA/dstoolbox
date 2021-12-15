%% dstable
% A dstable object is a collection of one or more datasets with one
% or more common dimension vectors. A dstable can contain different variable
% types, have row indexing of different types, and access multi-dimensional  
% arrays with dimension indexing.
%
%% Syntax
%
%   dst = dstable(var1,.. ,varN)
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
%%
% The variables in a _dstable_ can also be loaded using a _table_, with any
% of the above 'Name', 'Value' syntax.
%%
%   dst = dstable(vartable)
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
% a struct for a <matlab:doc('dsproperties') dsproperties> object defining
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

%% Variable assignment formats
% The format of the input variable(s) determines how the data are assigned
% to the _dstable_. As well as individual variable assignments, as shown 
% above, a cell array of variables can be assigned using the following syntax:
%%
%   dst = dstable(inputvars)    %where inputvars is a numeric array
%   dst = dstable(inputvars{:}) %where inputvars is a cell array
%%
% The format of the data in _inputvars_ can be any of the following:

%%
% <html>
% <table border=1>
% <tr><td><b>Array type</b></td><td><b>Variable<b></td><td><b>Data type</b></td><td><b>Data format</b></td></tr>
% <tr><td>single row vector</td><td>single</td><td>numeric array</td><td>1xM numerical array</td></tr>
% <tr><td>single row matrix</td><td>single</td><td>numeric array</td><td>1xMxN numerical array</td></tr>
% <tr><td>single row vector</td><td>multiple</td><td>cell array</td><td>1xM numerical arrays</td></tr>
% <tr><td>single row matrix</td><td>multiple</td><td>cell array</td><td>1xMxN numerical arrays</td></tr>
% <tr><td>multi row vector</td><td>single</td><td>numeric array</td><td>RxM numerical array</td></tr>
% <tr><td>multi row matrix</td><td>single</td><td>numeric array</td><td>RxMxN numerical array</td></tr>
% <tr><td>multi row vector</td><td>multiple</td><td>cell array</td><td>RxM numerical arrays</td></tr>
% <tr><td>multi row matrix</td><td>multiple</td><td>cell array</td><td>RxMxN numerical arrays</td></tr>
% </table>
% </html>

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
%   dst.variableProperty{index} = value  %variableProperty is any dstable metadata property
%   dst.rowProperty = value              %rowProperty is any dstable metadata property
%   dst.dimensionProperty{index} = value %dimensionProperty is any dstable metadata property
%%
% The assigned _value_ should be the same as any existing assignments or
% be specified in accordance with the Metatdata Property specification.
%

%% dstable Properties
% *DataTable* <br> This property holds the _table_ object.
%%
% *Dimensions* <br> Addional dimensions are equivalent to additional Rows.
% They allow multi-dimensional variables (e.g an [x, y, z, t] dataset) to be
% indexed using any of the dimensions (see section on *Indexing Methods*). 
%%
% The _Dimensions_ are applicable to all variables in the table (i.e. they
% are not variable specific). <br> 
% Each dimension is held and returned as a column vector. <br>
%
% Dimensions must also apply to all row values of a variable. For example
% if Rows are assigned as the time dimension, with two further dimensions
% for X and Y, the variable will be a (_k_ x _m_ x _n_) array, where _k_, _m_,
% and _n_ are the t, X, Y dimensions. If the X and Y dimensions vary with
% time (e.g. sampling intervals in X or Y change with time) then the X and 
% Y dimensions should be added as time dependent variables.
%%
% <html>
% <table border=1><tr><td>Limitation - the Dimensions are not variable 
% specific and the Dimension vectors are not checked for compatibility 
% with any of the variable arrays. However, by adding multiple Dimensions, 
% different Dimensions can be used in conjunction with different variables.
% </td></tr></table>
% </html>

%%
% *LastModified* <br>
% Date when variables or dimensions of the _dstable_ were created or last modified
%%
% *Source* <br>
% Description of data source, model used, etc
%%
% *MetaData* <br>
% Additional user data, such as more detailed description of table, version
% of model used to generate input, etc.

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
% *VariableNames* <br>
% Variable Names, specified as a cell array of character vectors or 
% a string array This property can be an empty cell array, which is the 
% default.
%
% *VariableDescriptions* <br>
% Variable descriptions, specified as a cell array of character vectors or 
% a string array This property can be an empty cell array, which is the 
% default. 
%
% *VariableUnits* <br>
% Row units, specified as a cell array of character vectors or a string 
% array. This property can be an empty cell array, which is the default.
%
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
% Variable quality control flags, specified as a cell array of character vectors, or 
% a string array. This property can be an empty cell array, which is the default. 
% If the array is not empty, then it must contain as many elements as there 
% are variables. You can specify an individual empty character vector, or 
% empty string, for a variable that does not have a label.  
%
% *VariabelRange* (read only) <br>
% Set internally when variables are loaded or updated. Defines the minimum 
% and maximum values of an array, or the first and last values if 
% non-numeric. Value returned as a 2 element cell array. If there are
% mutliple variables, the property returns a struct with the fields of the
% VariableNames.

%% Row Metadata Properties
% *TableRowName*
% The name assigned to the variable dimension in the rows column can be
% specified as a character vector or string. This property maps to the
% first value of the DimensionNames cell array of the DataTable property.
% When loading metadata properties using a <matlab:doc('dsproperties') dsproperties> 
% object, the Row.Name field is assigned to TableRowName. Hence, 
% dst.TableRowNames is equivalent to
% dst.DataTable.Properties.DimensionNames{1}.
%
% *RowDescription* <br>
% Row description, specified as a cell array of character vectors or 
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
%
% *RowRange* (read only) <br>
% Set internally when RowNames are loaded or updated. Defines the minimum 
% and maximum values of an array, or the first and last values if 
% non-numeric. Value returned as a 2 element cell array. 


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
% *DimensionRange* (read only) <br>
% Set internally when Dimensions are loaded or updated. Defines the minimum 
% and maximum values of an array, or the first and last values if 
% non-numeric. Values returned as a 2 element cell array. If there are
% mutliple dimensions, the property returns a struct with the fields of the
% DimensionNames.

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
% These invoke the _table_ equivalents of addprop and rmprop - see
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
% *addvars* syntax is the same as <matlab:doc('addvars') addvars>. 

%%
%   dst2 = addvars(dst1, varargin)  
%%
% _addvars_ does NOT update metadata properties for the new variable. To do this
% interactively use setDSproperties(dst.DSproperties).
%%
% *removevars* syntax is the same as <matlab:doc('removevars') removevars>
%%
%   dst2 = removevars(dst1,'varNames')   
%%
% *movevars* syntax is the same as <matlab:doc('movevars') movevars>. varName is the
% variable to be moved, position is 'Before' or 'After' and location is
% the name of the reference variable to use for the move.
%%
%  dst2 =  movevars(dst1,'varName','position','location)            
%%
% *vertcat* vertically concatenates the two dstables, variable names
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
% *height* number of rows in the dstable
%%
%   H = height(dst);
%%
% *width* number of variables in the dstable.
%%
%   W = width(dst);
%%
% *plot* overloads plot to extract the RowNames and the values for varName
% and passes thes to plot with any additional input variables 
% accepted by <matlab:doc('plot') plot>. Returns the plot handle, h.
%%
%   h = plot(dst,'varName',varargin) 

%%
% The following functions are specific to a _dstable_.
%%
% *addrows* add rows to a table, using a vector of rownames that matches
% the existing RowNames data type. The values in the merged list must be
% unique. The variables must have a first dimension that matches the length
% of the rownames vector, with other dimensions matching the existing
% variables and listed in the same order as the existing variables. 
%
%   dst2 = addrows(dst1, rownames,var1,var2,.. varN); %where var1...varN should be in 
%                                                     %the order used in the dstable
%%
% When adding or removing rows the metadata properties of the _dstable_ 
% are unchanged.
%%
% *removerows* remove rows from all variables in a dstable and update RowRange
% rows2use can be  a numeric index or RowNames values. The latter can be
% in source data type format as used by a dstable, or a string array or cell array 
% as used by The RowNames property for a table.
%
%   dst2 = removerows(dst1,row2use);  
%%
% *sortrows* sort table into ascending order of RowNames
%
%   dst2 = sortrows(dst1);                %sort table into ascending order of RowNames 
%%
% *mergerows* combine two dstables that have RowNames that are datetimes in
% date order (e.g. when infilling a gap in a data set, dst1, with dst2).
%
%   dst3 = mergerows(dst1,dst2);          %dst2 is added to dst1
%%
% To _add_ or _remove_ dimensions use the following syntax
%
%   dst.Dimensions.Dim1 = dim1;           %add dimension Dim1 to dst
%   dst.Dimensions.Dim1 = [];             %remove dimension Dim1
%%
% where Dim1 is the dimensions name and dim1 is the vector of values that 
% define the dimension (must be ordered and same length as one of the
% variable dimensions).
%%
% Adding a dimension does NOT update metadata properties for the new dimension. 
% To do this interactively, use setDSproperties(dst.DSproperties).
%%
% *orderdims* order dimensions that have been assigned
%
%   dst = orderdims(dst,dimnames);        %re-order the dimensions to match dimnames (cell array)
%%  
% *dst2tsc* and *tsc2dst* convert between dstable and tscollection objects 
% (see <matlab:doc('dst2tsc') dst2tsc> and <matlab:doc('tsc2dst') tsc2dst> for further
% details).
%
%   tsc = dst2tsc(dst,idxtime,idxvars);   %converts a dstable object to a tscollection object
%   dst = tsc2dst(tsc,idxtime,idxvars);   %converts a tscollection to a dstable object
%%
% * idxtime - index vector for the subselection of time, or the row names
% as cell array of character vectors or datatime array
% * idxvars - index vector for the subselection of variables, or the variable
% names as a cell array of character vectors  
%%
% The call to dst2tsc can also use any of the syntax formats used by
% getDSTable (see below).
%%
% When creating tscollection the DSproperties of the dstable are passed and
% stored in tsc.TimeInfo.UserData. If a tscollection has DSproperties defined,
% these are restored when a dstable object is created from a tscollection object.
% 
%%
% The following functions can be used to get the attributes of a _dstable_
% variable, such as a list of the variable, row and dimension name or description, or the
% data range of a particular attribute
%%
% *getVarAttributes* find the name and description of a variable and the
% associated row/dimension attributes
%
%   [names,desc,label,idv] = getVarAttributes(dst,idv);
%%
% * idv -  index to variable, which can be character vector, string,
% numerical or logical
% * names - the names of the attributes assigned in the _ddstable_ in the
% order variable, row, dimensions
% * desc - the descriptions of the attribures in the same order
% * label - the labels assigned to each attribute in hte asme order
% * idv - numerical index of selected variable

%%
% *getVarAttRange* finds the range of the selected variable attribute
%
%   range = getVarAttRange(dst,list,selected);
%%
% * list - cell array of attribute descriptions to select from, or a
% numeric index value of the variable
% * selected - the character vector or string of the attibute to use
% * range - the start and end or min/max values of the selected attribute

%%
% *selectAttribute* propmpt user to select a dstable variable, or dimension
%
%   [name,idx] = selectAttribute(dst,option);
%%
% * option - 1 or 'Variable'; 2 or 'Row'; 3 or 'Dimension'
% * name - selected attribute name
% * idx - index of selected attribute

%% 
% *allfieldnames* returns a cell array of all field names in order Variable
% names, Row name, Dimension names
%
%   fields = allfieldnames(dst);

%%
% *getsampleusingtime* is simialr to the Matlab function for tscollections
% and extracts timeseries data between a start and end time from a dstable. 
% The rows of the dstable must be datetime. All variables in the dstable 
% are resampled.
%
%   newdst = getsampleusingtime(dst,startime,endtime);
%%
% * startime - specified as a datetime scalar
% * endtime - specified as a datetime scalar


%% dstable Indexing Methods
% Data held in a dstable can be accessed by rows, variables and/or
% dimensions.

%%
% *Using the _table_, T = dst.DataTable* <br>
% The syntax to extract rows and variables from the table is the same as 
% summarised in <matlab:doc('access-data-in-a-table') Access Data in a Table>.
%
% To access a subset of values using the dimension indices the syntax can
% be any of the following:

%%  
%   T = dst.DataTable      %extract table to use any of the following:
%   extracted_data = T{rows,vars}(:,idd1,idd2,..iddN);
%   extracted_data = T.varname(rows,idd1,idd2,..iddN);
%   extracted_data = T.(vars)(rows,idd1,idd2,..iddN);
%%
% where rows, vars, idd1,...iddN are indices for the Rows, Variables and 
% Dimensions, respecitvely. <br>
%%
% * vars can be specified as a character vector, colon, numeric indices, 
% or logical expression. varname is the variable name without quotation
% marks. 
% * idr and idd* can be colon, numeric indices, or logical expression. 
% * The number of dimensions indices included must match the number of
% dimensions of the table variable (excluding the row dimension).
%%
% The Dimension indices can also be input using idd = {idd1,idd2,...iddN)
% as follows:

%%
%   extracted_data = T.varname(rows,idd{:}); 
%%
% To delete rows and variables from a _table_ use the standard Matlab syntax
%%
%   T(rows,vars) = [];     %rows and vars to be deleted
%   T.(varname) = [];      %varname to be deleted
%   T(rows,:) = [];        %rows to be deleted for all variables

%%
% *Using indices with a _dstable_* <br>
% Using a _dstable_ the data can be retrieved based on Rows, Variables and 
% Dimensions, using one of three functions depending on the type of output required.

%%
%   newdst = getDSTable(dst,__);      %returns a dstable with the selected data and updated metadata      
%   newtable = getDataTable(dst,__);  %returns a table with the selected data  
%   newdataset = getData(dst,__);     %returns a cell array of the selected data

%%
%  When using indices the syntax requires indices for rows, variables and
%  dimensions in that order. Use [] to select the full range of values.

%%
%   newdst = getDSTable(dst,idr,idv);                   %selects variables defined by idr and idv
%   newdst = getDSTable(dst,idr,idv,idd1,idd2,..iddN);  %where the variables have N dimensions
%   newdst = getDSTable(dst,idr,idv,idd);               %where idd = {idd1,idd2,..iddN}

%%
% The same syntax can be used with getDataTable and getTable
%%
% *Using dimension values with a _dstable_* <br>
% Using a _dstable_ there is also the option to use the dimension values 
% (including rows) to access data in the table. The syntax is as follows:

%%
%   newdst = getDSTable(dst,'Name','Value');
%   newtable = getDataTable(dst,'Name','Value'); 
%   newdataset = getData(dst,'Name','Value');
%%
% where the 'Name', 'Value' pairs can be any of the following combinations:
%%
% * 'RowNames', rownames - where rownames is a subset of the rows to be used, specified in the
% format used for RowNames
% * 'VariableNames', varnames - where varnames is a subset of the variable names to be used, 
% specified as a cell array of character vectors, or a string array.  
% * 'Dimensions.dimName', dimnames - where dimnames is a subset of the dimension dimName to be
% used, specified in the format used for the dimension.                              

%% See Also
% <matlab:doc('dsproperties') dsproperties>, <matlab:doc('dscatalogue') dscatalogue>, 
% <matlab:doc('dstoolbox') dstoolbox>.







