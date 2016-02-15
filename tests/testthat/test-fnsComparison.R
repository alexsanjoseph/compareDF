
library(testthat)

old_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 3))

new_df = data.frame(var1 = c("A", "B", "C"),
                    val1 = c(1, 2, 4))

context("compare_df_function")
#===============================================================================
# basic tests
ctable = compare_df(new_df, old_df, c("var1"))

expected_comparison_df = data.frame(var1 = ("C"), chng_type = c("+", "-"), val1 = c(4,3))
expect_equal(expected_comparison_df, ctable$comparison_df)

#===============================================================================
# Test for sameness

# Error if chng_type is used

# Test for sameness after exclusion

# Table

# Multiple Gourping

# Exclude

# Limit


#===============================================================================

#limit warning

