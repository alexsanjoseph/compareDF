
library(testthat)
library(dplyr)
library(compareDF)
library(stringr)
old_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 3))

new_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 4))

context("compare_df: basic tests")
#===============================================================================

ctable = compare_df(new_df, old_df, c("var1"))
expected_comparison_df = data.frame(var1 = ("C"), chng_type = c("+", "-"), val1 = c(4,3))
expect_equal(expected_comparison_df[1,3], ctable$comparison_df[1,3])

df1 <- data.frame(a = 1:5, b=letters[1:5], row = 1:5)
df2 <- data.frame(a = 1:3, b=letters[1:3], row = 1:3)

df_compare = compare_df(df1, df2, "row")
expected_df = data.frame(row = c(4, 5), chng_type = "+", a = c(4, 5), b = c("d", "e"))
expect_equal(df_compare$comparison_df, expected_df)

#===============================================================================
# Case when there are only new rows
new_df = data.frame(var1 = c("A", "B"), val1 = c(1, 2))
ctable = compare_df(new_df, old_df, c("var1"), tolerance = 0.5)

expected_comparison_df = data.frame(var1 = c('C'), chng_type = c("-"), val1 = c(3))
expect_equal(ctable$comparison_df, expected_comparison_df)

#===============================================================================
# Case when there are only new rows
old_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 3))
new_df = data.frame(var1 = c("A", "B"), val1 = c(1, 2))
ctable = compare_df(new_df, old_df, c("var1"), tolerance = 0.5)

expected_comparison_df = data.frame(var1 = c('C'), chng_type = c("-"), val1 = c(3))
expect_equal(ctable$comparison_df, expected_comparison_df)

#===============================================================================
# Case when the column order is different
old_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 3))
new_df = data.frame(val1 = c(1, 2), var1 = c("A", "B"))
ctable = compare_df(new_df, old_df, c("var1"), tolerance = 0.5)

expected_comparison_df = data.frame(var1 = c('C'), chng_type = c("-"), val1 = c(3))
expect_equal(ctable$comparison_df, expected_comparison_df)

#===============================================================================
# Case when the row order is different
old_df = data.frame(var1 = c("A", "C", "B"), val1 = c(1, 3, 2))
new_df = data.frame(var1 = c("A", "B", "C"), val1 = c(1, 2, 3))
expect_error(compare_df(new_df, old_df, c("var1"), tolerance = 0.5), "The two dataframes are similar after reordering")

#===============================================================================
context("compare_df: check warning output")
old_df = data.frame(var1 = c("A", "C", "B"), val1 = c(1, 3, 2))
new_df = data.frame(var1 = c("A", "B", "C"), val1 = c(1, 2, 3))
expected_comparison_df = data.frame(var1 = character(), val1 = numeric(), chng_type = numeric())
expected_comparison_table_diff = data.frame(var1 = numeric(), val1 = numeric(), chng_type = numeric())
expected_change_count = data.frame(var1 = character(), changes = numeric(), additions = numeric(), removals = numeric())
expected_change_summary = c(old_obs = 3, new_obs = 3, changes = 0, additions = 0, removals = 0)

output = expect_warning(compare_df(new_df, old_df, c("var1"), tolerance = 0.5, stop_on_error = F),
                        "The two dataframes are similar after reordering")
expect_equal(output$comparison_df, expected_comparison_df)
expect_null(output$html_output, expected_comparison_df)
expect_equivalent(output$comparison_table_diff, expected_comparison_table_diff)
expect_equivalent(output$change_count, expected_change_count)
expect_equivalent(output$change_summary, expected_change_summary)

#===============================================================================
context("compare_df: errors and warnings")

# Case when the row order is different after unique
old_df = data.frame(var1 = c("A", "C", "B", "C"), val1 = c(1, 3, 2, 3))
new_df = data.frame(var1 = c("A", "B", "C"), val1 = c(1, 2, 3))
expect_error(compare_df(new_df, old_df, c("var1"), tolerance = 0.5), "The two dataframes are similar after reordering and doing unique")
expect_warning(compare_df(new_df, old_df, c("var1"), tolerance = 0.5, stop_on_error = F),
               "The two dataframes are similar after reordering and doing unique")

# Test for sameness
expect_error(compare_df(new_df, new_df, "var1"), "The two data frames are the same")
expect_warning(compare_df(new_df, new_df, "var1", stop_on_error = F), "The two data frames are the same")

# Test for sameness after exclusion
expect_error(compare_df(new_df, new_df, "var1"),
             "The two data frames are the same")
expect_warning(compare_df(new_df, new_df, "var1", stop_on_error = F),
             "The two data frames are the same")

# Test for different structure
expect_error(compare_df(new_df %>% rename(val2 = val1), new_df, "var1"),
             "The two data frames have different columns!")
expect_error(compare_df(new_df %>% rename(val2 = val1), new_df, "var1", stop_on_error = F),
             "The two data frames have different columns!")

# Error if chng_type is used
expect_error(compare_df(new_df %>% rename(chng_type = var1), old_df %>% rename(chng_type = var1), "chng_type"),
             "chng_type, X1, X2) are reserved keywords!")
expect_error(compare_df(new_df %>% rename(X1 = var1), old_df %>% rename(X1 = var1), "chng_type"),
             "chng_type, X1, X2) are reserved keywords!")
expect_error(compare_df(new_df %>% rename(X2 = var1), old_df %>% rename(X2 = var1), "chng_type"),
             "chng_type, X1, X2) are reserved keywords!")

# Error if group_col is not in the data.frames
expect_error(compare_df(new_df, old_df, group_col = c("var1, var3")),
             "Grouping column\\(s\\) not found in the data.frames")

#===============================================================================
context("compare_df: change count")
old_df = data.frame(var1 = c("A", "B", "C"),
                    var2 = c("Z", "Y", "X"),
                    val1 = c(1, 2, 3),
                    val2 = c("A1", "B1", "C1"),
                    val3 = c(1, 2, 3)
)

new_df = data.frame(var1 = c("A", "B", "C"),
                    var2 = c("Z", "Y", "W"),
                    val1 = c(1, 2, 3),
                    val2 = c("A1", "B1", "C2"),
                    val3 = c(1, 2.1, 4)
)
ctable = compare_df(new_df, old_df, c("var1", "var2"))

# Table
#===============================================================================
# Change Count
expected_change_count_df = data.frame( grp = c(2, 3, 4),
                                       changes = c(1, 0, 0),
                                       additions = c(0, 1, 0),
                                       removals = c(0, 0, 1) )
expect_equal(ctable$change_count, expected_change_count_df)

#===============================================================================
context("compare_df: Multiple Grouping / Exclude")
ctable = compare_df(new_df, old_df, c("var1", "var2"), exclude = "val3")
expected_comparison_df = data.frame(grp = c(3, 4),
                                    chng_type = c("+", "-"),
                                    var1 = c("C", "C"),
                                    var2 = c("W", "X"),
                                    val1 = c(3,3),
                                    val2 = c("C2", "C1")) #%>%
  # arrange(desc(chng_type)) %>% arrange_("var1")
expect_equivalent(ctable$comparison_df, expected_comparison_df)

#===============================================================================
context("compare_df: Other stats")
ctable = compare_df(new_df, old_df, c("var1", "var2"))
change_summary_expected = c(old_obs = 3, new_obs = 3, changes = 1, additions = 1, removals = 1)
comparison_table_expected = data.frame(grp = c("=", "=", "+", "-"),
                                       chng_type = c("+", "-", "+", "-"),
                                       var1 = c("=", "=", "+", "-"),
                                       var2 = c("=", "=", "+", "-"),
                                       val1 = c("=", "=", "+", "-"),
                                       val2 = c("=", "=", "+", "-"),
                                       val3 = c("+", "-", "+", "-")
                                       )
change_summary_expected = c(old_obs = 3, new_obs = 3, changes = 1, additions = 1, removals = 1)

expect_equivalent(ctable$change_summary, change_summary_expected)
expect_equivalent(ctable$comparison_table_diff, comparison_table_expected)

#===============================================================================
context("compare_df: tolerance")
ctable = compare_df(new_df, old_df, c("var1", "var2"), tolerance = 0.06)
expected_comparison_df = data.frame(grp = c(3, 4),
                                    chng_type = c("+", "-"),
                                    var1 = c("C", "C"),
                                    var2 = c("W", "X"),
                                    val1 = c(3, 3),
                                    val2 = c("C2", "C1"),
                                    val3 = c(4.0, 3.0))
expect_equivalent(ctable$comparison_df, expected_comparison_df)

context("compare_df: tolerance with compare_type = 'difference'")
ctable = compare_df(new_df, old_df, c("var1", "var2"), tolerance = 0.06, tolerance_type = 'difference')
expected_comparison_df = data.frame(grp = c(2, 2, 3, 4),
                                    chng_type = c("+", "-", "+", "-"),
                                    var1 = c("B", "B", "C", "C"),
                                    var2 = c("Y", "Y", "W", "X"),
                                    val1 = c(2, 2, 3, 3),
                                    val2 = c("B1", "B1", "C2", "C1"),
                                    val3 = c(2.1, 2.0, 4.0, 3.0))
expect_equivalent(ctable$comparison_df, expected_comparison_df)

expect_error(compare_df(new_df, old_df, c("var1", "var2"), tolerance = 0.06, tolerance_type = 'random'), "Unknown tolerance type")
# Error
expect_error(compare_df(new_df %>% head(2), old_df %>% head(2), c("var1", "var2"), tolerance = 1))

#===========================
context("compare_df: negative numbers")
old_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 3))

new_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, -3))

ctable = compare_df(new_df, old_df, c("var1"))
expected_comparison_df = data.frame(var1 = ("C"), chng_type = c("+", "-"), val1 = c(-3,3))
expect_equivalent(expected_comparison_df, ctable$comparison_df)

#===========================
context("compare_df: Extremely small values - compare rounding parameter")
old_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(0.0001, 2e-5, 3))

new_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(0.00011, 2e-5, 5))

ctable = compare_df(new_df, old_df, c("var1"), round_output_to = 10)
expected_comparison_df = data.frame(var1 = c("A", "A", "C", "C"), chng_type = c("+", "-"), val1 = c(0.00011,0.00010, 5, 3))
expect_equivalent(expected_comparison_df, ctable$comparison_df)

#===============================================================================

context("compare_df: keep_unchanged_rows")
old_df = data.frame(var1 = c("A", "B", "C"),
                    var2 = c("Z", "Y", "X"),
                    val1 = c(1, 2, 3),
                    val2 = c("A1", "B1", "C1"),
                    val3 = c(1, 2, 3)
)

new_df = data.frame(var1 = c("A", "B", "C"),
                    var2 = c("Z", "Y", "W"),
                    val1 = c(1, 2, 3),
                    val2 = c("A1", "B1", "C2"),
                    val3 = c(1, 2.1, 4)
)

ctable = compare_df(new_df, old_df, c("var1", "var2"), keep_unchanged_rows = T)
expected_comparison_df = data.frame(grp = c(1, 1, 2, 2, 3, 4),
                                   chng_type = c("=", "=", "+", "-", "+", "-"),
                                   var1 = c("A", "A", "B", "B", "C", "C"),
                                   var2 = c("Z", "Z", "Y", "Y", "W", "X"),
                                   val1 = c(1, 1, 2, 2, 3, 3),
                                   val2 = c("A1", "A1", "B1", "B1", "C2", "C1"),
                                   val3 = c(1, 1, 2.1, 2, 4, 3) )

expected_comparison_table_diff = data.frame(grp = c("=", "=", "=", "=", "+", "-"),
                                            chng_type = c("=", "=", "+", "-", "+", "-"),
                                            var1 = c("=", "=", "=", "=", "+", "-"),
                                            var2 = c("=", "=", "=", "=", "+", "-"),
                                            val1 = c("=", "=", "=", "=", "+", "-"),
                                            val2 = c("=", "=", "=", "=", "+", "-"),
                                            val3 = c("=", "=", "+", "-", "+", "-") )
expected_change_count = data.frame(grp = c(1, 2, 3, 4),
                                   changes = c(0, 1, 0, 0),
                                   additions = c(0, 0, 1, 0),
                                   removals = c(0, 0, 0, 1) )
expected_change_summary = data.frame(old_obs = 3,
                                     new_obs = 3,
                                     changes = 1,
                                     additions = 1,
                                     removals = 1 )
expect_equivalent(expected_comparison_df, ctable$comparison_df)
expect_equivalent(expected_comparison_table_diff, ctable$comparison_table_diff)
expect_equivalent(expected_change_summary, ctable$change_summary)
expect_equivalent(expected_change_count, ctable$change_count)

#===============================================================================

context("compare_df: keep_unchanged_cols")
old_df = data.frame(var1 = c("A", "B", "C"),
                    var2 = c("Z", "Y", "X"),
                    val1 = c(1, 2, 3),
                    val2 = c("A1", "B1", "C1"),
                    val3 = c(1, 2, 3)
)

new_df = data.frame(var1 = c("A", "B", "C"),
                    var2 = c("Z", "Y", "X"),
                    val1 = c(1, 2, 3),
                    val2 = c("A1", "B1", "C2"),
                    val3 = c(1, 2.1, 4)
)

ctable = compare_df(new_df, old_df, c("var1", "var2"), keep_unchanged_rows = T, keep_unchanged_cols = F)
expected_comparison_df = data.frame(grp = c(1, 1, 2, 2, 3, 3),
                                   chng_type = c("=", "=", "+", "-", "+", "-"),
                                   val2 = c("A1", "A1", "B1", "B1", "C2", "C1"),
                                   val3 = c(1, 1, 2.1, 2, 4, 3))

expected_comparison_table_diff = data.frame(grp = c("=", "=", "=", "=", "=", "="),
                                            chng_type = c("=", "=", "+", "-", "+", "-"),
                                            val2 = c("=", "=", "=", "=", "+", "-"),
                                            val3 = c("=", "=", "+", "-", "+", "-"))

expected_change_count = data.frame(grp = c(1, 2, 3),
                                   changes = c(0, 1, 1),
                                   additions = c(0, 0, 0),
                                   removals = c(0, 0, 0))

expected_change_summary = data.frame(old_obs = 3,
                                     new_obs = 3,
                                     changes = 2,
                                     additions = 0,
                                     removals = 0)

expect_equivalent(expected_comparison_df, ctable$comparison_df)
expect_equivalent(expected_comparison_table_diff, ctable$comparison_table_diff)
expect_equivalent(expected_change_summary, ctable$change_summary)
expect_equivalent(expected_change_count, ctable$change_count)

#===============================================================================

context("compare_df: Integration Edge case")
test_that("compare_df: Some integration edge case", {

  df_old = data.frame(a = c(1), b = c(1))
  df_new = data.frame(a = numeric(0), b = numeric(0))

  actual_comparison_summary = compare_df(df_new = df_new, df_old = df_old, group_col = c("a"))

  expected_comparison_df = data.frame(a = 1, chng_type = "-", b = 1)
  expected_comparison_table_diff = data.frame(a = "-", chng_type = "-", b = "-")
  expected_change_count = structure(list(a = 1, changes = 0, additions = 0, removals = 1),
                                    .Names = c("a", "changes", "additions", "removals"),
                                    class = c("tbl_df", "tbl", "data.frame"), row.names = c(NA, -1L))
  expected_change_summary = setNames(c(1, 0, 0, 0, 1), c("old_obs", "new_obs", "changes", "additions", "removals"))

  expect_equivalent(expected_comparison_df, actual_comparison_summary$comparison_df)
  expect_equivalent(expected_comparison_table_diff, actual_comparison_summary$comparison_table_diff)
  #expect_equivalent(expected_change_count, actual_comparison_summary$change_count) # Might bring in back later if needed
  expect_equivalent(expected_change_summary, actual_comparison_summary$change_summary)
})

