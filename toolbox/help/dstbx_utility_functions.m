%% dstoolbox utility functions
% Summary of the functions available in the _dstfunctions_ folder. Use the Matlab(TM)
% help function in the command window to get further details of each
% function.

%%
% * *cellstruct2cell.m*
% - convert a struct of cell arrays of the same dimension, to a cell array
% with fields as the rows and cell entries as the columns
% 
% * *cellstruct2structarray.m*
% - convert a struct of cell arrays of the same dimension to a struct array
% with a set of fields for each entry in the cell array
%
% * *compact3Darray.m*
% - remove the rows and columns that are zeros in all 2D matrices of a 2 or
% 3D array and return the compacted array.
% 
% * *copydata2clip.m*
% - copy data from the active figure or tab to the clipboard
%
% * *getcolumnwidths.m*
% - find the extent of text in each column (including the header), and the
% row text (if included)
% 
% * *getdatatype.m*
% - find the data type of 'var', checks for:
% logical, integer, float, char, string, categorical, datetime, duration, calendarDuration
% 
% * *getdialog.m*
% - generate a message dialogue box with no buttons. Calls setDialog.m^%
% 
% * *getfiles.m*
% - call uigetfile and return one or more files
%
% * *getprecision.m*
% - find the precision of a number that is a double
% 
% * *getvariabledimensions.m*
% - find total number of dimensions for a variable in a table or dstable
%
% * *isallround.m*
% - check whether vector of numbers or durations are are all round numbers
% but may or may not be integer data types
%
% * *islist.m*
% - test whether a variable is some form of text data. Input option allows 
% different combinations of character data types to be tested. If option is not included
% the function tests for cellstr, or string, or categorical, or char array
% 
% * *isunique.m*
% - check that all values in usevals are unique
% 
% * *mat2clip.m* 
% - Copies matrix to system clipboard. From Matlab(TM) Forum, jiro (2021),
% https://www.mathworks.com/matlabcentral/fileexchange/8559-mat2clip.
% 
% * *readinputfile.m*
% - read data from a file
% 
% * *setactionbutton.m*
% - add an action button with callback to graphical object
% 
% * *setdialog.m*
% - generate a dialogue with message and no buttons. Called by getDialog.m
% 
% * *sort_nat.m*
% - natural order sorting sorts strings containing digits in a way such that 
% the numerical value of the digits is taken into account. From Matlab(TM) Forum, 
% Douglas Schwarz (2021), https://www.mathworks.com/matlabcentral/fileexchange/10959-sort_nat-natural-order-sort.
%
% * *statictextbox.m*
% - create static text box with wrapped text to fit the number of lines
% if greater that nlines make box scrollable
% 
% * *str2var.m*
% - Convert the input cell array of character vectors to an array of the 
% specified data type and using the given format if datetime or duration
% 
% * *tablefigure.m*
% - generate plot figure to show table with a button to copy to clipboard
% 
% * *tabtablefigure.m*
% - generate figure with tabs to show set of tables 
%
% * *var2str.m*
% - convert the input variable to a cell array of strings and return the 
% data type and format (for datetime and duration only) 






