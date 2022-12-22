function example_folder()
%find the location of the example folder and open it
fname = 'dstable.m';
toolboxpath = which(fname);
fpath = [toolboxpath(1:end-length(fname)),'example'];
try
    winopen(fpath)
catch
    msg = sprintf('The examples can be found here:\n%s',fpath);
    msgbox(msg)
end