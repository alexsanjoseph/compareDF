
library(testthat)

data("results_2010", "results_2011")

#===============================================================================
context("Basic Comparison")

ctable = compare_df(results_2011, results_2010, c("Student"), exclude = "Discipline")

ctable$html_output
