function dst_open_manual()
%find the location of the dstoolbox and the introducton pdf
fname = 'dstable.m';
toolboxpath = which(fname);
fpath = [toolboxpath(1:end-length(fname)),'doc'];
fpath = [fpath,filesep,'Introduction_to_dstoolbox.pdf'];
try
    open(fpath)
catch
    msg = sprintf('Introduction to dstoolbox file not found here:\n%s',fpath);
    msgbox(msg)
end

