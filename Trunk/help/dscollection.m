%% dscollection
% A dscollection object is a collection of one or more datasets held in an 
% array of _dstable_ tables. 
%
%% Syntax
%
%   dsc = dscollection(var1,...,varN)
%   dsc = dscollection('Size',sz,'Variabledscypes',varTypes)
%   dsc = dscollection(___,'VariableNames',varNames)
%   dsc = dscollection(___,'RowNames',rowNames)
%   dsc = dscollection
%
%%
% This syntax is the same as the <matlab:doc('table') table> syntax and
% is used in the same manner.


%% Description
% A dscollection holds a multiple dstable datasets
%%
%   dsc = ???
% 
% The additional properties used by dscollection are all assigned to the
% CustomProperties object that is a property of _table_. However, all
% properties can be set and accessed using the dscollection directly. For
% example:
%%
%   dsc.VariableNames
%   dsc.RowNames
%   dsc.Dimensions.<DimensionField>
%   etc
%
% Alternatively, the properties of the _table_ can be set and accessed 
% using the standard _table_ syntax such as:https://localhost:31515/static/help/matlab/matlab_prog/specifying-output-preferences-for-publishing.html#bthbe__-9
%% 
%   T.Properties.VariableNames
%   T.Properties.CustomProperties.<_PropertyName_>
% 

%% Input arguments
% These are the same as for <matlab:doc('table') table> with the exception
% of _rowNames_.
%%
% *rowNames* [edit HTML with <br> to add line break]
% Names of the rows in the output table, specified as a cell array of 
% character vectors, a string array, a datetime array, a duration array, or 
% a numeric vector. The number of names in rowNames must equal the number
% of rows for the variables being added. rowNames must define each row 
% using distinct, non-empty values.

%% Properties
% *Access Table Metadata Properties* <br>
% A dscollection contains metadata properties that describe the table, its
% variables and the 'dimensions' in the Row and Dimensions properties.