function sout = mergestruct(varargin)
%MERGESTRUCT Merge structures with unique fields.

% Start with collecting fieldnames, checking implicitly 
% that inputs are structures.
fn = [];
for k = 1:nargin
     try
      fn = [fn ; fieldnames(varargin{k})];
   catch MEstruct
     throw(MEstruct)
   end
 end
 
  % Make sure the field names are unique.
 if length(fn) ~= length(unique(fn))
      error('mergestruct:FieldsNotUnique',...
           'Field names must be unique');
   end

c = [];
 for k = 1:nargin
     try
         c = [c ; struct2cell(varargin{k})];
     catch MEdata
         throw(MEdata);
     end
   end
 
   % Construct the output.
  sout = cell2struct(c, fn, 1);
end 