
[![View dispstr on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/73960-dispstr)

The [Dispstr API](https://github.com/janklab/dispstr) is a Matlab API for extensible, polymorphic custom object display. This means it's an API you can code against to support generic display of user-defined objects and their data. It also supports using those custom displays when the objects are contained inside a complex type such as a `struct` or `table`.

## Motivation

Let's say you've got a class with a custom `disp` method.

```matlab
classdef Birthday1
    
    properties
        Month double
        Day double
    end
    
    methods
        function this = Birthday1(month, day)
            this.Month = month;
            this.Day = day;
        end

        function disp(this)
          fprintf('%s\n', datestr(datenum(1, this.Month, this.Day), 'mmm dd'));
        end
    end
    
end
```

This works great for displaying at the command window.

```text
>> b = Birthday1(10, 14)
b = 
Oct 14
```

But what if you stick it inside a struct or a cell?

```text
>> c = { 42 b }
c =
  1×2 cell array
    {[42]}    {1×1 Birthday1}
>> s.bday = b
s = 
  struct with fields:

    bday: [1×1 Birthday1]
```

Or if you want to use it with fprintf or sprintf?

```text
>> fprintf('My bday is %s\n', b)
My bday is Error using fprintf
Unable to convert 'Birthday1' value to 'char' or 'string'. 
```

Bummer!

Dispstr supplies an API that lets you overcome this. Have your class inherit from `dispstrlib.Displayable`, and override the `dispstr_scalar` method.

```matlab
classdef Birthday < dispstrlib.Displayable
    
    properties
        Month double
        Day double
    end
    
    methods
        function this = Birthday(month, day)
            this.Month = month;
            this.Day = day;
        end
    end
    
    methods (Access = protected)
        function out = dispstr_scalar(this)
            out = datestr(datenum(1, this.Month, this.Day), 'mmm dd');
        end
    end
    
end
```

Now it works! (As long as you call `dispd` to display cells, structs, or tables.)

```text
>> b = Birthday(10, 14)
b = 
Oct 14
>> dispd({ 42 b })
{42}   {Oct 14}
>> s.bday = b;
>> dispd(s)
    bday: 'Oct 14'
>> fprintf('My bday is %s\n', b)
My bday is Oct 14
```

And if you're brave, pull in the `Mcode-monkeypatch/` dir to your Matlab path, and it'll override Matlab's `disp` to do this automatically.

```text
>> addpath Mcode-monkeypatch
>> { 42 b }
c =
{42}   {Oct 14}
```

## A techier explanation

Matlab lacks a conventional method for polymorphic data display that works across (almost) all types, like Java's `toString()` does. This makes it hard to write generic code that can take arbitrary inputs and include a string representation of them in debugging data. It also means that custom classes don't display well when they're inside a `struct` or `table`.

Dispstr provides an API that includes a conventional set of functions/methods for doing polymorphic display, and a display method that respects them and supports Matlab's own composite types like `struct`, `table`, and `cell`.

This fixes Matlab output that looks like this:

```text
>> disp(tbl)
    Name       UserID          Birthday
    _______    ____________    ______________
    'Alice'    [1x1 UserID]    [1x1 Birthday]
    'Bob'      [1x1 UserID]    [1x1 Birthday]
    'Carol'    [1x1 UserID]    [1x1 Birthday]
```

to look more useful, like this:

```text
>> dispd(tbl)
    Name    UserID        Birthday
    _____   ___________   ________
    Alice   HR\alice      May 24  
    Bob     Sales\bob     Dec 14  
    Carol   Sales\carol   Apr 20  
```

There's not a whole lot of code in this library. I think the major value in it is in establishing the function convention and signatures, not in the implementation code itself.

## Functions

There are three main levels or styles of representation in the Dispstr API:

* `dispstr`/`dispstrs` – Human-readable, user-oriented display of the _meaning_ or _appearance_ of values in an array.
* `reprstr`/`reprstrs` – Human-readable, developer-oriented display of the _format_ or internal representation of values in an array.
* `mat2str`/`mat2str2` – Matlab-readable representation containing M-code that reconstructs the original array (or something close to it) when passed to `eval()`.

### `dispstr` and `dispstrs`

`dispstr` and `dispstrs` are polymorphic functions that can display a concise, human-readable summary of any input data. Their implementation in the API is as global functions that have support for Matlab's built-in data types, and generic display formats for user-defined objects. User-defined classes can define `dispstr` and `dispstrs` methods to override them and provide customized displays.

`dispstr` produces a single string that describes an entire array.

`dispstrs` produces a string for each element in an array, that describes that particular element's value or contents.

These values are suitable for use in user interfaces, presentation to end users, casual display at the command prompt, and the like.

### `reprstr` and `reprstrs`

`reprstr` and `reprstrs` are like `dispstr` and `dispstrs`, but display a lower-level, more developer-oriented representation of values. These are suitable for use in debugging contexts, like object dumps, log files, debugging and code inspection tools, and so on.

### `mat2str2`

`mat2str2` is an extension of Matlab's `mat2str` that works on additional types and sizes of arrays. It adds support for n-dimensional arrays, `cell` arrays, and `struct` arrays, and respects classes that provide `mat2str` overrides.

### `sprintfd`, `fprintfd`, `errord`, and `warningd`

`sprintfd` and `fprintfd` are variants of `sprintf` and `fprintf` that respect dispstr() methods defined on their arguments, so you can pass objects to '%s' conversion specifiers and get nice output.

Similarly, `errord` and `warningd` are variants of Matlab’s `error` and `warning` that support dispstr functionality, so you can pass objects to their `%s` conversion specifiers, too.

### `prettyprint` and `pp`

`prettyprint` is a function that produces a verbose, multi-line, formatted output describing an object's contents. The main implementation can handle Matlab built-in types, `struct`s, and `table`s, respecting the custom `dispstr` implementations of objects inside those structs and tables.

Classes can implement their own `prettyprint` methods to customize their own display. This is typically only needed for classes that implement complex, hierarchical structures like tabular objects, trees, and whatnot.

`pp` is a command wrapper around `prettyprint` for interactive use. It does the same thing as `prettyprint`, except that it also accepts variable names as `char` for its input.

### `dispstrlib.Displayable`

`dispstrlib.Displayable` is a mixin class that makes it easier for you to write classes that use dispstr and dispstrs. All you have to do is inherit from it or `dispstrlib.DisplayableHandle` and override `dispstr_scalar`.

## Usage

Get the Dispstr library on your path, and then define `dispstr()` and `dispstrs()` methods on your classes. Have their `disp()` methods use `dispstr()`. Or, for convenience, have them inherit from `dispstrlib.Displayable` and just define `dispstrs()` on them.

Use `dispd` to display tables. Use `fprintfd` and `sprintfd` instead of `fprintf` and `sprintf` for string output.

If you're brave, and your code is an application instead of a library, or you're using Matlab interactively, add `Mcode-monkeypatch` to your path too, to override Matlab's own `disp`, `fprintf`, and `sprintf` to support dispstr. (It's a risky move, but having that work is really nice, so consider doing it. And go ahead and turn off `warning off MATLAB:dispatcher:nameConflict`.)

See the documentation [on the web](http://dispstr.janklab.net) or in `docs/` in the distribution for details.

## License

BSD 2-Clause License. Share and enjoy.

## Author

dispstr was written by [Andrew Janke](https://apjanke.net).

The project home page is the [GitHub repo page](https://github.com/janklab/dispstr). Bug reports and feature requests are welcome. Documentation can be found at [the website](https://dispstr.janklab.net).

dispstr is part of the [Janklab](https://janklab.net) suite of libraries for Matlab.

## More documentation

* [User's Guide](User-Guide.html)
* [Developer Notes](Developer-Notes.html)
* [Changelog](CHANGES.html)
