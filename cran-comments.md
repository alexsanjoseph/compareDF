# CRAN Comments

## Resubmission

This is a new version. In this version I have:

* internals now use data.table making the comparison MUCH faster!
* convert output to wide format using `create_wide_output`
* customize nomenclature of the chng_type using `change_markers`

## Test environments

*  Mac OS X Catalina install - 10.15.6, R 3.6.3 (Local)
*  Ubuntu 16.04 (on travis-ci)
*  Ubuntu 18.04 - Docker, R 3.6.3 (Github Acions)
*  Ubuntu Linux 16.04 LTS, R-release, GCC (Rhub)
*  Fedora Linux, R-devel, clang, gfortran (Rhub)
*  Windows Server 2008 R2 SP1, R-devel, 32/64 bit (Rhub)
*  Windows (on Appveyor)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are no reverse dependencies.
