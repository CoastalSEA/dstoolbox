function test_dstoolbox(classname,casenum,option)
%
%-------function help------------------------------------------------------
% NAME
%   test_dstoolbox.m
% PURPOSE
%   functions to test ds components of the dstoolbox
% USAGE
%   test_dstoolbox('funcname',casenum,option);
%       e.g. test_dstoolbox('dstable',6,[1,3,5]);
% INPUT
%   classsname - name of dstoolbox class function to be tested
%   testnum - numver of test to run
%   option  - selects format for dimesnion when calling set_dimension in
%             dstable (single value or vector depending on case)
% OUTPUT
%   See in-code comments for details of test and in-code outputs.
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    switch classname
        case 'dscatalogue'  %Class to manage catalogue of cases held
            test_dscatalogue;
        case 'dsproperties' %Class to manage the meta-data properties
            test_dsproperties(casenum);
        case 'dstable'       %collection of one or more datasets with one 
                             %or more common dimension vectors
            test_dstable(casenum,option);
        case 'dscollection'
            %interface needs to be implemented by a class
        case 'dstb_usage'    %example of using the dstoolbox
            test_dstb_usage(casenum);
    end
end
%%
function test_dscatalogue()
    %test set, get edit and delete functions
    dsCases = dscatalogue;

    recnum1 = setCase(dsCases,'TestClass','model');
    recnum2 = setCase(dsCases,'TestClass','model');
    recnum3 = setCase(dsCases,'DifferentClass','data');
    recnum4 = setCase(dsCases,'DifferentClass','data');
    recnum5 = setCase(dsCases,'DifferentClass','data');

    casedef = getCase(dsCases,recnum2);
    display(casedef)
    casedef = getCase(dsCases,[],4);
    display(casedef)

    [caserec,newdesc] = editRecord(dsCases,recnum3);
    fprintf('Record %g: %s\n',caserec,newdesc{1})
    
    [caserec,~] = selectRecord(dsCases,'PromptText','Select case:',...
                     'CaseClass','TestClass','ListSize',[250,200]);
    fprintf('Record %g\n',caserec)
    
    deleteRecords(dsCases);
    display(dsCases.Catalogue)
end
%%
function test_dsproperties(testnum)
    %test set, edit, delete and display options
    switch testnum
        case 1  %Set individual assinement
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
            
        case 4 
            aa = dsproperties(dsp_struct);  %alternative call to initialise        
            aa.Variables = [];              %clear all Variables
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
            dsp = dsp_struct;               %predefined struct array
            setDSproperties(aa,dsp);        %load a dsp struct directly
            setDSproperties(aa);            %call ui to edit
            displayDSproperties(aa);        %display current definition
            
        case 7  %assign a struct of cell arrays
            aa = dsproperties;              %create blank dsproperties
            setDSproperties(aa,dsp_cellstruct); %load a dsp struct directly
            setDSproperties(aa);            %call ui to edit
            displayDSproperties(aa);        %display current definition
            
        case 8  %set and manipulate using option 2
            bb = dsproperties(dsp_struct);  %alternative call to initialise
            bb_str = bb.Variables;          %assign DSproperties struct
            bad_str = rmfield(bb_str,'Label');%remove a row field from struct
            bb.Variables = bad_str;         %assign incomplete struct (fails)
            bb.Variables = bb_str;          %assign existing struct
            displayDSproperties(bb);        %display current definition
            
        case 9  %test removal of variables and dimensions
            %varnames/dimnames can be character vector, cell array of 
            %character vectors, string array, numeric array, logical array
            cc = dsproperties(dsp_cellstruct);%initialise with cell struct
            varnames = {'var2','var3'};
            rmVariables(cc,varnames);       %remove variables
            dimnames = 'Dim1';
            rmDimensions(cc,dimnames);      %remove dimension
            displayDSproperties(cc);        %display current definition
            
        case 10  %test addition of variables and dimensions
            %varprops/dimprops can be a Variables struct, cell array, 
            %or just the name of the variable to be added
            dd = dsproperties(dsp_cellstruct);%initialise with cell struct
            varprops = 'var4';
            addVariables(dd,varprops)
            dimprops = struct(...
                'Name',{'Dim3';'Dim4'},...
                'Description',{'Distance 3';'Distance 4'},...
                'Unit',{'m';'m'},...
                'Label',{'Distance';'Distance'},...
                'Format',{'na';'na'});
            addDimensions(dd,dimprops)
            displayDSproperties(dd);        %display current definition
            
        case 11  %test change order of variables and dimensions
            %varname is character vector,string scalar,integer,logical array
            %position is 'Before' or 'After'
            %location is character vector,string scalar,integer,logical array
            ee = dsproperties(dsp_struct);  %initialise with struct array
            varname = 'var3';
            location = "var2";
            moveVariable(ee,varname,'Before',location)
            moveDimension(ee,1,'After',[false,true])
            displayDSproperties(ee);        %display current definition
            
        case 12  %test input of struct with empty fields
            ff = dsproperties(dsp_partialstruct,'test');%create partial struct with blanks
            displayDSproperties(ff);        %display current definition
    end
end
%%
function test_dstable(testnum,option)
    %test initialisation, setting, accessing, editing and deleting dstable
    switch testnum
        case 1  %initialise a blank dstable
            t1 = dstable     
            
        case 2  %create a simple table with no dimensions
            nrows = 5;
            varnames = {'Var1'};
            data = set_variable(nrows);
            rownames = set_dimension(option,nrows);
            t1 = dstable(data,'RowNames',rownames,'VariableNames',varnames);
            t1.DataTable
            t1.DSproperties = dsp_partialstruct; %variable names in DSproperties struct
            displayDSproperties(t1.DSproperties);        %display current definition
            
        case 3  %create table with 2d+t array. option is 1x3 vector to 
                %define the data type for row and dimensions
            t1 = dummytable(option);    
            displayDSproperties(t1.DSproperties);        %display current definition
            fprintf('Row: %s to %s\n',t1.RowRange{1},t1.RowRange{2})
            fprintf('Dim1: %s to %s\n',t1.DimensionRange.Dim1{1},t1.DimensionRange.Dim1{2})
            fprintf('Dim2: %s to %s\n',t1.DimensionRange.Dim2{1},t1.DimensionRange.Dim2{2})
            fprintf('Var: %s to %s\n',t1.VariableRange.Var1{1},t1.VariableRange.Var1{2})            
            
        case 4  %update the values in the variable
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct; %assign DSproperties struct
            fprintf('Var: %s to %s\n',t1.VariableRange.Var1{1},t1.VariableRange.Var1{2})
            t1.Var1 = t1.Var1*2;
            fprintf('Var: %s to %s\n',t1.VariableRange.Var1{1},t1.VariableRange.Var1{2})
            %now test manipulation of dstable                       
            tv2 = t1.Var2;      %extract values for Var2
            t2 = removevars(t1,'Var2');        %create new dst and remove Var2
            t1.Var2 = [];                      %remove Var2 from original table
            addvars(t2,tv2,'Before','Var3');   %restore Var2
            movevars(t2,'Var2','After','Var3');%move Var2 after Var3
            dsp = t2.DSproperties;             %get the current table properties
            dsp.Variables(3).QCflag = 'raw';   %update specific properties
            dsp.Variables(3).Description = 'A moved variable';
            t2.DSproperties = dsp;             %assign updated properties to table
            displayDSproperties(t2.DSproperties);
            movevars(t2,'Var3','After','Var2') %move variable and assigned properties
            displayDSproperties(t2.DSproperties);
            
        case 5 %test horzcat and vertcat - simple table with no dimensions
            nrows = 5;
            varnames = {'Var1'};
            data = set_variable(nrows);               %generate dataset
            rownames1 = set_dimension(option,nrows);  %generate row dimension
            t1 = dstable(data,'RowNames',rownames1,'VariableNames',varnames); %create table with same variable name
            rownames2 = set_dimension(option,nrows,1);%generate row dimension
            t2 = dstable(data,'RowNames',rownames2,'VariableNames',{'Var1'}); %create table
            t3 = vertcat(t2,t1);                      %vertical concatenation of the two tables
            t3.DataTable                              %display
            displayDSproperties(t3.DSproperties);
            clear t2 t3
            t2 = dstable(data,'RowNames',rownames1,'VariableNames',{'Var2'}); %create table with different variable name
            t1.VariableDescriptions = {'var1'};       %add descriptions to the variables
            t2.VariableDescriptions = {'var2'};
            t3 = horzcat(t2,t1);                      %horizontal concatenation of the two tables    
            t3.DataTable                              %display
            displayDSproperties(t3.DSproperties);
            
        case 6 %test horzcat and vertcat - multiple variables with dimensions
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct; %assign DSproperties struct
            t2 = copy(t1);  %make copy of dstable including all dynamic properties
            t2.VariableNames = {'vv1','vv2','vv3'};   %change the variable names
            t3 = horzcat(t2,t1);                      %horizontal concatenation of the two tables    
            displayDSproperties(t3.DSproperties);
            t4 = dummytable(option);                  %table with different row values
            movevars(t4,'Var2','After','Var3');       %move Var2 after Var3
            t5 = vertcat(t1,t4);                      %vertical concatenation of the two tables
            displayDSproperties(t5.DSproperties);     %display
            
        case 7 %test add variable rownames, dimensions and metadata in one call
            nrows = 5; ndim1 = 3; ndim2 = 7;
            data1 = set_variable(nrows,ndim1,ndim2);
            data2 = set_variable(nrows,ndim1,ndim2);
            data3 = set_variable(nrows,ndim1,ndim2);
            rowdims = set_dimension(option(1),nrows);
            %dsp = dsp_struct;                        %DSproperies struct
            dsp = dsproperties(dsp_struct);           %dsproperies object (prompts for name)
            t1 = dstable(data1,data2,data3,'RowNames',rowdims,'DSproperties',dsp);           
            t1.DataTable                              %display
            displayDSproperties(t1.DSproperties);     
            
        case 8 %access data using dimensions
            t1 = dummytable(option);
            t1.DSproperties = dsp_struct; %assign DSproperties struct
            dim1 = t1.Dimensions.Dim1;
            dim2 = t1.Dimensions.Dim2;
            dim3 = t1.RowNames;
            subrow = dim3(2:3);
            subvar = {'Var2'};
            subdimx = dim1(2:3);
            subdimy = dim2(1:4);
            datatable = getDataTable(t1,'RowNames',subrow,'VariableNames',subvar,...
                       'Dimensions.Dim1',subdimx,'Dimensions.Dim2',subdimy);
            newdst = getDStable(t1,'RowNames',subrow,'VariableNames',subvar,...
                       'Dimensions.Dim1',subdimx,'Dimensions.Dim2',subdimy);            
  
        case 9 %convert dstable to tscollection and back
            t1 = tstable();             %dstable of timeseries data
            t1.DSproperties = dsp_struct;   %assign properties to dstable
            tsc1 = dst2tsc(t1);         %convert to full table to tscollection
            figure; plot(tsc1.Var2);
            tsc2 = dst2tsc(t1,5:16,{'Var2','Var3'});  %convert subset of table to tscollection
            hold on
            plot(tsc2.Var2);
            dst = tsc2dst(tsc2);        %convert subset tsc back to dstable
            plot(dst,'Var2','x')         
            hold off
            displayDSproperties(dst.DSproperties); 
             
        case 99 %generate variables of different dimension
            s = rng; %control random number generator (does not need to be passed to fcn)
            var1 = set_variable(5)
            rng(s);
            var2 = set_variable(1,2)
            rng(s);
            var3 = set_variable(2,3,3)
    end    
end
%%
function test_dstb_usage(testnum)
    %test the components of the toolbox using a calling class
    switch testnum
        case 1  %initialise a blank dstable
    end
end
%%
%--------------------------------------------------------------------------
%   Additional functions used by test functions
%--------------------------------------------------------------------------
function dsp = dsp_struct
    %populate the DSproperties stuct as a struct array 
    %use  cell arrays of row or column vectors
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
            dsp.Variables = struct(...
                'Name',{'Var1','Var2','Var3'},...
                'Description',{'Variable 1','Variable 2','Variable 3'},...
                'Unit',{'m2','m3','m'},...
                'Label',{'Area','Volume','Length'},...
                'QCflag',{'raw','-','model'}); 
            dsp.Row = struct(...
                'Name',{'Time'},...
                'Description',{'Row Description'},...
                'Unit',{'time'},...
                'Label',{'s'},...
                'Format',{'dd-MM-yyyy'});            
            dsp.Dimensions = struct(...
                'Name',{'Dim1';'Dim2'},...
                'Description',{'Distance 1';'Distance 2'},...
                'Unit',{'m';'m'},...
                'Label',{'Distance';'Distance'},...
                'Format',{'na';'na'});           
end
%%
function dsp = dsp_cellstruct
    %populate the DSproperties stuct as a struct of cell arrays
    %use  cell arrays of row or column vectors
    dsp = struct('Variables',[],'Row',[],'Dimensions',[]);
    dsp.Variables.Name = {'Var1','Var2','Var3'};
    dsp.Variables.Description = {'Variable 1','Variable 2','Variable 3'};
    dsp.Variables.Unit = {'m2','m3','m'};
    dsp.Variables.Label = {'Area','Volume','Length'};
    dsp.Variables.QCflag = {'raw','-','model'};
    dsp.Row.Name = 'Time';
    dsp.Row.Description = 'Row Description';
    dsp.Row.Unit = 'time';
    dsp.Row.Label = 's';
    dsp.Row.Format = 'dd-MM-yyyy';
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
    %set different types of dimension (used for row and dimensions
    if nargin<3, offset = 0; end
    switch idx
        case 1  %datetime format
            dimensions = getdate(idim,offset);
        case 2  %duration format
            yrdate = getdate(idim,offset);
            dimensions = yrdate-yrdate(1);
            dimensions.Format = 'd';
        case 3  %char format
            dimensions = get_text(idim);
        case 4  %string format
            txt = get_text(idim);
            dimensions = string(txt);
        case 5  %numeric format
            dimensions = 1:idim;
        case 6  %test duplicate dimension check
            dimensions = 1:idim;
            if idim>1
                dimensions(idim-1) = dimensions(1); 
            else
                dimensions = [];
            end
    end
    %
        function yrdate = getdate(idim,offset)
            date = datetime(now,'ConvertFrom','datenum');
            addyear = years((1:idim)')+offset;
            yrdate = date+addyear;
        end
    %
        function txt = get_text(idim)
            for i=1:idim
                txt{1,i} = sprintf('Text %u',i);
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
    nrows = 5; ndim1 = 3; ndim2 = 7;    
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
% function tsdsp = ts_dsp()
%     %create a dsproperties obj for timeseries data
%     
% end