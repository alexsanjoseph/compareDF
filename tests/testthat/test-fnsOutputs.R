
library(testthat)
library(dplyr)
library(compareDF)
library(stringr)

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


#===============================================================================
context("fnsOutputs: wide_output")
# Wide output
test_that("Wide output works for a single and multiple column", {
  ctable = compare_df(new_df, old_df, c("var1"))
  wide_output = create_wide_output(ctable)
  expected_wide_output = data.frame(
    var1 = c("B", "C"),
    var2_old = c("Y", "X"),
    var2_new = c("Y", "X"),
    val3_old = c(2, 3),
    val3_new = c(2.1, 4),
    val2_old = c("B1", "C1"),
    val2_new = c("B1", "C2"),
    val1_old = c(2, 3),
    val1_new = c(2, 3)
  )
  expect_equal(wide_output, expected_wide_output)

  ctable = compare_df(new_df, old_df, c("var1", "var2"))
  wide_output = create_wide_output(ctable)
  expected_wide_output = data.frame(
    grp = c(2, 3),
    var2_old = c("Y", "X"),
    var2_new = c("Y", "X"),
    var1_old = c("B", "C"),
    var1_new = c("B", "C"),
    val3_old = c(2, 3),
    val3_new = c(2.1, 4),
    val2_old = c("B1", "C1"),
    val2_new = c("B1", "C2"),
    val1_old = c(2, 3),
    val1_new = c(2, 3)
  )
  expect_equal(wide_output, expected_wide_output)
})


#===============================================================================
# HTML
#===============================================================================
# Limit
context("fnsOutputs: limit")
max_rows = 2
ctable = compare_df(new_df, old_df, c("var1", "var2"))

html_output = create_output_table(ctable, limit = max_rows)
expect_equal(html_output %>% as.character() %>% stringr::str_count("<tr style="), max_rows)

#===============================================================================
# Headers

get_html_header_names <- function(html_output){
  html_output_string = html_output %>% str_replace_all("\\n", "")

  (html_output_string %>%
    str_extract("thead.*thead") %>%
    str_extract_all("'>.+?<"))[[1]] %>%
    str_replace_all("'>(.*)<", "\\1")

}

context("fnsOutputs:  Headers")

test_that("compare_df: headers with 1 grouping column", {
  ctable = compare_df(new_df, old_df, c("var1"))
  html_headers = c(var1 = "Variable 1", var2 = "Variable 2", val1 = "Value 1", val2 = "Value 2", val3 = "Value 3")
  html_output = create_output_table(ctable, headers = html_headers)

  expected_headers = c("Variable 1", "chng_type", "Variable 2",
                       "Value 1", "Value 2", "Value 3")
  expect_equal(expected_headers, get_html_header_names(html_output))
})



test_that("compare_df: headers with partial matching", {
  ctable = compare_df(new_df, old_df, c("var1"))
  html_headers = c(var1 = "Variable 1", val1 = "Value 1", val3 = "Value 3")
  html_output = create_output_table(ctable, headers = html_headers)

  expected_headers = c("Variable 1", "chng_type", "var2",
                       "Value 1", "val2", "Value 3")
  expect_equal(expected_headers, get_html_header_names(html_output))
})

test_that("compare_df: headers with additional matching", {
  ctable = compare_df(new_df, old_df, c("var1"))
  html_headers = c(var1 = "Variable 1", var2 = "Variable 2", val1 = "Value 1", val2 = "Value 2", val4 = "Value 4")
  html_output = create_output_table(ctable, headers = html_headers)

  expected_headers = c("Variable 1", "chng_type", "Variable 2",
                       "Value 1", "Value 2", "val3")
  expect_equal(expected_headers, get_html_header_names(html_output))

})

test_that("compare_df: headers and group column and change column", {
  ctable = compare_df(new_df, old_df, c("var1"))
  html_headers = c(var1 = "Variable 1", var2 = "Variable 2", val1 = "Value 1", val2 = "Value 2", val3 = "Value 3")
  html_group_col_name = "Group ID"
  html_change_col_name = "Type of Change"
  html_output = create_output_table(ctable, headers = html_headers, group_col_name = html_group_col_name, change_col_name = html_change_col_name)

  expected_headers = c("Variable 1", "Type of Change", "Variable 2",
                       "Value 1", "Value 2", "Value 3")
  expect_equal(expected_headers, get_html_header_names(html_output))
})

test_that("compare_df: only group column and change column", {
  ctable = compare_df(new_df, old_df, c("var1"))
  html_group_col_name = "Group ID"
  html_change_col_name = "Type of Change"
  html_output = create_output_table(ctable, group_col_name = html_group_col_name, change_col_name = html_change_col_name)

  expected_headers = c("var1", "Type of Change", "var2",
                       "val1", "val2", "val3")
  expect_equal(expected_headers, get_html_header_names(html_output))


})

test_that("compare_df: headers with more than 1 grouping column and group column and change column", {

  ctable = compare_df(new_df, old_df,  c("var1", "var2"))
  html_group_col_name = "Group ID"
  html_change_col_name = "Type of Change"
  html_headers = c(var1 = "Variable 1", var2 = "Variable 2", val1 = "Value 1", val2 = "Value 2", val3 = "Value 3")
  html_output = create_output_table(ctable, headers = html_headers, group_col_name = html_group_col_name, change_col_name = html_change_col_name)

  expected_headers = c("Group ID", "Type of Change", "Variable 1", "Variable 2",
                       "Value 1", "Value 2", "Value 3")

  expect_equal(expected_headers, get_html_header_names(html_output))
})

test_that("compare_df: write output to file", {

  ctable = compare_df(new_df, old_df,  c("var1", "var2"))
  temp_file = tempfile()
  html_output = create_output_table(ctable, file_name = temp_file)
  expect_true(file.exists(temp_file))
  unlink(temp_file)
})


#===============================================================================
# XLSX
#===============================================================================

context("fnsOutputs: Output to Excel")

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

compare_output = compareDF::compare_df(old_df, new_df, c('var1', 'var2'))

test_that("compare_df: Error out if file name is NULL", {
  expect_error(create_output_table(compare_output, output_type = 'xlsx'), "file_name cannot be null if output format is xlsx")
})

test_that("compare_df: Write to file correctly", {
  temp_file = tempfile()
  create_output_table(compare_output, output_type = 'xlsx', file_name = temp_file)
  expect_true(file.exists(temp_file))
  unlink(temp_file)
})

# context("compare_df: Test Large output")
#
# old_df = data.frame(var1 = paste(1:12000, c("A"), sep = "_"),
#                     var2 = c("Z", "Y", "X"),
#                     val1 = c(1, 2, 3),
#                     val2 = c("A1", "B1", "C1"),
#                     val3 = c(1, 2, 3)
# )
#
# new_df = data.frame(var1 = paste(1:9000, c("A"), sep = "_"),
#                     var2 = c("Z", "Y", "X"),
#                     val1 = c(1, 5, 3),
#                     val2 = c("A1", "B1", "C2"),
#                     val3 = c(1, 2, 3)
# )
# big_output = compareDF::compare_df(old_df, new_df, c('var1', 'var2'))
# create_output_table(big_output, output_type = 'xlsx', file_name = "test_file.xlsx")

