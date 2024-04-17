function tiffloop(path, n, pmt, varargin)
%SBXFIRSTLAST Make TIFFs of the first and last 500 frames

    p = inputParser;
    addOptional(p, 'server', []);  % Server name
    addOptional(p, 'startframe', 1, @isnumeric);
    addOptional(p, 'optolevel', []);
    addOptional(p, 'force', true);
    addOptional(p, 'register', false');
    parse(p, varargin{:});
    p = p.Results;
    
    if nargin < 2, n = 500; end
    if nargin < 3, pmt = 1; end
    info = pipe.metadata(path);
    if isempty(p.optolevel)
        last_start = info.nframes - n + 1;
    else
        last_start = floor(info.nframes/length(info.otwave)) - n + 1;
    end
      %%
    tiff_start_vector1=1:(2*n):info.nframes;
    tiff_start_vector2=n+1:(2*n):info.nframes;
    if length(tiff_start_vector1)~=length(tiff_start_vector2)
        cutoff=min(length(tiff_start_vector1)~=length(tiff_start_vector2))
        tiff_start_vector1=tiff_start_vector1(1:cutoff)
        tiff_start_vector2=tiff_start_vector2(1:cutoff)
        disp('May drop frames (particularly at the end)! Frames may be out of order! Okay for Z-stack, abort for real data')
    end
    
% 501:1000;
% 1:500;
% m=n-1;
        for i=1:length(tiff_start_vector1);
        spath = sprintf('%s_-%i.tif', path(1:strfind(path,'.')-1), i);
        f500 = pipe.imread(path, tiff_start_vector1(i), n, pmt, p.optolevel, 'register', p.register);
        f1000 = pipe.imread(path, tiff_start_vector2(i), n, pmt, p.optolevel, 'register', p.register);
        pipe.io.write_tiff(cat(3, f500,f1000), spath, class(f500));
        end     
end