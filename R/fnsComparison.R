
#' @title Compare Two dataframes
#'
#' @description Do a git style comparison between two data frames of similar columnar structure
#'
#' @param df_new The data frame for which any changes will be shown as an addition (green)
#' @param df_old The data frame for which any changes will be shown as a removal (red)
#' @param group_col A character vector of a string of character vector showing the columns
#'  by which to group_by.
#' @param exclude The columns which should be excluded from the comparison
#' @param limit_html maximum number of rows to show in the html diff. >1000 not recommended
#' @param tolerance The amount in fraction to which changes are ignored while showing the
#'  visual representation. By default, the value is 0 and any change in the value of variables
#'  is shown off. Doesn't apply to categorical variables.
#' @import dplyr
#' @export
#' @examples
#' old_df = data.frame(var1 = c("A", "B", "C"),
#'                     val1 = c(1, 2, 3))
#' new_df = data.frame(var1 = c("A", "B", "C"),
#'                     val1 = c(1, 2, 4))
#' ctable = compare_df(new_df, old_df, c("var1"))
#' print(ctable$comparison_df)
#' ctable$html_output
compare_df <- function(df_new, df_old, group_col, exclude = NULL, limit_html = 100, tolerance = 0){

  one_of = everything = identity
  . = from = chng_type = value = additions = removals = variable = param = NULL # F*** R CMD Check

  if(!is.null(exclude)) {
    df_old = df_old %>% select(-one_of(exclude))
    df_new = df_new %>% select(-one_of(exclude))
  }

  check_if_comparable(df_new, df_old, group_col)

  if (length(group_col) > 1) {

    message("Grouping grouping columns")
    df_combined = rbind(df_new %>% mutate(from = "new"), df_old %>% mutate(from = "old"))
    df_combined = df_combined %>% piped.do.call(group_by_, group_col) %>% data.frame(grp = group_indices(.), .) %>% ungroup
    df_new = df_combined %>% filter(from == "new") %>% select(-from)
    df_old = df_combined %>% filter(from == "old") %>% select(-from)
    group_col = 'grp'
  }

  df1_2 = rowdiff(df_old, df_new)
  df2_1 = rowdiff(df_new, df_old)

  message("Creating comparison table...")
  comparison_table = rbind(data.frame(chng_type = "-", df1_2) , data.frame(chng_type = "+", df2_1)) %>%
    arrange(desc(chng_type)) %>% arrange_(group_col) %>%
    select(one_of(group_col), everything()) %>% r2two()

  html_table = NULL
  comparison_table_ts2char = .ts2char(comparison_table)

  comparison_table_diff  = comparison_table_ts2char %>% group_by_(group_col) %>%
    do(.diff_type_df(., tolerance = tolerance)) %>% as.data.frame

  proceed = T
  if(limit_html > 1000 & comparison_table_diff %>% nrow > 1000)
    warning("Creating HTML diff for a large dataset (>1000 rows) could take a long time!")

  if(limit_html < nrow(comparison_table_diff))
    message("Truncating HTML diff table to ", limit_html, " rows...")
  if (limit_html > 0){
    requireNamespace("htmlTable")
    comparison_table_color_code  = comparison_table_diff %>% do(.colour_coding_df(.)) %>% as.data.frame

    shading = ifelse(sequence_order_vector(comparison_table_ts2char[[group_col]]) %% 2, "#dedede", "white")

    table_css = lapply(comparison_table_color_code, function(x)
      paste0("padding: .2em; color: ", x, ";")) %>% data.frame  %>% head(limit_html)

    message("Creating HTML table for first ", limit_html, " rows")
    html_table = htmlTable::htmlTable(comparison_table_ts2char %>% head(limit_html),
                           col.rgroup = shading,
                           rnames = F, css.cell = table_css,
                           padding.rgroup = rep("5em", length(shading))
    )
  }


  ### Summary report
  change_count = comparison_table_ts2char %>% group_by_(group_col, "chng_type") %>% tally()
  change_count_replace = change_count %>% tidyr::spread(key = chng_type, value = n)
  change_count_replace[is.na(change_count_replace)] = 0
  change_count_replace = change_count_replace %>% as.data.frame %>%
    tidyr::gather_("variable", "value", c("+", "-"))

  change_count = change_count_replace %>% group_by_("variable") %>% arrange(value) %>%
    summarize(changes = min(value), additions = value[1] - value[2], removals = value[2] - value[1]) %>%
    mutate(additions = replace(additions, is.na(additions), 0)) %>%
    mutate(removals = replace(removals, is.na(removals), 0))
  change_count[change_count < 0] = 0

  change_summary = c(old_obs = nrow(df_old), new_obs = nrow(df_new),
                     changes = sum(change_count$changes), additions = sum(change_count$additions),
                     removals = sum(change_count$removals))

  change_detail = comparison_table_diff
  change_detail[[group_col]] = comparison_table_ts2char[[group_col]]
  change_detail = change_detail %>% reshape::melt.data.frame(group_col)

  change_detail_replace = change_detail %>% group_by_(group_col, "variable", "value") %>% tally()
  change_detail_replace = change_detail_replace %>% group_by_(group_col, "variable") %>% tidyr::spread(key = value, value = n)
  change_detail_replace[is.na(change_detail_replace)] = 0
  change_detail_summary_replace = change_detail_replace %>% data.frame %>% dplyr::rename(param = variable) %>%
    mutate(param = as.character(param)) %>% tidyr::gather("variable", "value", 3:ncol(.))

  change_detail_count = change_detail_summary_replace %>% group_by_(group_col, "param") %>% arrange(desc(variable)) %>%
    summarize(changes = min(value[1:2]), additions = value[1] - value[2], removals = value[2] - value[1]) %>%
    mutate(additions = replace(additions, is.na(additions), 0)) %>%
    mutate(removals = replace(removals, is.na(removals), 0))
  change_detail_count = change_detail_count %>%
    mutate(replace(changes, changes < 0, 0)) %>%
    mutate(replace(removals, removals < 0, 0)) %>%
    mutate(replace(additions, additions < 0, 0))

  change_detail_count_summary = change_detail_count %>% group_by(param) %>%
    summarize(total_changes = sum(changes), total_additions = sum(additions), tot_removals = sum(removals))

  output = list(comparison_df = comparison_table, html_output = html_table,
                comparison_table_diff = comparison_table_diff,
                change_count = change_count, change_summary = change_summary,
                change_detail_summary = change_detail_count_summary)

}

check_if_comparable <- function(df_new, df_old, group_col){

  if(isTRUE(all.equal(df_old, df_new))) stop("The two data frames are the same!")

  if(any(names(df_new) != names(df_old))) stop("The two data frames have different columns!")

  if(any("chng_type" %in% group_col)) stop("chng_type is a reserved keyword!")

  if(!all(group_col %in% names(df_new))) stop("Grouping column(s) not found in the data.frames!")

  return(TRUE)

}
r2two <- function(df, round_digits = 2)
{
  numeric_cols = which(sapply(df, is.numeric))
  df[, numeric_cols] = lapply(df[, numeric_cols, drop = F], round, round_digits)

  df
}

.colour_coding_df <- function(df){
  df[df == 2] = "green"
  df[df == 1] = "red"
  df[df == 0] = "grey"
  df
}

.diff_type_df <- function(df, tolerance = 1e-6){

  lapply(df, function(x) {
    len_unique_x = length(na.omit(unique(x)))

    # Score = 1 here implies it should be coloured
    if(length(na.omit(x)) == 1){
      score = 1
    }else{
      if(is.numeric(x) & !is.POSIXct(x) & len_unique_x > 1){
        range_x = diff(range(x, na.rm = T))
        score = as.numeric(range_x/min(x, na.rm = T) > tolerance)
      }else
        score = as.numeric(len_unique_x > 1)
    }
    # This step decides what colour it should be.
    score = score + score * as.numeric(df$chng_type == "+")
  }) %>% data.frame
}

# Courtesy - Gabor Grothendieck
# rowdiff2 <- function(x.1,x.2,...){
#   do.call("rbind", setdiff(split(x.1, rownames(x.1)), split(x.2, rownames(x.2))))
# }

rowdiff <- function(x.1,x.2,...){
  x.1[!duplicated(rbind(x.2, x.1))[-(1:nrow(x.2))],]
}

.ts2char <- function(df)
{
  ts_cols = which(sapply(df, is.POSIXct))
  if (length(ts_cols) != 1) {
    df[, ts_cols] = lapply(df[, ts_cols], as.character)
  }else
    df[[ts_cols]] = as.character(df[[ts_cols]])

    df
}

piped.do.call = function(x, fname, largs) do.call(fname, c(list(x), largs))

is.POSIXct <- function(x) inherits(x, "POSIXct")

sequence_order_vector <- function(data)
{
  temp1 <- rle(as.vector(data))$lengths
  rep(seq_along(temp1),temp1) - 1L
}
