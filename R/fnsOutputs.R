
#' @title Create human readable output from the comparison_df output
#'
#' @description Currently `html` and `xlsx` are supported
#'
#' @param comparison_output Output from the comparison Table functions
#' @param output_type Type of comparison output. Defaults to `html`
#' @param file_name Where to write the output to. Default to NULL which output to the Rstudio viewer (not supported for `xlsx`)
#' @param limit maximum number of rows to show in the diff. >1000 not recommended for HTML
#' @param color_scheme What color scheme to use for the  output. Should be a vector/list with
#'  named_elements. Default - \code{c("addition" = "green", "removal" = "red", "unchanged_cell" = "gray", "unchanged_row" = "deepskyblue")}
#' @param headers A character vector of column names to be used in the table. Defaults to \code{colnames}.
#' @param change_col_name Name of the change column to use in the table. Defaults to \code{chng_type}.
#' @param group_col_name Name of the group column to be used in the table (if there are multiple grouping vars). Defaults to \code{grp}.
#' @export
create_output_table <- function(comparison_output, output_type = 'html', file_name = NULL, limit = 100,
                                color_scheme = c("addition" = "#52854C", "removal" = "#FC4E07",
                                                 "unchanged_cell" = "#999999", "unchanged_row" = "#293352"),
                                headers = NULL, change_col_name = "chng_type", group_col_name = "grp"){
  headers_all = get_headers_for_table(headers, change_col_name, group_col_name, comparison_output$comparison_table_diff)

  comparison_output$comparison_table_ts2char$chng_type = comparison_output$comparison_table_ts2char$chng_type %>%
    replace_numbers_with_change_markers(comparison_output$change_markers)

  if (limit == 0 || nrow(comparison_output$comparison_table_diff) == 0 || nrow(comparison_output$comparison_df) == 0)
    return(NULL)
  output = switch(output_type,
                  'html' = create_html_table(comparison_output, file_name, limit, color_scheme, headers_all),
                  'xlsx' = create_xlsx_document(comparison_output, file_name, limit, color_scheme, headers_all)
  )
  output
}

message_compareDF <- function(msg){
  if ("futile.logger" %in% rownames(utils::installed.packages())) {
    futile.logger::flog.trace(stringr::str_interp(msg, env = parent.frame()))
  } else {
    message(msg)
  }
}

#' @importFrom utils head
create_html_table <- function(comparison_output, file_name, limit_html, color_scheme, headers_all){

  comparison_table_diff = comparison_output$comparison_table_diff_numbers
  comparison_table_ts2char = comparison_output$comparison_table_ts2char
  group_col = comparison_output$group_col

  if (limit_html > 1000 & comparison_table_diff %>% nrow > 1000)
    warning("Creating HTML diff for a large dataset (>1000 rows) could take a long time!")

  if (limit_html < nrow(comparison_table_diff))
    message_compareDF("Truncating HTML diff table to ${limit_html} rows...")

  requireNamespace("htmlTable")
  comparison_table_color_code  = comparison_table_diff %>% do(.colour_coding_df(., color_scheme)) %>% as.data.frame

  shading = ifelse(sequence_order_vector(comparison_table_ts2char[[group_col]]) %% 2, "#dedede", "white")

  table_css = lapply(comparison_table_color_code, function(x)
    paste0("padding: .2em; color: ", x, ";")) %>% data.frame %>% head(limit_html) %>% as.matrix()

  colnames(comparison_table_ts2char) <- headers_all

  message_compareDF("Creating HTML table for first ${limit_html} rows")
  html_table = htmlTable::htmlTable(comparison_table_ts2char %>% head(limit_html),
                                    col.rgroup = shading,
                                    rnames = F, css.cell = table_css,
                                    padding.rgroup = rep("5em", length(shading))
  )
  if (!is.null(file_name)){
    cat(html_table, file = file_name)
    return(file_name)
  }
  return(html_table)

}

.colour_coding_df <- function(df, color_scheme){
  if(nrow(df) == 0) return(df)
  df[df == 2] = color_scheme[['addition']]
  df[df == 1] = color_scheme[['removal']]
  df[df == 0] = color_scheme[['unchanged_cell']]
  df[df == -1] = color_scheme[['unchanged_row']]
  df
}

.convert_to_row_column_format <- function(x, n){
  list(
    rows = ((x - 1) %% n) + 1,
    cols = ((x - 1) %/% n) + 1
  )
}

.get_color_coding_indices <- function(df){
  output = list(
    'addition' = which(df == 2),
    'removal' = which(df == 1),
    'unchanged_cell' = which(df == 0),
    'unchanged_row' = which(df == -1)
  ) %>% Filter(function(x) length(x) > 0, .) %>%
    lapply(.convert_to_row_column_format, nrow(df))
}

.adjust_colors_for_excel <- function(types){
  for(type in names(types)){
    types[[type]][['rows']] = types[[type]][['rows']] + 1
  }
  types
}

create_xlsx_document <- function(comparison_output, file_name, limit, color_scheme, headers_all){
  if(is.null(file_name)) stop("file_name cannot be null if output format is xlsx")
  comparison_table_diff = comparison_output$comparison_table_diff_numbers
  comparison_table_ts2char = comparison_output$comparison_table_ts2char
  group_col = comparison_output$group_col

  requireNamespace("openxlsx")

  comparison_table_color_code  = comparison_table_diff %>% .get_color_coding_indices() %>%
    .adjust_colors_for_excel()

  wb <- openxlsx::createWorkbook("Compare DF Output")
  openxlsx::addWorksheet(wb, "Sheet1", gridLines = FALSE)
  openxlsx::writeData(wb, sheet = 1, comparison_table_ts2char, rowNames = FALSE)

  for(i in seq_along(comparison_table_color_code)){
    openxlsx::addStyle(wb, sheet = 1,
                       openxlsx::createStyle(fontColour = color_scheme[[names(comparison_table_color_code)[i]]]),
                       rows = comparison_table_color_code[[i]]$rows, cols = comparison_table_color_code[[i]]$cols,
                       gridExpand = FALSE)
  }

  even_rows = which(sequence_order_vector(comparison_table_ts2char[[group_col]]) %% 2 == 0) + 1
  openxlsx::addStyle(wb, sheet = 1, openxlsx::createStyle(fgFill = 'lightgray'), rows = even_rows,
                     cols = 1:ncol(comparison_table_ts2char), gridExpand = T, stack = TRUE)

  openxlsx::saveWorkbook(wb, file_name, overwrite = T)

}

#' @title Convert to wide format
#' @description Easier to compare side-by-side
#' @param comparison_output Output from the comparison Table functions
#' @param suffix Nomenclature for the new and old dataframe
#' @export
create_wide_output <- function(comparison_output, suffix = c("_new", "_old")){
  dplyr::full_join(
      comparison_output$comparison_df %>% filter(chng_type == comparison_output$change_markers[1]),
      comparison_output$comparison_df %>% filter(chng_type == comparison_output$change_markers[2]),
      by = comparison_output$group_col,
      suffix = suffix,
    ) %>%
    select(-starts_with("chng_type")) %>%
    select(comparison_output$group_col, one_of(sort(names(.), decreasing = TRUE)))
}

# nocov start
#' @title View Comparison output HTML
#'
#' @description Some versions of Rstudio doesn't automatically show the html pane for the html output. This is a workaround
#'
#' @param comparison_output output from the comparisonDF compare function
#' @export
view_html <- function(comparison_output){
  temp_dir = tempdir()
  temp_file <- paste0(temp_dir, "/temp.html")
  cat(create_output_table(comparison_output), file = temp_file)
  getOption("viewer")(temp_file)
  unlink("temp.html")
}
# nocov end

