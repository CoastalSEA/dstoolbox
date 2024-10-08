%% dstoolbox
% dstoolbox is a collection of classes used to store and manage access to
% multi-dimensional data sets. 

%% Licence
% The code is provided as Open Source code (issued under a BSD 3-clause License).

%% Requirements
% dstoolbox is written in Matlab(TM) and requires v2016b, or later. The 
% toolbox is designed as an alternative to a Matlab(TM) _table_ but is also
% an integral component of the <matlab:doc('muitoolbox') muitoolbox>.

%% dstoolbox classes
% The classes in the toolbox include:
%%
% * <matlab:doc('dstable') dstable>, holds a collection of one or more datasets 
% with one or more common dimension vectors and the associated metadata.
% * <matlab:doc('dsproperties') dsproperties>, defines the object used to 
% assign metadata to a _dstable_.
% * <matlab:doc('dscatalogue') dscatalogue>, manages a catalogue of data sets
% that handle a collection of data sets (e.g. imported and model data), which are 
% loaded into _dstables_ and catalogued using _dscatalogue_.

%%
% _Note: links to dstoolbox classes, in the text, display the class 'help'. 
% Use the links on the dstoolbox sidebar menu to access the class
% documentation._

%% Schematic
% These classes can be used together as illustrated in the following figure:

%%
% <<dstoolbox_model.png>>

%% Usage
% The toolbox is designed to store and manage multi-dimensional data sets, including 
% meta-data of the variables and all dimensions and manage access to a 
% collection of classes that hold data sets using a catalogue. In the
% schematic outline _dstb_usage_ is a class to illustrate how _dstable_,
% _dsproperties_ and _dscatalgue_ are used. Data are loaded into a _dstable_
% with relevant metadata added to the table and made accessibile using
% _dsproperties_. Each time a class adds data a record is added using
% _dscatalogue_. The 'Format Spec'  user functions, shown in the upper part of
% the figure, are implemented with functions, indicated
% by 'File Type' and 'Output Type', shown in the lower part of the figure. 
% These define the meta-data of the data set 
% being saved (and any input parameters, or details needed to read and load 
% data from a file, depending on the application).

%% See Also
% Some slides providing an introduction to the use of the dstoolbox can be found
% <matlab:dst_open_manual here>. In addition, the dstoolbox is used in 
% the <matlab:doc('muitoolbox') muitoolbox> and the use of both
% toolboxes is illustrated in the <matlab:doc('modelui') ModelUI> App.