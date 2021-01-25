classdef Dispstr
  % All the dispstr implementation code, wrapped up in a class
  %
  % We make it a class so that all the definitions can live in a single
  % file, which makes it easy (well, maybe not easy, just not a huge pain in the
  % ass) to transform the code to relocate its package, which will hopefully
  % allow us to generate "compatters" for internal use by other libraries that
  % don't want to take a dependency on dispstr.
  
  methods (Static)
    
    function out = convertArgsForPrintf(args)
      out = args;
      for i = 1:numel(args)
        arg = args{i};
        if isobject(arg)
          if isstring(arg) && isscalar(arg)
            % NOP; we want to keep the single string and let it be interpolated
            % as normal
          elseif isa(arg, 'datetime') || isa(arg, 'duration') || isa(arg, 'calendarDuration')
            % NOP; these already support %s conversions
          else
            out{i} = dispstr(arg);
          end
        end
      end
    end
    
    function disp(x)
      if iscell(x)
        dispstrlib.internal.Dispstr.dispCell(x);
      elseif isnumeric(x)
        builtin('disp', x);
      elseif isstruct(x)
        dispstrlib.internal.Dispstr.dispStruct(x);
      elseif istable(x)
        dispstrlib.internal.Dispstr.prettyprintTabular(x);
      else
        builtin('disp', x);
      end
    end
    
    function display(x) %#ok<DISPLAY>
      label = inputname(1);
      if ~isempty(label)
        fprintf('%s =\n', label);
      end
      dispstrlib.internal.Dispstr.disp(x);
    end
    
    function out = dispstr(x)      
      if ~ismatrix(x)
        out = sprintf('%s %s', size2str(size(x)), class(x));
      elseif isempty(x)
        if ischar(x) && isequal(size(x), [0 0])
          out = '''''';
        elseif isnumeric(x) && isequal(size(x), [0 0])
          out = '[]';
        else
          out = sprintf('Empty %s %s', size2str(size(x)), class(x));
        end
      elseif isnumeric(x)
        if isscalar(x)
          out = num2str(x);
        else
          strs = strtrim(cellstr(num2str(x(:))));
          strs = reshape(strs, size(x));
          out = formatArrayOfStringsAsMat2strExpr(strs);
        end
      elseif ischar(x)
        if isrow(x)
          out = ['''' x ''''];
        else
          strs = strcat({''''}, num2cell(x,2), {''''});
          out = formatArrayOfStringsAsMat2strExpr(strs);
        end
      elseif iscell(x)
        if iscellstr(x)
          strs = strcat('''', x, '''');
        else
          strs = cellfun(@dispstr, x, 'UniformOutput',false);
        end
        out = formatArrayOfStringsAsMat2strExpr(strs, {'{','}'});
      elseif isstring(x)
        strs = cellstr(x);
        out = formatArrayOfStringsAsMat2strExpr(strs, {'[',']'});
      elseif isa(x, 'datetime') && isscalar(x)
        if isnat(x)
          out = 'NaT';
        else
          out = char(x);
        end
      elseif isscalar(x) && (isa(x, 'duration') || isa(x, 'calendarDuration'))
        out = char(x);
      elseif isscalar(x) && iscategorical(x)
        out = char(x);
      else
        out = sprintf('%s %s', size2str(size(x)), class(x));
      end
      
      out = string(out);
      
    end
    
    function out = dispstrs(x)
      if isempty(x)
        out = reshape({}, size(x));
      elseif isnumeric(x)
        out = dispstrsNumeric(x);
      elseif islogical(x)
        out = dispstrsLogical(x);
      elseif iscellstr(x)
        out = x;
      elseif isstring(x)
        out = cellstr(x);
      elseif iscell(x)
        out = dispstrsGenericDisp(x);
      elseif ischar(x)
        % An unfortunate consequence of the typical use of char and dispstrs' contract
        out = num2cell(x);
      elseif isa(x, 'tabular')
        out = dispstrsTabular(x);
      elseif isa(x, 'datetime')
        out = dispstrsDatetime(x);
      elseif isa(x, 'struct')
        out = repmat({'1-by-1 struct'}, size(x));
      else
        out = dispstrsGenericDisp(x);
      end
      
      out = string(out);
      
    end
    
    function out = reprstr(x)
      if isnumeric(x)
        out = string(mat2str2(x));
      elseif ischar(x)
        out = string(mat2str2(x));
      elseif isstring(x)
        out = string(mat2str2(x));
      elseif islogical(x)
        out = string(mat2str2(x));
      elseif isstruct(x)
        if isscalar(x)
          out = mat2str2(x);
        else
          out = sprintf("<%s %s, fields %s>", size2str(size(x)), 'struct', ...
            strjoin(fieldnames(x), ', '));
        end
      else
        % If we're here, it's not an object of that overrides reprstr; do
        % something generic.
        out = sprintf("<%s: %s: %s>", class(x), size2str(size(x)), dispstr(x));
      end
    end
    
    function out = reprstrs(x)
      % TODO: Real implementation
      % TODO: Escaping of special characters inside strings
      if ischar(x)
        out = compose("'%s'", strrep(x, "'", "''"));
      elseif isstring(x)
        out = compose("""%s""", strrep(x, """", """"""));
      elseif isnumeric(x)
        % TODO: Be smarter about picking precision? Would be nice to just
        % display to eps maybe?
        out = dispstrlib.internal.Dispstr.num2strs(x);
      elseif islogical(x)
        out = repmat("false", size(x));
        out(x) = "true";
      elseif isdatetime(x)
        out = dispstrlib.internal.Dispstr.looooooongDatestrs(x);
      elseif iscell(x)
        cellContentsReprs = string(size(x));
        for i = 1:numel(x)
          cellContentsReprs(i) = reprstr(x{i});
        end
        out = compose("{ %s }", cellContentsReprs);
      elseif isstruct(x)
        out = strings(size(x));
        for i = 1:numel(x)
          out(i) = mat2str2(x(i));
        end
      else
        % If we got here, then it's not an object that overrides reprstrs
        % itself, so do something generic.
        out = repmat(string(missing), size(x));
        strs = dispstrs(x);
        for i = 1:numel(x)
          out(i) = sprintf("<%s: %s>", class(x), strs(i));
        end
      end
    end
    
    function out = mat2str2(x)
      % TODO: Add support for more types and sizes
      if isnumeric(x) || isstring(x) || islogical(x)
        out = dispstrlib.internal.Dispstr.mat2strExtendedSizes(x);
      elseif iscell(x)
        out = dispstrlib.internal.Dispstr.mat2strCell(x);
      elseif isstruct(x)
        out = dispstrlib.internal.Dispstr.mat2strStruct(x);
      else
        % Rely on object overrides or whatever functionality Matlab provides
        out = mat2str(x);
      end
    end
    
    function out = mat2strExtendedSizes(x, ndimStyle)
      % Uses basic mat2str() but adds support for n-d arrays
      arguments
        x
        ndimStyle (1,1) string {mustBeMember(ndimStyle, ["cat", "reshape"])} = "reshape"
      end
      if ismatrix(x)
        out = mat2str(x);
      else
        if ndimStyle == "cat"
          nd = ndims(x);
          len = size(x, nd);
          pageExprs = repmat(string(missing), [1 len]);
          colons = repmat({':'}, [1 len-1]);
          for i = 1:len
            ix = [colons {i}];
            page = x(ix{:});
            pageExprs(i) = dispstrlib.internal.Dispstr.mat2strExtendedSizes(page);
          end
          out = sprintf("cat(%d, %s)", strjoin(pageExprs, ", "));
        else
          vectorExpr = mat2str(x(:)');
          out = sprintf("reshape(%s, %s)", vectorExpr, mat2str(size(x)));
        end
      end
    end
    
    function out = mat2strCell(x)
      cellExprs = repmat(string(missing), size(x));
      for i = 1:numel(x)
        cellExprs(i) = mat2str2(x{i});
      end
      out = formatArrayOfStringsAsMat2strExpr(cellExprs, ["{" "}"]);
    end
    
    function out = mat2strStruct(x)
      elExprs = repmat(string(missing), size(x));
      fields = string(fieldnames(x));
      for iEl = 1:numel(x)
        s = x(iEl);
        argExprs = repmat(string(missing), [2 numel(fields)]);
        argExprs(1,:) = strcat("'", fields, "'");
        for iField = 1:numel(fields)
          fieldExpr = mat2str2(s.(fields{iField}));
          if iscell(s.(fields{iField}))
            % Gotta protect cell arguments from expansion by struct()
            fieldExpr = sprintf("{%s}", fieldExpr);
          end
          argExprs(2,iField) = fieldExpr;
        end
        sExpr = sprintf("struct(%s)", strjoin(argExprs(:), ", "));
        elExprs(iEl) = sExpr;
      end
      out = formatArrayOfStringsAsMat2strExpr(elExprs);
    end
    
    function dispCell(c)
      
      if ~iscell(c)
        error('input must be a cell; got a %s', class(c));
      end
      if isempty(c)
        if isequal(size(c), [0 0])
          fprintf('{}\n');
        else
          fprintf('Empty %s %s\n', size2str(c), 'cell array');
        end
        return
      end
      
      dstrs = repmat(string(missing), size(c));
      for i = 1:numel(c)
        dstrs(i) = dispstr(c{i});
      end
      dstrs = strcat("{", dstrs, "}");
      
      fprintf('%s\n', dispstrlib.internal.Dispstr.prettyprintArray(dstrs));
    end
    
    function dispStruct(x)
      s = x;
      if ~isscalar(s)
        disp(s);
        return
      end
      flds = fieldnames(s);
      for i = 1:numel(flds)
        val = s.(flds{i});
        if isobject(val)
          if alreadySupportsPrintf(val)
            % NOP
          else
            s.(flds{i}) = dispstr(val);
          end
        end
      end
      builtin('disp', s);
    end
    
    function out = dispc(x) %#ok<INUSD>
      %DISPC Display, with capture
      out = evalc('disp(x)');
      out(end) = []; % chomp
    end
    
    function out = looooooongDatestrs(dt, doTimeZone)
      arguments
        dt
        doTimeZone (1,1) logical = true
      end
      dt = dispstrlib.internal.util.todatetime(dt);
      tz = dt.TimeZone;
      out = repmat(string(missing), size(dt));
      dvec = datevec(dt);
      % TODO: Vectorize this loop
      for i = 1:numel(dt)
        secs = floor(dvec(i,6));
        nanos = round(rem(dvec(i,6), 1) * 1000000000);
        if nanos == 1000000000
          secs = secs + 1;
          nanos = 0;
        end
        dstr = sprintf("%4d-%02d-%02d %02d:%02d:%02d.%09d", dvec(i,1), dvec(i,2), ...
          dvec(i,3), dvec(i,4), dvec(i,5), secs, nanos);
        if doTimeZone && ~isempty(tz)
          dstr = dstr + " " + tz;
        end
        out(i) = dstr;
      end
    end
    
    function out = isErrorIdentifier(str)
      str = char(str);
      out = ~isempty(regexp(str, '^[\w:]$', 'once')) && any(str == ':');
    end
    
    function out = mycombvec(vecs)
      %MYCOMBVEC All combinations of values from vectors
      %
      % This is similar to Matlab's combvec, but has a different signature.
      if ~iscell(vecs)
        error('Input vecs must be cell');
      end
      switch numel(vecs)
        case 0
          error('Must supply at least one input vector');
        case 1
          out = vecs{1}(:);
        case 2
          a = vecs{1}(:);
          b = vecs{2}(:);
          out = repmat(a, [numel(b) 2]);
          i_comb = 1;
          for i_a = 1:numel(a)
            for i_b = 1:numel(b)
              out(i_comb,:) = [a(i_a) b(i_b)];
              i_comb = i_comb + 1;
            end
          end
        otherwise
          a = vecs{1}(:);
          rest = vecs(2:end);
          rest_combs = dispstrlib.internal.Dispstr.mycombvec(rest);
          n_combs = numel(a) * size(rest_combs, 1);
          out = repmat(a(1), [n_combs 1+size(rest_combs, 2)]);
          for i = 1:numel(a)
            n = size(rest_combs, 1);
            this_comb = [repmat(a(i), [n 1]) rest_combs];
            out(1+((i-1)*n):1+(i*n)-1,:) = this_comb;
          end
      end
    end
    
    function out = num2cellstr(x)
      %NUM2CELLSTR Like num2str, but return cellstr of individual number strings
      out = strtrim(cellstr(num2str(x(:))));
    end
    
    function out = num2strs(x, format)
      if nargin == 1
        c = num2str(x(:));
      else
        c = num2str(x(:), format);
      end
      out = reshape(strtrim(string(c)), size(x));
    end
    
    function out = prettyprintArray(strs)
      %PRETTYPRINT_ARRAY Pretty-print an array from dispstrs
      %
      % out = prettyprintArray(strs)
      %
      % Converts an n-dimensional array of display strings to a multi-line
      % formatted display of same. This is the sort of thing you see when
      % you disp() an array.
      %
      % strs (string) is an array of display strings of any size.
      arguments
        strs string
      end
      if ismatrix(strs)
        out = dispstrlib.internal.Dispstr.prettyprintMatrix(strs);
      else
        sz = size(strs);
        high_sz = sz(3:end);
        high_ixs = {};
        for i = 1:numel(high_sz)
          high_ixs{i} = (1:high_sz(i))';
        end
        page_ixs = dispstrlib.internal.Dispstr.mycombvec(high_ixs);
        chunks = {};
        for i_page = 1:size(page_ixs, 1)
          page_ix = page_ixs(i_page,:);
          chunks{end+1} = sprintf('(:,:,%s) = ', ...
            strjoin(dispstrlib.internal.Dispstr.num2cellstr(page_ix), ',')); %#ok<*AGROW>
          page_ix_cell = num2cell(page_ix);
          page_strs = strs(:,:,page_ix_cell{:});
          chunks{end+1} = dispstrlib.internal.Dispstr.prettyprintMatrix(page_strs);
        end
        out = strjoin(chunks, '\n');
      end
      if nargout == 0
        disp(out);
        clear out;
      end
    end
    
    function out = prettyprintMatrix(strs)
      % Pretty-print a matrix of arbitrary display strings
      %
      % out = prettyprintMatrix(strs)
      %
      % strs is a matrix of strings which are already converted to their display
      % form.
      if ~ismatrix(strs)
        error('Input must be matrix; got %d-D', ndims(strs));
      end
      lens = cellfun('prodofsize', strs);
      widths = max(lens, 1);
      formats = dispstrlib.internal.Dispstr.sprintfv('%%%ds', widths);
      format = strjoin(formats, '   ');
      lines = cell(size(strs,1), 1);
      for i = 1:size(strs, 1)
        lines{i} = sprintf(format, strs{i,:});
      end
      out = strjoin(lines, '\n');
      if nargout == 0
        fprintf('%s\n', out);
        clear out;
      end
    end
    
    function out = prettyprintCell(c)
      %PRETTYPRINT_CELL Cell implementation of prettyprint
      
      %TODO: Maybe justify each cell independently based on its content type
      
      strs = cellfun(@dispstr, c, 'UniformOutput',false);
      colWidths = NaN(1, size(c,2));
      colFormats = cell(1, size(c,2));
      for i = 1:size(c, 2)
        colWidths(i) = max(cellfun('length', strs(:,i)));
        colFormats{i} = ['{ %' num2str(colWidths(i)) 's }'];
      end
      
      rowFormat = ['  ' strjoin(colFormats, '   ')];
      lines = cell(1, size(c,1));
      for i = 1:size(c, 1)
        lines{i} = sprintf(rowFormat, strs{i,:});
      end
      
      out = strjoin(lines, newline);
      
    end
    
    function out = prettyprintStruct(s)
      %PRETTYPRINT_STRUCT struct implementation of prettyprint
      
      if isscalar(s)
        fields = fieldnames(s);
        if isempty(fields)
          out = 'Scalar struct with zero fields';
          return;
        end
        fieldLens = cellfun('length', fields);
        maxFieldLen = max(fieldLens);
        lines = cell(1, numel(fields));
        for iField = 1:numel(fields)
          field = fields{iField};
          lines{iField} = sprintf('    %*s: %s', maxFieldLen, field, dispstr(s.(field)));
        end
        out = strjoin(lines, newline);
      else
        out = dispstrlib.internal.Dispstr.dispc(s);
      end
      
    end
    
    function out = prettyprintTabular(t)
      %PRETTYPRINT_TABULAR Tabular implementation of prettyprint
      
      %TODO: Probably put quotes around strings
      
      varNames = t.Properties.VariableNames;
      nVars = numel(varNames);
      if nVars == 0
        out = sprintf('%s table with zero variables', size2str(size(t)));
        return;
      end
      varVals = cell(1, nVars);
      
      for i = 1:nVars
        varVals{i} = t{:,i};
      end
      
      out = dispstrlib.internal.Dispstr.prettyprintTabular_generic(varNames, varVals, true);
      if nargout == 0
        fprintf('%s\n', out);
      end
    end
    
    function out = prettyprintTabular_generic(varNames, varVals, quoteStrings)
      % A generic tabular pretty-print that can be used for tabulars or relations
      arguments
        varNames string
        varVals cell
        quoteStrings logical = false
      end
      
      nVars = numel(varNames);
      nRows = numel(varVals{1});
      
      varStrs = cell(1, nVars);
      varStrWidths = NaN(1, nVars);
      for i = 1:nVars
        varStrs{i} = dispstrs(varVals{i});
        if quoteStrings
          if isstring(varVals{i})
            varStrs{i} = strjoin('"', varVals{i}, '"');
          end
        end
        varStrWidths(i) = max(cellfun('length', varStrs{i}));
      end
      varNameWidths = cellfun('length', varNames);
      colWidths = max([varNameWidths; varStrWidths]);
      
      lines = cell(1, nRows+2);
      
      headerFormat = ['    ' strjoin(repmat({'%-*s'}, [1 nVars]), '   ')];
      rowVals = rowData2sprintfArgs(colWidths, varNames);
      lines{1} = sprintf(headerFormat, rowVals{:});
      
      colFormats = cell(1, nVars);
      for i = 1:nVars
        if isnumeric(varVals{i})
          colFormats{i} = '%*s';
        else
          colFormats{i} = '%-*s';
        end
      end
      rowFormat = ['    ' strjoin(colFormats, '   ')];
      
      underlines = arrayfun(@(n) repmat('_', [1 n]), colWidths, 'UniformOutput',false);
      rowVals = rowData2sprintfArgs(colWidths, underlines);
      lines{2} = sprintf(rowFormat, rowVals{:});
      
      varStrs = cat(2, varStrs{:});
      for i = 1:nRows
        rowVals = rowData2sprintfArgs(colWidths, varStrs(i,:));
        lines{i+2} = sprintf(rowFormat, rowVals{:});
      end
      
      out = strjoin(lines, newline);
      if nargout == 0
        fprintf('%s\n', out);
      end
      
    end
    
    function out = sprintfv(format, varargin)
      %SPRINTFV "Vectorized" sprintf
      %
      % out = sprintfv(format, varargin)
      %
      % SPRINTFV is an array-oriented form of sprintf that applies a format to array
      % inputs and produces a cellstr.
      %
      % This is not a high-performance method. It's a convenience wrapper around a
      % loop around sprintf().
      %
      % Returns cellstr.
      
      args = varargin;
      sz = [];
      for i = 1:numel(args)
        if ischar(args{i})
          args{i} = { args{i} };  %#ok<CCAT1>
        end
        if ~isscalar(args{i})
          if isempty(sz)
            sz = size(args{i});
          else
            if ~isequal(sz, size(args{i}))
              error('Inconsistent dimensions in inputs');
            end
          end
        end
      end
      if isempty(sz)
        sz = [1 1];
      end
      
      out = cell(sz);
      for i = 1:numel(out)
        theseArgs = cell(size(args));
        for iArg = 1:numel(args)
          if isscalar(args{iArg})
            ix_i = 1;
          else
            ix_i = i;
          end
          if iscell(args{iArg})
            theseArgs{iArg} = args{iArg}{ix_i};
          else
            theseArgs{iArg} = args{iArg}(ix_i);
          end
        end
        out{i} = sprintf(format, theseArgs{:});
      end
    end
    
  end
  
end

function out = formatArrayOfStringsAsMat2strExpr(strs, brackets, ndimStyle)
arguments
  strs string
  brackets (1,2) string = ["[" "]"]
  ndimStyle (1,1) string {mustBeMember(ndimStyle, ["cat", "reshape"])} = "cat"
end
if isscalar(strs)
  out = strs;
elseif ismatrix(strs)
  rowStrs = repmat(string(missing), [size(strs,1), 1]);
  for iRow = 1:size(strs,1)
    rowStrs(iRow) = strjoin(strs(iRow,:), ' ');
  end
  out = brackets(1) + strjoin(rowStrs, '; ') + brackets(2);
else
  if ndimStyle == "cat"
    nd = ndims(strs);
    len = size(strs, nd);
    subExprs = repmat(string(missing), [1 len]);
    colons = repmat({':'}, [1 nd-1]);
    for i = 1:len
      ix = [colons {i}];
      subStrs = strs(ix{:});
      subExprs(i) = formatArrayOfStringsAsMat2strExpr(subStrs, brackets, ndimStyle);
    end
    out = sprintf("cat(%d, %s)", nd, strjoin(subExprs, ", "));
  else
    vectorExpr = formatArrayOfStringsAsMat2strExpr(strs(:)', brackets);
    out = sprintf("reshape(%s, %s)", vectorExpr, mat2str(size(strs)));
  end
end
end

function out = rowData2sprintfArgs(widths, strs)
x = [num2cell(widths(:)) cellstr(strs(:))];
x = x';
out = x(:);
end

function out = alreadySupportsPrintf(obj)
persistent supportingClasses
if isempty(supportingClasses)
  supportingClasses = ["datetime" "duration" "calendarduration"];
end
out = ismember(class(obj), supportingClasses);
end


function out = dispstrsDatetime(x)
out = cell(size(x));
tfFinite = isfinite(x);
out(tfFinite) = cellstr(datestr(x(tfFinite)));
out(isnat(x)) = {'NaT'};
dnum = datenum(x);
out(isinf(dnum) & dnum > 0) = {'Inf'};
out(isinf(dnum) & dnum < 0) = {'-Inf'};
end

function out = dispstrsNumeric(x)
out = reshape(strtrim(cellstr(num2str(x(:)))), size(x));
end

function out = dispstrsLogical(x)
out = repmat("false", size(x));
out(x) = "true";
end

function out = dispstrsTabular(x)
out = cell(size(x));
for iRow = 1:size(x, 1)
  for iCol = 1:size(x, 2)
    val = x{iRow,iCol};
    if iscell(val)
      val = val{1};
    end
    out{iRow,iCol} = dispstr(val);
  end
end
end

function out = dispstrsGenericDisp(x)
out = cell(size(x));
for i = 1:numel(x)
  if iscell(x)
    xi = x{i}; %#ok<NASGU>
  else
    xi = x(i); %#ok<NASGU>
  end
  str = evalc('disp(xi)');
  str(end) = []; % chomp newline
  out{i} = str;
end
end


function out = size2str(sz)
%SIZE2STR Format an array size for display
%
% out = size2str(sz)
%
% Sz is an array of dimension sizes, in the format returned by SIZE.
%
% Examples:
%
% size2str(magic(3))
strs = cell(size(sz));
for i = 1:numel(sz)
  strs{i} = sprintf('%d', sz(i));
end
out = strjoin(strs, '-by-');
end
