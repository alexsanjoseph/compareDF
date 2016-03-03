
library(testthat)
library(dplyr)
library(compareDF)
old_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 3))

new_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 4))

context("compare_df_function")
#===============================================================================
# basic tests
ctable = compare_df(new_df, old_df, c("var1"))
expected_comparison_df = data.frame(var1 = ("C"), chng_type = c("+", "-"), val1 = c(4,3))
expect_equal(expected_comparison_df[1,3], ctable$comparison_df[1,3])

#===============================================================================
# Testing errors and warnings
# Test for sameness
expect_error(compare_df(new_df, new_df),
             "The two data frames are the same")

# Test for sameness after exclusion
expect_error(compare_df(new_df, new_df),
             "The two data frames are the same")

# Test for different structure
expect_error(compare_df(new_df %>% rename(val2 = val1), new_df, "var1"),
             "The two data frames have different columns!")

# Error if chng_type is used
expect_error(compare_df(new_df %>% rename(chng_type = var1),
                        old_df %>% rename(chng_type = var1), "chng_type"),
             "chng_type is a reserved keyword!")

# Error if group_col is not in the data.frames
expect_error(compare_df(new_df, old_df, group_col = c("var1, var3")),
             "Grouping column\\(s\\) not found in the data.frames")

#===============================================================================
# Let's get more complicated
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
ctable$comparison_table_diff

#===============================================================================
# Multiple Grouping / Exclude
ctable = compare_df(new_df, old_df, c("var1", "var2"), exclude = "val3")
expected_comparison_df = data.frame(grp = c(3, 4),
                                    chng_type = c("+", "-"),
                                    var1 = c("C", "C"),
                                    var2 = c("W", "X"),
                                    val1 = c(3,3),
                                    val2 = c("C2", "C1")) #%>%
  # arrange(desc(chng_type)) %>% arrange_("var1")
expect_equal(ctable$comparison_df, expected_comparison_df)

#===============================================================================
# Limit
library("stringr")
max_rows = 2
ctable = compare_df(new_df, old_df, c("var1", "var2"), limit_html = max_rows)
expect_equal(ctable$html_output %>% as.character() %>% str_count("<tr style="), max_rows)


#===============================================================================
# Other stats
change_summary_expected = c(old_obs = 3, new_obs = 3, changes = 1, additions = 1, removals = 1)
comparison_table_expected = data.frame(grp = c(".", ".", "+", "-"),
                                       chng_type = c("+", "-", "+", "-"),
                                       var1 = c(".", ".", "+", "-"),
                                       var2 = c(".", ".", "+", "-"),
                                       val1 = c(".", ".", "+", "-"),
                                       val2 = c(".", ".", "+", "-"),
                                       val3 = c("+", "-", "+", "-")
                                       )
change_summary_expected = c(old_obs = 3, new_obs = 3, changes = 1, additions = 1, removals = 1)

expect_equal(ctable$change_summary, change_summary_expected)
expect_equal(ctable$comparison_table_diff, comparison_table_expected)

#===============================================================================
# Tolerance
ctable = compare_df(new_df, old_df, c("var1", "var2"), tolerance = 0.5)
expected_comparison_df = data.frame(grp = c(3, 4),
                                    chng_type = c("+", "-"),
                                    var1 = c("C", "C"),
                                    var2 = c("W", "X"),
                                    val1 = c(3,3),
                                    val2 = c("C2", "C1"),
                                    val3 = c(4.0, 3.0))
expect_equal(ctable$comparison_df, expected_comparison_df)

#===============================================================================
# For later: Two types of tolerance
