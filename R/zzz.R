.onLoad <- function(libname, pkgname) {
  options(stringsAsFactors = FALSE)
  data.table::setNumericRounding(0L)
}
