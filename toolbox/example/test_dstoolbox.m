function h = test_dstoolbox(classname,casenum,option)
%
%-------function help------------------------------------------------------
% NAME
%   test_dstoolbox.m
% PURPOSE
%   functions to test ds components of the dstoolbox
% USAGE
%   test_dstoolbox('funcname',casenum,option);
%       e.g. test_dstoolbox('dscatalogue');  %class to manage catalogue of cases held
%       e.g. test_dstoolbox('dsproperties,6,[1,3,5]');  %class to manage the meta-data properties
%            test_dstoolbox('dstable',6,[1,3,5]);  %class for a ollection of one or more datasets
%            h = test_dstoolbox('dstb_usage');  %class to demonstrate use of dstoolbox
% INPUT
%   classsname - name of dstoolbox class function to be tested
%   casenum - number of case to run
%   option  - selects format for dimension when calling set_dimension in
%             dstable - single value or vector depending on case:
%             for vector v(1)=row type, v(2)=dim1 type, v(3)=dim2 type
%             1  datetime; 2  duration; 3  char; 4  string; 5  numeric;
%             6  categorical; 7  ordinal; 8  test duplicate dimensions           
% OUTPUT
%   See in-code comments for details of test and in-code outputs.
%   h - first dstable created (t1) when classname=dstable, or
%   h - handle to dstb_usage, a class to demonstrate use of dstoolbox 
%       classes
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    h = [];
    if nargin<2
        casenum = 0; option = [];
    elseif nargin<3
        option = [];
%     elseif option>5
%         warndlg('''option'' should be from 1-5')
%         return;
    end

    switch classname
        case 'dscatalogue'  %Class to manage catalogue of cases held
            test_dscatalogue;
        case 'dsproperties' %Class to manage the meta-data properties
            test_dsproperties(casenum,option);
        case 'dstable'       %collection of one or more datasets with one 
                             %or more common dimension vectors
            h = test_dstable(casenum,option);
        case 'dscollection'
            %interface needs to be implemented by a class
        case 'dstb_usage'    %class to demonstrate use of dstoolbox
            h = test_dstb_usage;
    end
end
%%
%--------------------------------------------------------------------------
%   Tests for dscatalogue
%--------------------------------------------------------------------------
function test_dscatalogue()
    %test set, get edit and delete functions
    dsCat = dscatalogue;
    
    fprintf('Loading dscatalogue with records\n')
    %daaCase returns the record number in the Catalogue property of dscatalogue
    recnum1 = addRecord(dsCat,'TestClass','model');  
    recnum2 = addRecord(dsCat,'TestClass','model');
    recnum3 = addRecord(dsCat,'DifferentClass','data');
    recnum4 = addRecord(dsCat,'DifferentClass','data');
    recnum5 = addRecord(dsCat,'DifferentClass','data');
    
    %access selected cases
    casedef = getRecord(dsCat,recnum2);
    fprintf('Display definition for case no.2\n')
    display(casedef)
    fprintf('Display definition for case no.4 using caseid\n')
    casedef = getRecord(dsCat,dsCat.caseRec(4));
    display(casedef)
    
    %edit the description of a case
    [caserec,newdesc] = editRecord(dsCat,recnum3);
    fprintf('Edited Record %g: to read: %s\n',caserec,newdesc{1})
    
    %select from the TestClass subset
    [caserec,~] = selectRecord(dsCat,'PromptText','Select case:',...
                     'CaseClass',{'TestClass'},'ListSize',[250,200]);
    fprintf('Selected TestCLass record %g\n',caserec)
    
    removeRecord(dsCat,[2,4]);
    removeRecord(dsCat);  %prompts to select from list    
    fprintf('Display catalogue table after deleting records\n')
    display(dsCat.Catalogue)
end
%%
%--------------------------------------------------------------------------
%   Tests for dsproperties
%--------------------------------------------------------------------------
function test_dsproperties(testnum,option)
    %test set, edit, delete and display options
    switch testnum
        case 0
            warndlg('Specify a case and option to use');
        case 1  %Set individual assignment
            aa = dsproperties;              %create blank dsproperties  
            displayDSproperties(aa);
            
        case 2  %set all properties
            aa = dsproperties('set');       %create and set dsproperties
            displayDSproperties(aa);        %display current definition
            
        case 3  %call and set properties individually
            aa = dsproperties;
            aa.Variables = 'set';           %ui to set Variables
            aa.Dimensions = 'set';          %ui to set Dimensions
            aa.Row = 'set';                 %ui to set Row
            aa.DSPdescription = 'set';      %ui to set DSPdescription
            displayDSproperties(aa);        %display current definition
            
        case 4  %create using a struct and delete contents
            dsp = dsp_struct(option);       %predefined struct array
            aa = dsproperties(dsp);         %alternative call to initialise        
            displayDSproperties(aa);        %display current definition
            aa.Variables(2) = [];           %clear a Variable (Var2)
            aa.Dimensions = [];             %clear all Dimensions
            aa.Row = [];                    %clear Row
            aa.DSPdescription = [];         %clear DSPdescription
            displayDSproperties(aa);        %display current definition
            
        case 5  %alternative syntax to set all
            aa = dsproperties;              %create blank dsproperties
            setDSproperties(aa,[],'test desc') %set all the class properties
            displayDSproperties(aa);        %display current definition
            
        case 6  %assign a struct array
            aa = dsproperties;              %create blank dsproperties
            dsp = dsp_struct(option);       %predefined struct array
            setDSproperties(aa,dsp);        %load a dsp struct directly
            setDSproperties(aa);            %call ui to edit
            displayDSproperties(aa);        %display current definition
            
        case 7  %assign a struct of cell arrays
            aa = dsproperties;              %create blank dsproperties
            setDSproperties(aa,dsp_cellstruct); %load a dsp struct directly
            setDSproperties(aa);            %call ui to edit
            displayDSproperties(aa);        %display current definition
            
        case 8  %set and manipulate using option 2
            dsp = dsp_struct(option);       %predefined struct array
            bb = dsproperties(dsp);         %alternative call to initialise
            bb_str = bb.Variables;          %assign DSproperties struct
            bad_str = rmfield(bb_str,'Label');%remove a row field from struct
            bb.Variables = bad_str;         %assign incomplete struct (fails)
            bb.Variables = bb_str;          %assign existing struct
            displayDSproperties(bb);        %display current definition
            
        case 9  %test removal of variables and dimensions
            %varnames/dimnames can be character vector, cell array of 
            %character vectors, string array, numeric array, logical array
            cc = dsproperties(dsp_cellstruct);%initialise with cell struct
            varnames = {'Var2','Var3'};
            rmVariables(cc,varnames);       %remove variables
            dimnames = 'Dim1';
            rmDimensions(cc,dimnames);      %remove dimension
            displayDSproperties(cc);        %display current definition
            
        case 10  %test addition of variables and dimensions
            %varprops/dimprops can be a Variables struct, cell array, 
            %or just the name of the variable to be added
            dd = dsproperties(dsp_cellstruct);%initialise with cell struct
            varprops = 'var4';
            addVariables(dd,varprops);      %sets a property (no prompt)
            editDSproperty(dd,'Variables')  %edit current set of Variables
            dimprops = struct(...
                'Name',{'Dim3';'Dim4'},...
                'Description',{'Distance 3';'Distance 4'},...
                'Unit',{'m';'m'},...
                'Label',{'Distance';'Distance'},...
                'Format',{'na';'na'});
            addDimensions(dd,dimprops)
            displayDSproperties(dd);        %display current definition
            %add a variable with the field values defined as a cell array
            [ee,~] = addDSproperties(dd,'Variables',...
                {'Var5','Variable 5','units','Variable 5 label','raw'});
            rmDimensions(ee,{'Dim2','Dim3','Dim4'});
            dimprop5 = struct(...
                'Name',{'Dim5'},...
                'Description',{'Distance 5'},...
                'Unit',{'m'},...
                'Label',{'Distance'},...
                'Format',{'-'});
            %add a dimension with the field values defined as a struct
            [ee,ok] = addDSproperties(ee,'Dimensions',dimprop5);
            if ok==1
                displayDSproperties(ee);        %display current definition
            end
            
        case 11  %test change order of variables and dimensions
            %varname is character vector,string scalar,integer,logical array
            %position is 'Before' or 'After'
            %location is character vector,string scalar,integer,logical array
            dsp = dsp_struct(option);       %predefined struct array
            ee = dsproperties(dsp);         %initialise with struct array
            varname = 'Var3';
            location = "Var2";
            moveVariable(ee,varname,'Before',location)
            moveDimension(ee,1,'After',[false,true])
            displayDSproperties(ee);        %display current definition
            
        case 12  %test input of struct with empty fields
            ff = dsproperties(dsp_partialstruct,'test');%create partial struct with blanks
            displayDSproperties(ff);        %display current definition

        case 13  %test adding default values to the Variable dsproperty
            aa = dsproperties;              %create blank dsproperties
            aa.Variables.Name = 'Var1';
            varprops = {'Var2','Var3'};
            addVariables(aa,varprops); 
            vardef = getDSpropsStruct(aa,2);
            vardef.Variables.Unit = 'm';
            vardef.Variables.QCflag = 'none';
            setDefaultDSproperties(aa,'Variables',vardef.Variables)     
            displayDSproperties(aa);        %display current definition

        case 14  %test 
            aa = dsproperties;              %create blank dsproperties
            aa.Variables.Name = 'Var1';
            aa.Dimensions.Name = 'Dim1';
            dspdef = getDSpropsStruct(aa,2);
            dspdef.Row.Description = 'Location';
            dspdef.Dimensions.Label = 'Distance from mouth';
            setDefaultDSproperties(aa,'Row',dspdef.Row,'Dimensions',dspdef.Dimensions)  
            displayDSproperties(aa);        %display current definition
    end
end
%%
%--------------------------------------------------------------------------
%   Tests for dstable
%--------------------------------------------------------------------------
function t1 = test_dstable(testnum,option)
    %test initialisation, setting, accessing, editing and deleting dstable
    switch testnum
        case 0
            warndlg('Specify a case and option to use');
        case 1  %initialise a blank dstable
            t1 = dstable      %#ok<NOPRT>
            
        case 2  %create a simple table with rows but no dimensions
            nrows = 5;
            varnames = {'Var1'};
            data = set_variable(nrows);
            rownames = set_dimension(option(1),nrows);
            t1 = dstable(data,'RowNames',rownames,'VariableNames',varnames);
            t1.DataTable
            t1.DSproperties = dsp_partialstruct; %variable names in DSproperties struct
            displayDSproperties(t1.DSproperties);        %display current definition
            
        case 3  %create table with 2d+t array. option is 1x3 vector to 
                %define the data type for row and dimensions
            t1 = dummytable(option);    
            displayDSproperties(t1.DSproperties);        %display current definition
            outscript('Row: %s to %s\n',t1.RowRange{1},t1.RowRange{2});
            outscript('Dim1: %s to %s\n',t1.DimensionRange.Dim1{1},t1.DimensionRange.Dim1{2});
            outscript('Dim2: %s to %s\n',t1.DimensionRange.Dim2{1},t1.DimensionRange.Dim2{2});
            outscript('Var: %s to %s\n',t1.VariableRange.Var1{1},t1.VariableRange.Var1{2});    

        case 4  %update the values in the variable
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct(option); %assign DSproperties struct
            outscript('Var: %s to %s\n',t1.VariableRange.Var1{1},t1.VariableRange.Var1{2})
            t1.Var1 = t1.Var1*2;
            outscript('2xVar: %s to %s\n',t1.VariableRange.Var1{1},t1.VariableRange.Var1{2})
            %now test manipulation of dstable                       
            tv2 = t1.Var2;      %extract values for Var2
            t2 = removevars(t1,'Var2');        %create new dst and remove Var2
            t1.Var2 = [];                      %remove Var2 from original table
            t3 = addvars(t2,tv2,'Before','Var3');   %restore Var2
            t3.DSproperties = setDSproperties(t3.DSproperties); %interactively define dsproperties
            displayDSproperties(t3.DSproperties);
            t4 = movevars(t3,'Var2','After','Var3');%move Var2 after Var3
            t4.VariableRange
            dsp = t4.DSproperties;             %get the current table properties
            dsp.Variables(3).QCflag = 'raw';   %update specific properties
            dsp.Variables(3).Description = 'A moved variable';
            t4.DSproperties = dsp;             %assign updated properties to table
            displayDSproperties(t4.DSproperties);
            t4 = movevars(t4,'Var3','After','Var2'); %move variable and assigned properties
            displayDSproperties(t4.DSproperties);
            t4.VariableRange
            
        case 5 %add and delete rows and dimensions
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct(option); %assign DSproperties struct
            t1.Dimensions.Dim1 = [];              %delete first dimenion
            t1.RowRange
            t1.DimensionRange
            ndim1 = 3; ndim2 = 7; 
            dim1 =  set_dimension(option(2),ndim1);
            t1.Dimensions.Dim1 = dim1;            %reassign first dimension
            %now reorder dimension fields
            t1 = orderdims(t1,{'Dim1','Dim2'});
            t1.DimensionRange
            %rows can be added by vertical concatenation of two dstables, 
            %which sorts the dstable into ascending order. Alterantively,
            %rows can be added using the rownames and variables to be added
            %(the number of variables must match the number in the table)
            t1.RowRange
            t1.VariableRange
            nrows = 3;
            rowdims = set_dimension(option(1),nrows,height(t1));
            var1 = set_variable(nrows,ndim1,ndim2);
            var2 = set_variable(nrows,ndim1,ndim2);
            var3 = set_variable(nrows,ndim1,ndim2);
            t1 = addrows(t1,rowdims,var1,var2,var3); %add an array of rows
            t1.RowNames
            t1.RowRange
            t1.VariableRange
            t1 = removerows(t1,rowdims);             %restore original
            %t1 = removerows(t1,cellstr(rowdims));   %syntax using table RowNames data type
            %t1 = removerows(t1,6:8);                %syntax using indices
            t1.RowRange
            t1.VariableRange
            
        case 6 %test horzcat and vertcat - simple table with no dimensions
            nrows = 5;
            varnames = {'Var1'};
            data = set_variable(nrows);               %generate dataset
            rownames1 = set_dimension(option(1),nrows);  %generate row dimension
            t1 = dstable(data,'RowNames',rownames1,'VariableNames',varnames); %create table with same variable name
            rownames2 = set_dimension(option(1),nrows,nrows);%generate row dimensions with offset to ensure unique
            t2 = dstable(data,'RowNames',rownames2,'VariableNames',{'Var1'}); %create table
            t3 = vertcat(t2,t1);                      %vertical concatenation of the two tables
            t3.DataTable                              %display
            t3 = sortrows(t3);
            t3.DataTable                              %display
            displayDSproperties(t3.DSproperties);
            clear t2 t3
            t2 = dstable(data,'RowNames',rownames1,'VariableNames',{'Var2'}); %create table with different variable name
            t1.VariableDescriptions = {'var1'};       %add descriptions to the variables
            t2.VariableDescriptions = {'var2'};
            t3 = horzcat(t2,t1);                      %horizontal concatenation of the two tables    
            t3.DataTable                              %display
            displayDSproperties(t3.DSproperties);
            
        case 7 %test horzcat and vertcat - multiple variables with dimensions
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct(option); %assign DSproperties struct
            t2 = copy(t1);  %make copy of dstable including all dynamic properties
            t2.VariableNames = {'vv1','vv2','vv3'};   %change the variable names
            t2.VariableDescriptions = {'varv1','varv2','varv3'};
            t3 = horzcat(t2,t1);                      %horizontal concatenation of the two tables    
            displayDSproperties(t3.DSproperties);
            t3.RowRange
            t3.VariableRange
            t4 = dummytable(option);                  %table with different row values
            rowdims = set_dimension(option(1),height(t4),height(t4));
            t4.RowNames = rowdims;
            %change variable order to test vertical concatenation sort
            movevars(t4,'Var2','After','Var3');       %move Var2 after Var3
            t5 = vertcat(t1,t4);                      %vertical concatenation of the two tables
            displayDSproperties(t5.DSproperties);     %display
            t5.RowRange
            t5.VariableRange
            t5.DimensionRange
            
        case 8 %test add variable rownames, dimensions and metadata in one call
            nrows = 5; ndim1 = 3; ndim2 = 7;
            data1 = set_variable(nrows,ndim1,ndim2);
            data2 = set_variable(nrows,ndim1,ndim2);
            data3 = set_variable(nrows,ndim1,ndim2);
            rowdims = set_dimension(option(1),nrows);
            %dsp = dsp_struct;                        %DSproperies struct
            dsp = dsproperties(dsp_struct(option));   %dsproperies object (prompts for name)
            t1 = dstable(data1,data2,data3,'RowNames',rowdims,'DSproperties',dsp);           
            t1.DataTable                              %display
            displayDSproperties(t1.DSproperties);     
            
        case 9 %access dstable using getDataTable and getDStable with dimensions
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct(option);     %assign DSproperties struct
            dim1 = t1.Dimensions.Dim1;
            dim2 = t1.Dimensions.Dim2;
            dim3 = t1.RowNames;
            subrow = dim3(2:3);
            %setup sub-selection vectors
            subvar = {'Var2','Var3'};
            subdimx = dim1(2:3);
            subdimy = dim2(2:2:6);
            %use sub-selections to retrieve table and dstable
            datatable = getDataTable(t1,'RowNames',subrow,'VariableNames',subvar,...
                       'Dimensions.Dim2',subdimy); 
            newdst = getDSTable(t1,'RowNames',subrow,'VariableNames',subvar,...
                       'Dimensions.Dim1',subdimx,'Dimensions.Dim2',subdimy);  
            %dispaly dsproperties and print ranges to command window       
            displayDSproperties(newdst.DSproperties);
            newdst.RowRange
            newdst.VariableRange
            newdst.DimensionRange
  
        case 10 %convert dstable to tscollection and back
            t1 = tstable();                           %dstable of timeseries data
            t1.DSproperties = dsp_struct(option);     %assign properties to dstable
            tsc1 = dst2tsc(t1);                       %convert to full table to tscollection
            figure; plot(tsc1.Var2);
            %syntax dst2tsc(obj, times or time_index, variables or variable_index)
            times = cellstr(t1.RowNames(5:16));       %can be cell of strings
%             times = t1.RowNames(5:16);              %can be datetime
            tsc2 = dst2tsc(t1,times,{'Var2','Var3'}); %convert subset of table to tscollection
            hold on
            plot(tsc2.Var2);
            %syntax tsc2dst(obj, times or time_index, variables or variable_index)
%             times2 = 3:9;
            times2 = times(3:9);
            dst = tsc2dst(tsc2,times2,1);             %convert subset tsc back to dstable
            plot(dst,'Var2','x','MarkerSize',10);        
            hold off
            displayDSproperties(dst.DSproperties); 
            
        case 11 %add variable and dimension and update dsproperties programatically
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct(option); %assign DSproperties struct              
            tv2 = t1.Var2;             %extract values for Var2
            dm2 = t1.Dimensions.Dim2;  %extract values for Dim2
            t2 = addvars(t1,tv2,'NewDSproperties',...
                {'ClusterNumber','Cluster Numbers','-','Cluster Numbers','-'});
            displayDSproperties(t2.DSproperties);
            t2.Dimensions.Dim3 = dm2;
                       
            
        case 12  %different ways of accessing data to get table or data array
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct(option); %assign DSproperties struct
            
            dim1 = t1.Dimensions.Dim1;
            idd1 = 1:length(dim1);
            dim2 = t1.Dimensions.Dim2;            
            idd2 = 1:length(dim2);
            idd = {idd1,idd2};
            
            dimr = t1.RowNames;
            idr= 1:length(dimr);
            
            dimv = t1.VariableNames;
            idv = 1:length(dimv);
            
            %extract data using index syntax
            newdst = getDSTable(t1,idr(2:3),':',{idd1,idd2(3:4)});       %#ok<*NASGU> %returns a dstable
            datatable = getDataTable(t1,idr(2:3),idv(2),{[],idd2(3:4)}); %returns a table of Var2
            vars = getData(t1,idr(1:5),[],idd);                          %returns a cell array of variable arrays
            
            %extract data using dimension values syntax
            newDST = getDSTable(t1,'RowNames',dimr(2:3),...
                      'VariableNames',dimv(2),'Dimensions.Dim2',dim2(3:4));
            dataTbl = getDataTable(t1,'RowNames',dimr(2:3),...
                      'VariableNames',dimv(2),'Dimensions.Dim2',dim2(3:4));            
            varData = getData(t1,'RowNames',dimr(1:5),...
                                            'Dimensions.Dim2',dim2(3:4));            
            %check that results are the same
            acheck = varData{1}-vars{1}(:,:,3:4); disp(acheck)
            
            %extract data from table
            T = t1.DataTable;
            newT = T(idr(2:3),idv(2));                     %returns subtable
            Tdat1 = T{idr(2:3),idv(2)}(:,idd1,idd2(3:4));  %returns data set
            Tdat2 = T{idr(2:3),'Var2'}(:,idd{:});          %equivalent syntax
            Tdat3 = T.Var2(2:3,idd{:});
            %in the above row and variable can be indices or values, but
            %dimension can only be indices. if using idd it must have a
            %cell for every dimension, which can be empty to select all
            %check that results are the same
            acheck = varData{2}(2:3,:,:)-Tdat1; disp(acheck)
            %Tdat1-Tdat2(:,:,3:4)
            
        case 99 %generate variables of different dimension
            s = rng; %control random number generator (does not need to be passed to fcn)
            var1 = set_variable(5); disp(var1)
            rng(s);
            var2 = set_variable(1,2); disp(var2)
            rng(s);
            var3 = set_variable(2,3,3); disp(var3)
    end    
end
%%
%--------------------------------------------------------------------------
%   Tests for dstb_usage
%--------------------------------------------------------------------------
function dm = test_dstb_usage()
    %test the components of the toolbox using a calling class

    %initialise class that manages calls to models and data classes
    dm = dstb_usage;
    %run model twice and load two data sets
    run_a_model(dm);
    load_data(dm);
    run_a_model(dm);
    load_data(dm);
    %plot results
    plotCase(dm);
    %display DSproperties of a selected Case
    displayProps(dm);
end
%%
%--------------------------------------------------------------------------
%   Additional functions used by test functions
%--------------------------------------------------------------------------
function dsp = dsp_struct(options)
    %populate the DSproperties stuct as a struct array 
    %uses cell arrays of row or column vectors (but not string arrays)
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
            dsp.Variables = struct(...
                'Name',{'Var1','Var2','Var3'},...
                'Description',{'Variable 1','Variable 2','Variable 3'},...
                'Unit',{'m2','m3','m'},...
                'Label',{'Area','Volume','Length'},...
                'QCflag',{'raw','-','model'}); 

            switch options(1)      %Rows
                case 1  %datetime format
                    dsp.Row = struct(...
                        'Name',{'Time'},...
                        'Description',{'Row Description'},...
                        'Unit',{'time'},...
                        'Label',{'s'},...
                        'Format',{'dd-MMM-uuuu HH:mm:ss'});  
                case 2  %duration format
                    dsp.Row = struct(...
                        'Name',{'Time'},...
                        'Description',{'Row Description'},...
                        'Unit',{'year'},...
                        'Label',{'s'},...
                        'Format',{'y'});  
                otherwise
                    dsp.Row = struct(...
                        'Name',{'Index'},...
                        'Description',{'Row Description'},...
                        'Unit',{'id'},...
                        'Label',{'Index'},...
                        'Format',{''});  
            end
            
            dsp.Dimensions = struct(...
                'Name',{'Dim1';'Dim2'},...
                'Description',{'Dim 1';'Dim 2'},...
                'Unit',{'m';'m'},...
                'Label',{'Dimension1';'Dimension2'},...
                'Format',{'';''}); 
            
            for i=1:2                 %Dimensions
                switch options(i+1)
                    case 1  %datetime format
                        aformat = 'dd-MMM-uuuu HH:mm:ss';
                    case 2  %duration format 
                        aformat = 'y';
                    otherwise
                        aformat = '';
                end
                dsp.Dimensions(i).Format = aformat;
            end
end
%%
function dsp = dsp_cellstruct
    %populate the DSproperties stuct as a struct of cell arrays
    %uses cell arrays of row or column vectors or string arrays
    dsp = struct('Variables',[],'Row',[],'Dimensions',[]);
    dsp.Variables.Name = {'Var1','Var2','Var3'};
    dsp.Variables.Description = {'Variable 1','Variable 2','Variable 3'};
    dsp.Variables.Unit = ["m2","m3","m"];  
    dsp.Variables.Label = {'Area','Volume','Length'};
    dsp.Variables.QCflag = {'raw','-','model'};
    dsp.Row.Name = 'Time';
    dsp.Row.Description = 'Row Description';
    dsp.Row.Unit = 'time';
    dsp.Row.Label = 's';
    dsp.Row.Format = 'dd-MMM-yyyy HH:mm:ss';
    dsp.Dimensions.Name = {'Dim1';'Dim2'};
    dsp.Dimensions.Description = {'Distance 1';'Distance 2'};
    dsp.Dimensions.Unit = {'m';'m'};
    dsp.Dimensions.Label = {'Distance';'Distance'};
    dsp.Dimensions.Format = {'na';'na'};        
end
%%
function dsp = dsp_partialstruct
    %populate only the variable names of a DSproperties struct
    dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
    dsp.Variables = struct(...
        'Name',{'var1'},...
        'Description',{''},...
        'Unit',{''},...
        'Label',{''},...
        'QCflag',{''}); 
    dsp.Row = struct(...
        'Name',{''},...
        'Description',{''},...
        'Unit',{''},...
        'Label',{''},...
        'Format',{''});            
    dsp.Dimensions = struct(...
        'Name',{'Dim1'},...
        'Description',{''},...
        'Unit',{''},...
        'Label',{''},...
        'Format',{''}); 
end
%%
function dimensions = set_dimension(idx,idim,offset)
    %set different types of dimension (used for row and dimensions)
    if nargin<3, offset = 0; end
    switch idx
        case 1  %datetime format
            dimensions = getdate(idim,offset);
        case 2  %duration format
            yrdate = getdate(idim,0);
            dimensions = (yrdate-yrdate(1))+years(offset);
            dimensions.Format = 'y';
        case 3  %char format
            dimensions = get_text(idim,offset);
        case 4  %string format
            txt = get_text(idim,offset);
            dimensions = string(txt);
        case 5  %numeric format
            dimensions(1,:) = (1:idim)+offset;
        case 6  %categorical
            dimensions = categorical(get_text(idim,offset));
        case 7  %ordinal 
            dimensions =  categorical(get_text(idim,offset),'Ordinal',true);   
        case 8  %test duplicate dimension check
            dimensions = 1:idim;
            if idim>1
                dimensions(idim-1) = dimensions(1); 
            else
                dimensions = [];
            end
        
    end
    %
        function yrdate = getdate(idim,offset)
            date = datetime("now");
            addyear = years((1:idim)')+offset;
            yrdate = date+addyear;
        end
    %
        function txt = get_text(idim,offset)
            for i=1:idim
                txt{1,i} = sprintf('Text %u',i+offset); %#ok<AGROW>
            end
        end
end
%%
function var = set_variable(nrow,ndim1,ndim2,ndim3)
    %set variables of different dimensions 
    if nargin<2        
        var = rand(nrow,1);
    elseif nargin<3
        var = rand(nrow,ndim1);
    elseif nargin<4
        var = rand(nrow,ndim1,ndim2);
    else
        var = rand(nrow,ndim1,ndim2,ndim3);
    end    
end
%%
function tt = dummytable(option)
    %generate table of multi-dimensional arrays
    nrows = 5; ndim1 = 9; ndim2 = 7;    
    varnames = {'Var1','Var2','Var3'};
    data1 = set_variable(nrows,ndim1,ndim2);
    data2 = set_variable(nrows,ndim1,ndim2);
    data3 = set_variable(nrows,ndim1,ndim2);
    rowdims = set_dimension(option(1),nrows);
    dim1 =  set_dimension(option(2),ndim1);
    dim2 =  set_dimension(option(3),ndim2);
    tt = dstable(data1,data2,data3,'RowNames',rowdims,...
                      'VariableNames',varnames,...
                      'DimensionNames',{'Dim1','Dim2'});
    tt.Dimensions.Dim1 = dim1;
    tt.Dimensions.Dim2 = dim2;
    tt.DataTable
    tt.Description = 'My Table';             
end
%%
function tt = tstable()
    %generate a table of timeseries variables
    nrows = 20; 
    varnames = {'Var1','Var2','Var3'};
    data1 = set_variable(nrows,1,1);
    data2 = set_variable(nrows,1,1);
    data3 = set_variable(nrows,1,1);
    rowdims = set_dimension(1,nrows);
    tt = dstable(data1,data2,data3,'RowNames',rowdims,...
                      'VariableNames',varnames);
    tt.Description = 'TS Table';     
end
%%
function outscript(txt,v1,v2)
    %check whether variables are numeric and then print to command window
    if isnumeric(v1)
        v1 = string(v1);
        v2 = string(v2);
    end
    fprintf(txt,v1,v2);
end