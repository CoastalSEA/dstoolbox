%% dstoolbox
% dstoolbox is a collection of classes used to store and manage access to
% multi-dimensional data sets. These include: <br>
% <matlab:doc('dstable') dstable>, holds a collection of one or more datasets 
% with one or more common dimension vectors.  <br>
% <matlab:doc('dsproperties') dsproperties>, defines the object used to 
% assign metadata to a _dstable_. <br>
% <matlab:doc('dscatalogue') dscatalogue>, manages a catalogue of data sets <br>
% that handle all types of data set (eg imported or model data) which are 
% loaded into dstables and catalogued using _dscatalgue_. <br>

%% Schematic
% These classes can be used together as illustrated in the following figure:

%%
% <<dstoolbox_model.png>>
%
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