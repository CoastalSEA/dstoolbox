function dst = tsc2dst(tsc,idxtime,idxvars)
%
%-------function help------------------------------------------------------
% NAME
%   tsc2dst.m
% PURPOSE
%   convert dscollection or timeseries to a dstable
% USAGE
%   dst = tsc2dst(tsc)
% INPUTS
%   tsc - timeseries or tscollection
%   idxtime - index vector for the subselection of time
%   idxvars - index vector for the subselection of variables, or the 
%             variable names as a cell array of character vectors 
% OUTPUT
%   dst - dstable object
% NOTES
%   if the tsc was created using dst2tsc the DSproperties will have been
%   coped and these are used to reset the DSproperties of the new dstable
% SEE ALSO
%   dstable.m and method dst2tsc
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    if isa(tsc,'timeseries')
        tsc = tscollection(tsc);
    end
    mdate = datetime(getabstime(tsc));
    varnames = gettimeseriesnames(tsc); 
    
    nvar = length(varnames);
    nrow = length(mdate);
    if nargin<2
        idxtime = 1:nrow;
        idxvars = 1:nvar;
    elseif nargin<3               
        idxvars = 1:nvar;
    elseif isempty(idxtime)
        idxtime = 1:nrow;
    end   
    %
    if ~isnumeric(idxtime) && ~islogical(idxtime)        
       idxtime = find(ismember(mdate,idxtime,'rows'));
    end        
    %    
    if ~isnumeric(idxvars) && ~islogical(idxvars)
        idxvars = find(ismember(varnames,idxvars));
    end
    %
    mdate = mdate(idxtime);    %subsample time to selected range  
    nsubvar = length(idxvars);
    tsdata = cell(1,nsubvar);
    for j=1:nsubvar
        ts = tsc.(varnames{idxvars(j)});
        tsdata{1,j} = ts.Data(idxtime);
    end
    
    dst = dstable(tsdata{:},'RowNames',mdate,...
                                'VariableNames',varnames(idxvars));
    
    if ~isempty(tsc.TimeInfo.UserData) && ...
            isa(tsc.TimeInfo.UserData,'dsproperties')
        dsp = tsc.TimeInfo.UserData;
        if length(idxvars)~=nvar
            idvars = setdiff(1:nvar,idxvars);
            dsp.Variables(idvars) = [];
        end
        %tsc must be derived from a dstable so pass dstable metadata 
        %back to new dstable
        dst.DSproperties = dsp;
    end
end