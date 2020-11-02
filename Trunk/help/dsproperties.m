%% dsproperties
% dsproperties defines the struct used to assign the metadata to a
% _dstable_. A valid struct can be used to initialise dsproperties, or the 
% Row, Variables and Dimensions properties can be defined interactively. 
%
%% Syntax
%%
%   dsp = dsproperties;            %creates an empty object
%   dsp = dsproperties(dsprops);   %assigns dsprops to dsp.DSproperties
%   dsp = dsproperties('set');     %invokes UI to set values interactively
%

%% Description
% The _dstable_ class provides for more extensive metadata for each
% variable and the dimensions of the variables. dsproperties can be used to
% setup a valid struct that can be used to populate the metadata in a
% _dstable_.
%
%% Input arguments
% *dsprops* can be a valid dsproperties struct, or the keyword 'set'. The
% keyword 'set' is the same as using setDSproperties(dsp) and calls a UI
% to allow the propery values to be set or edited interactively.
%

%% Properties
% *DSPdescription* <br>
% The DSPdescription property is used to provide a desecription of the dsproperties object <br> 
%
% *Variables* <br>
% A struct array of the properties for each variable including the
% following fields: <br>
% Name  - names used in dstable, tscollection and table to label variables <br>
% Description - description of variables (used in data access UIs to provide 
% a fuller description of the variables) <br>
% Unit  - variable units <br>
% Label - axis labels for results <br> 
% QCflag - flag to indicate any quality control of data  <br>
%
% *Row* <br>
% Name - name for datatype used in table rows Assigned to the Property TableRowName
% in a <matlab:doc('dstable') dstable> and as the first value of the 
% DimensionNames property in a <matlab:doc('table') table> <br>
% Description - description for RowNames in table (usually Time but
% rows can be any unique descriptor) <br>        
% Unit   - units of row data  <br>
% Label  - axis labels for use with row data <br>
% Format - time format to use when saving time data. Formats can be durations
% (e.g. y,d,m,s),or datetime (e.g. dd-MMM-uuuu HH:mm:ss) <br>
%
% *Dimensions* <br>
% Name - stuct name used for dimensions.<br>
% Description - description to be used for co-ordinates <br>
% Unit  - units for the defined co-ordinates <br>
% Label - axis labels for use with XYZ data <br>
% Format - data format to use when saving the dimension <br>
%
% The _Labels_ field can be used to define generic summaries of variables, 
% such as when plotting different variables of the same type but labelling 
% the axis with a common label. For example: variables: Vel1, Vel2, Vel2 
% all labelled 'Velocity (m/s)'. 

%% Assign and access Properties
% Properties can be assigned and accessed using dot indexing for the
% property and array indexing for the element in the struct array. In
% addition the keyword 'set; can be used to invoke the UI to assign or edit
% values of any of the properties. For example:

%%
%   dsp.Variables = 'set';     %calls UI to set or edit the Variables property
%   dsp.Row = [];              %clears the struct array element
%   dsp.Dimensions = [];       %clears all dimension properties
%   dsp.Dimensions(idx) = [];  %clears only the idx dimensions in the struct array

%% dsproperties input formats
% Two fprmats can be used to load a dsproperties object from a a struct.
% Both use a struct with fields Variables, Row, and Dimensions. The second
% level struct can then be a struct array of the fields, or a cell array 
% for each field, as illustrated by the following two examples. <br>
% 
% *dsproperties struct array* <br>
% Populate the DSproperties stuct as a struct array. 
% Uses cell arrays of row or column vectors (but not string arrays).
% The file |dsprop_struct_template.m| provides a copy of the following format

%%
    dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
    dsp.Variables = struct(...   %cell arrays can be column or row vectors
        'Name',{'Var1','Var2','Var3'},...
        'Description',{'Variable 1','Variable 2','Variable 3'},...
        'Unit',{'u1','u2','u3'},...
        'Label',{'Label1','Label2','Label3'},...
        'QCflag',{'qc1','qc2','qc3'}); 
    dsp.Row = struct(...
        'Name',{'Time'},...
        'Description',{'Row Description'},...
        'Unit',{'time'},...
        'Label',{'s'},...
        'Format',{'dd-MM-yyyy'}); %only used for datetime and duration formats           
    dsp.Dimensions = struct(...    
        'Name',{'Dim1';'Dim2'},...
        'Description',{'Distance 1';'Distance 2'},...
        'Unit',{'u1';'u2'},...
        'Label',{'Label1';'Label2'},...
        'Format',{'-';'-'});      %only used for datetime and duration formats
%%
% *dsproperties struct of cell arrays* <br>
% Populate the DSproperties stuct as a struct of cell arrays. 
% Uses cell arrays of row or column vectors, or string arrays.
%%
    dsp = struct('Variables',[],'Row',[],'Dimensions',[]);
    dsp.Variables.Name = {'Var1','Var2','Var3'}; %cell arrays can be column or row vectors
    dsp.Variables.Description = {'Variable 1','Variable 2','Variable 3'};
    dsp.Variables.Unit = ["u1","u2","u3"];       %string array
    dsp.Variables.Label = {'Label1','Label2','Label3'};
    dsp.Variables.QCflag = {'qc1','qc2','qc3'};
    dsp.Row.Name = 'Time';
    dsp.Row.Description = 'Row Description';
    dsp.Row.Unit = 'time';
    dsp.Row.Label = 's';
    dsp.Row.Format = 'dd-MM-yyyy';       %only used for datetime and duration formats
    dsp.Dimensions.Name = {'Dim1';'Dim2'};
    dsp.Dimensions.Description = {'Distance 1';'Distance 2'};
    dsp.Dimensions.Unit = {'u1';'u2'};
    dsp.Dimensions.Label = {'Label1','Label2'};
    dsp.Dimensions.Format = {'-';'-'};   %only used for datetime and duration formats

%% dsproperties methods
% *addVariables* add additional stuct array elements to the Variables property.
% Input can be just the name of the variable, a cell array of variable 
% names, or a stuct of variable fields.
%%
%   addVariables(dsp,{'varNames'});   %add 'varNames' to the dsproperties object, dsp 
%   addVariables(dsp,varStruct);      %add 'varStruct' to the dsproperties object, dsp
%%
% *rmVariables* remove variables from the struct array of a dsproperties
% object. Input values for 'varNames' can be a character vector, cell array 
% of character vectors, string array, numeric array, or logical array of the 
% variable to be removed. 
%%
%   rmVariables(dsp,{'varNames'});    %remove 'varNames' from the dsproperties object, dsp 
%%
% *moveVariables* move the position of a variable in the dsproperties stuct array
% Inputs for varName and location can be a character vector,string scalar, 
% integer, or logical array, and position is 'Before' or 'After'.
%%
%   moveVariable(dsp,varName,position,location)
%%
% *addDimensions* add additional stuct array elements to the Dimensions property. 
% Input can be just the name of the variable, a cell array of variable
% names, or a stuct of variable fields.
%%
%   addDimensions(dsp,{'dimNames'});  %add 'dimNames' to the dsproperties object, dsp
%   addDimensions(dsp,dimStruct);     %add 'dimStruct' to the dsproperties object, dsp
%%
% *rmDimensions* remove dimensions from the struct array of a dsproperties
% object. Input values for 'dimNames' can be a character vector, cell array 
% of character vectors, string array, numeric array, or logical array of the 
% variable to be removed.
%%
%   rmDimensions(dsp,{'dimNames'});   %remove 'dimNames' from the dsproperties object, dsp 
%%
% *moveDimensions* move the position of a variable in the dsproperties stuct array
% Inputs for varName and location can be a character vector,string scalar, 
% integer, or logical array, and position is 'Before' or 'After'.
%%
%   moveDimension(dsp,varName,position,location)
%%
% *setDSproperties* calls the UI to add the definition for Row, Variables
% and Dimensions. Provides the option to add Variables and Dimensions
% interactively.
%%
%   dsp = dsproperties;               %empty dsproperties object
%   setDSproperties(dsp);             %edit existing dsproperties object, dsp.
%   setDSproperties(dsp,dsp_struct);  %load a dsproperties struct array into a dsproperties object
%   setDSproperties(aa,[],'dspDesc'); %interactively define properties and add dspDesc as the DSPdescription

%% 
% *displayDSproperrties* displays the current property setting on a figure
% with tabs for Variables, Row and Dimensions. Settings can be copied to
% the clipboard.
%%
%   displayDSproperties(dsp);         %display current definitions
 

%% See Also
% <matlab:doc('dstable') dstable>, <matlab:doc('dscatalogue') dscatalogue>, 
% <matlab:doc('dscollection') dscollection>,
% <matlab:doc('dstoolbox') dstoolbox>.