#' @importFrom utils head
create_html_table <- function(comparison_output, file_name, limit_html, color_scheme, headers_all){

  comparison_table_diff = comparison_output$comparison_table_diff
  comparison_table_ts2char = comparison_output$comparison_table_ts2char
  group_col = comparison_output$group_col

  if(limit_html > 1000 & comparison_table_diff %>% nrow > 1000)
    warning("Creating HTML diff for a large dataset (>1000 rows) could take a long time!")

  if(limit_html < nrow(comparison_table_diff))
    message("Truncating HTML diff table to ", limit_html, " rows...")

  requireNamespace("htmlTable")
  comparison_table_color_code  = comparison_table_diff %>% do(.colour_coding_df(., color_scheme)) %>% as.data.frame

  shading = ifelse(sequence_order_vector(comparison_table_ts2char[[group_col]]) %% 2, "#dedede", "white")

  table_css = lapply(comparison_table_color_code, function(x)
    paste0("padding: .2em; color: ", x, ";")) %>% data.frame %>% head(limit_html) %>% as.matrix()

  colnames(comparison_table_ts2char) <- headers_all

  message("Creating HTML table for first ", limit_html, " rows")
  html_table = htmlTable::htmlTable(comparison_table_ts2char %>% head(limit_html),
                                    col.rgroup = shading,
                                    rnames = F, css.cell = table_css,
                                    padding.rgroup = rep("5em", length(shading))
  )
}



create_xlsx_document <- function(comparison_output, file_name, limit, color_scheme, headers_all){
  comparison_table_diff = comparison_output$comparison_table_diff
  comparison_table_ts2char = comparison_output$comparison_table_ts2char
  group_col = comparison_output$group_col

  requireNamespace("openxlsx")
  browser()
  comparison_table_color_code  = comparison_table_diff %>% do(.colour_coding_df(., color_scheme)) %>% as.data.frame

  shading = ifelse(sequence_order_vector(comparison_table_ts2char[[group_col]]) %% 2, "#dedede", "white")

  table_css = lapply(comparison_table_color_code, function(x)
    paste0("padding: .2em; color: ", x, ";")) %>% data.frame %>% head(limit_html) %>% as.matrix()

  colnames(comparison_table_ts2char) <- headers_all

  message("Creating HTML table for first ", limit_html, " rows")
  html_table = htmlTable::htmlTable(comparison_table_ts2char %>% head(limit_html),
                                    col.rgroup = shading,
                                    rnames = F, css.cell = table_css,
                                    padding.rgroup = rep("5em", length(shading))
  )
}

# nocov start
#' @title View Comparison output HTML
#'
#' @description Some versions of Rstudio doesn't automatically show the html pane for the html output. This is a workaround
#'
#' @param comparison_output output from the comparisonDF compare function
#' @export
#' @examples
#' old_df = data.frame(var1 = c("A", "B", "C"),
#'                     val1 = c(1, 2, 3))
#' new_df = data.frame(var1 = c("A", "B", "C"),
#'                     val1 = c(1, 2, 4))
#' ctable = compare_df(new_df, old_df, c("var1"))
#' # Not Run::
#' # view_html(ctable)
view_html <- function(comparison_output){
  temp_dir = tempdir()
  temp_file <- paste0(temp_dir, "/temp.html")
  cat(comparison_output$html_output, file = temp_file)
  getOption("viewer")(temp_file)
  unlink("temp.html")
}
# nocov end
