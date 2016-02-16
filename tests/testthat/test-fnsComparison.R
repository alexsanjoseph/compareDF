
library(testthat)
library(dplyr)
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
                    val3 = c(1, 2, 4)
)

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



# Table

# Multiple Gourping

# Exclude

# Limit


#===============================================================================

#limit warning

