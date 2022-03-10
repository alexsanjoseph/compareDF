## compareDF 2.3.3
* Changed deprecated `_gather` to `pivot_longer` (thanks to `olivroy`!)
* Fixed a bug where `compare_df` would mutate the global data to data.table

## compareDF 2.3.2
* Fixed an edge case with `keep_unchanged_rows`
* Removed naked `stringsAsFactors` from tests into data.frame creation function.

## compareDF 2.3.1
* prevented the `compareDF` function from mangling non-standard column names in input dataframes (thanks to `lcougnaud`!).

## compareDF 2.3.0
* internals now use data.table making the comparison MUCH faster!
* convert output to wide format using `create_wide_output`
* customize nomenclature of the chng_type using `change_markers`

## compareDF 2.2.0
* Fixed a bug where the package would corrupt the global environment with `stringsAsFactors=FALSE`
* Added `futile.logger` as a potential option for logging messages.

## compareDF 2.1.0
* Added defaults if no `group_col` is given

## compareDF 2.0.2
* Fixed test for dplyr 1.0

## compareDF 2.0.1
* Fixed bugs in XLSX output

## compareDF 2.0.0
* New Major Version! Contains some breaking changes
* Support for `XLSX` format
* Write output to file directly
* Separate functions to compare output and create output tables
* Cleaner abstractions in functions
* More bugs squashed
* Color blind friendly default colors

## compareDF 1.8.0
* Added new option to keep only the columns which have changed using `keep_unchanged_cols`. 
* changed option `keep_unchanged` to `keep_unchanged_rows`

## compareDF 1.7.3
* Fixed tests to work with dplyr 0.8.2 and on Linux systems

## compareDF 1.7.2
* Fixed tests to work with dplyr 0.8.1

## compareDF 1.7.1
* Fixed tests to work with dplyr 0.8.0

## compareDF 1.7.0
* Provided options to name the columns in the HTML output
* Provided option change column name
* Provided option to change group column name

## compareDF 1.6.0
* Added option to specify different types of tolerances. Now you can use `difference` as an argument to use difference rather than ratio
* Fixed some bugs
* Lot more tests

## compareDF 1.5.0
* Added an option to preserve the rows that have not changed in the analysis using the `keep_unchanged_rows` argument
* Added an option to set the color scheme in the HTML using the `color_scheme` argument.
* Updated Documentation
* Fixed some bugs
* Fixed dependencies

## compareDF 1.3.1
* added a test dependency(stringr) as notified by CRAN

## compareDF 1.3.0
* added an option to ignore errors `stop_on_error`

## compareDF 1.2.0
* Fixed bugs
* view_html function to view the html file created for setups that cannot print html directly

## compareDF 1.1.2
* compareDF can now handle negative inputs correctly

## compareDF 1.1.1
* Fixed some bugs when the two frames are similar except reordering

## compareDF 1.1.0
* Fixed some bugs

## compareDF 1.0.0

* First Release!
