%% dstoolbox examples
% The construct illustrated in the introduction of the <matlab:doc('dstoolbox') dstoolbox>
% is illustrated using the calling function dstb_usage.m and the
% demoData and demoModel classes <br>
% Usage of the individual classes is provided in the test_dstoolbox
% function. The files for the example use cases can be found in
% the example folder <matlab:ds_example_folder here>. 
%%
%   dm = dstb_usage;    %initialise class that manages calls to models and data classes
%   run_a_model(dm);    %run model and save record to catalogue
%   load_data(dm);      %load data from text file and save record to catalogue
%   plotCase(dm);       %plot some results for a selected Case
%   displayProps(dm);   %display DSproperties for a selected Case
%

%% dstb_usage class
% A class to illustrate the combined use of data and model classes that use 
% dstable and dsproperties, with a record for each data set held in
% dscatalouge. An option to run dstb_usage is included in test_dstoolbox

%% ds_demoData class
% A class to load data from a file and store it in a <matlab:doc('dstable') dstable>. 
% The class includes methods to define the dsproperties, read the 
% input file format, load the data into a _dstable_ and plot some output.

%% ds_demoModel class
% A class to run a simple model (2D diffusion using hard code parameter settings)
% The class includes methods to run the model, save the results, and plot
% the model output

%% test_dstoolbox function
% The test_dstoolbox function can be used to experiment with the different
% options available for the <matlab:doc('dstable') dstable>, 
% <matlab:doc('dsproperties') dsproperties> and 
% <matlab:doc('dscatalogue') dscatalogue>. The comments included in the
% code explain each function call.
%%
% *Examples of usage*
%%
%   test_dstoolbox(classname,casenum,options)
%%
% _classname_ is one of the toolbox classes 'dscatalogue', 'dsproperties',
% 'dstable' <br>
% _casenum_ is the example test case (see below) <br>
% _options_ define the input selection for some of the cases (see below)

%% 
% *dscatalogue* <br>
% _casenum_ and _options_ input arguments not used <br>
% Initialises the class object, add and remove some records, prompt to edit
% case descriptions, select records to be deleted. Results are displayed in 
% the Command Window.

%%
% *dsproperties* <br>
% _options_ input arguments not used <br>
% _casenum_ defines the test cases below: <br>
% Case 1 - create and display blank dsproperties. <br>
% Case 2 - set properties and display.  <br>
% Case 3 - call and set properties individually using UI.  <br>
% Case 4 - create using a struct and delete contents.  <br>
% Case 5 - alternative syntax to set all using UI.  <br>
% Case 6 - assign a struct array.  <br>
% Case 7 - assign a struct of cell arrays.  <br>
% Case 8 - set and test loading incomplete struct (fails).  <br>
% Case 9 - removal of variables and dimensions.  <br>
% Case 10 - addition of variables and dimensions. <br>
% Case 11 - change order of variables and dimensions <br>
% Case 12 - input of struct with empty fields

%%
% *dstable* <br>
% _casenum_ defines the test cases below: <br>
% Case 1 - initialise a blank dstable. option not used <br>
% Case 2 - create a simple table with no dimensions. options is a single scalar value <br>
% Case 3 - create table with 2d+t array. options are a [1x3] vector <br>
% Case 4 - update the values in the variable. options are a [1x3] vector <br>
% Case 5 - horzcat and vertcat - simple table with no dimensions. options are a single scalar value <br>
% Case 6 - horzcat and vertcat - multiple variables with dimensions. options are a [1x3] vector <br>
% Case 7 - add variable rownames, dimensions and metadata in one call. options are a [1x3] vector <br>
% Case 8 - access data using dimensions. options are a [1x3] vector <br>
% Case 9 - convert dstable to tscollection and back. options are a [1x3] vector

%%
% _options_ define the data type used to generate row and dimension data. A 
% single value defines the row dimension and a [1x3] vector defines 
% [row,dim1,dim2] data types. The data types are numbered as follows: <br>
% 1 - datetime <br>
% 2 - duration <br>
% 3 - char <br>
% 4 - string <br>
% 5 - numeric
%%
% *dstb_usage* <br>
% _casenum_ and _options_ input arguments not used <br>
% Runs the model and loads data twice to create a catalogue of four data
% sets, then calls plot and display functions for selected cases.

%% See Also
% <matlab:doc('dstable') dstable>, <matlab:doc('dscatalogue') dscatalogue>, 
% <matlab:doc('dsproperties') dsproperties>, <matlab:doc('dstoolbox') dstoolbox>.
