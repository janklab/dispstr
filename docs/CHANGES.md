Changelog for Dispstr
======================

Version 1.2.0+ (in progress)
--------------------------

Nothing yet!

Version 1.2.0 (2021-09-14)
--------------------------

* Add "repr" variants of functions.
* Add `mat2str2`.
* Add dispstrlib.disp().
* Refactor to a single-class core implementation, to facilitate making compatters.
* Fix col-width issue in matrix display.
* Fix array display for ndims > 3.

Version 1.1.1 (2020-01-30)
--------------------------

* Fix a bug with orientation of numeric arrays in dispstr.

Version 1.1 (2020-01-29)
------------------------

* Use strings instead of cellstrs.
* Add errords() and warningds().
* Fix interpolation of scalar string array arguments in printf functions.
* Add printf/error/warning support to Displayable.
* Add DisplayableHandle.
* Remove dispstrable, superseded by Displayable.

Version 1.0 (2020-01-18)
----------------------

* Initial implementation.
