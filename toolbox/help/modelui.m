%% ModelUI
% ModelUI is a generic interface for bespoke models and data analysis tools.

%% Licence
% The code is provided as Open Source code (issued under a BSD 3-clause License).

%% Requirements
% ModelUI is written in Matlab(TM) and requires v2016b, or later. In addition, 
% ModelUI requires both the <matlab:doc('dstoolbox') dstoolbox> and the 
% <matlab:doc('muitoolbox') muitoolbox>

%% Background
% ModelUI provides a generic interface for modelling applications that produce 
% some combination of graphical and/or time series outputs. The purpose of this 
% user interface (UI) is to enable the rapid prototyping of models by allowing 
% the model developer to focus on the model, rather than the functional or operational 
% needs of the software package itself.  To this end, the UI provides a standard 
% interface with drop-down menus, tools to open and close files, keep track of model 
% runs, provide a rapid means to implement model set-up and data import and export, 
% derivation of new variables, and some basic plotting and statistical tools. 

%%
% <<schematic.png>>

%% ModelUI classes
% *ModelUI* - defines the behaviour of the main UI.

%% Demonstration model classes
% * *VPdata* - import vertical profile velocity data.
% * *VPmodel* - compute the vertical velocity profile at a point.
% * *VPparam* - load the input parameters needed to run the model.

%% Manual
% The <matlab:mmui_open_manual manual> provides further details of setup and 
% configuration of the model. The files for the example use case can be found in
% the example folder <matlab:mmui_example_folder here>. 

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('dstoolbox') dstoolbox>. 