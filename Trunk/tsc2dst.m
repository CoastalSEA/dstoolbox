function dst = tsc2dst(tsc)
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
    tsdata = cell(1,nvar);
    for i=1:nvar
        ts = tsc.(varnames{i});
        tsdata{1,i} = ts.Data;
    end
    
    dst = dstable(tsdata{:},'RowNames',mdate,'VariableNames',varnames);
    
%     for i=2:length(varnames)
%         ts = tsc.(varnames{i});
%         varname = varnames{i};
%         addvars(dst,ts.Data,'NewVariableNames',varname);        
%         dst.add_dyn_prop(varname, [], false);
%         dst.VariableRange.(varname) = getVariableRange(dst,varname);       
%     end
    
    if ~isempty(tsc.TimeInfo.UserData) && ...
            isa(tsc.TimeInfo.UserData,'dsproperties')
        %tsc must be derived from a dstable so pass dstable metadata 
        %back to new dstable
        dst.DSproperties = tsc.TimeInfo.UserData;
    end
end