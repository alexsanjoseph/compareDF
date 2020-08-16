## Resubmission
This is a new version. In this version I have:

* internals now use data.table making the comparison MUCH faster!
* convert output to wide format using `create_wide_output`
* customize nomenclature of the chng_type using `change_markers`

## Test environments
*  local OS X install - 10.14, R 3.5.1
*  ubuntu 16.04 (on travis-ci)
*  Windows (on Appveyor)
*  Ubuntu Linux 16.04 LTS, R-release, GCC (Rhub)
*  Fedora Linux, R-devel, clang, gfortran (Rhub)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are no reverse dependencies.
