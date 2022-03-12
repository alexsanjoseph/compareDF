# CRAN Comments

## Resubmission

This is a resubmission of new version. In this version I have:

* Changed deprecated `_gather` to `pivot_longer` (thanks to `olivroy`!)
* Fixed a bug where `compare_df` would mutate the global data to data.table
* Removed all examples from the code because CRAN server can't handle it

## Test environments

*  Mac OS X Monterey install - 12.2.1, R 4.1.1 (Local)
*  Ubuntu 16.04 (on travis-ci)
*  Ubuntu 18.04 - Docker, R 3.6.3 (Github Actions)
*  Windows - Latest (on Github Actions)
*  MacOS - Latest (on Github Actions)
*  Ubuntu Linux 20.04.1 LTS, R-release, GCC (Rhub)
*  Fedora Linux, R-devel, clang, gfortran (Rhub)
*  Windows Server 2008 R2 SP1, R-devel, 32/64 bit (Rhub)
*  Windows (on Appveyor)

## R CMD check results

0 errors | 0 warnings | 0 notes


## Reverse dependencies

There are no reverse dependencies.
