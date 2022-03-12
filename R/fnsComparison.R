utils::globalVariables(c("is_changed", "newold_type"))
.datatable.aware = TRUE

#' @title Compare Two dataframes
#'
#' @description Do a git style comparison between two data frames of similar columnar structure
#'
#' @param df_new The data frame for which any changes will be shown as an addition (green)
#' @param df_old The data frame for which any changes will be shown as a removal (red)
#' @param group_col A character vector of a string of character vector showing the columns
#'  by which to group_by.
#' @param exclude The columns which should be excluded from the comparison
#' @param stop_on_error Whether to stop on acceptable errors on not
#' @param tolerance The amount in fraction to which changes are ignored while showing the
#'  visual representation. By default, the value is 0 and any change in the value of variables
#'  is shown off. Doesn't apply to categorical variables.
#' @param tolerance_type Defaults to 'ratio'. The type of comparison for numeric values, can be 'ratio' or 'difference'
#' @param keep_unchanged_rows whether to preserve unchanged values or not. Defaults to \code{FALSE}
#' @param keep_unchanged_cols whether to preserve unchanged values or not. Defaults to \code{TRUE}
#' @param change_markers what the different change_type nomenclature should be eg: c("new", "old", "unchanged").
#' @param round_output_to Number of digits to round the output to. Defaults to 3.
# #' @import data.table
# #' @import dplyr

#' @importFrom data.table :=
#' @importFrom data.table data.table as.data.table uniqueN .N .SD

#' @importFrom dplyr `%>%`
#' @importFrom dplyr mutate transmute select slice arrange desc do filter tally n ungroup
#' @importFrom dplyr group_by_at mutate_if arrange_at summarize arrange_at starts_with full_join
#' @importFrom rlang .data
#' @importFrom tibble rownames_to_column
#' @export
compare_df <- function(df_new, df_old, group_col, exclude = NULL, tolerance = 0, tolerance_type = 'ratio',
                       stop_on_error = TRUE, keep_unchanged_rows = FALSE, keep_unchanged_cols = TRUE,
                       change_markers = c("+", "-", "="),
                       round_output_to = 3){

  current_saf_val = options('stringsAsFactors')[[1]]
  options(stringsAsFactors = FALSE)
  on.exit(options(stringsAsFactors = current_saf_val))

  df_old = data.table::data.table(df_old)
  df_new = data.table::data.table(df_new)

  if (missing(group_col)) {
    warning("Missing grouping columns. Adding rownames to use as the default")
    group_col = 'rowname'
    if (!('rowname' %in% names(df_new))) df_new = rownames_to_column(df_new)
    if (!('rowname' %in% names(df_old))) df_old = rownames_to_column(df_old)
  }

  both_tables = list(df_new = df_new, df_old = df_old)
  if (!is.null(exclude)) both_tables = exclude_columns(both_tables, exclude)

  check_if_comparable(both_tables$df_new, both_tables$df_old, group_col, stop_on_error)
  both_tables = convert_factors_to_character(both_tables)

  both_tables$df_new = both_tables$df_new[, .SD, .SDcols = names(both_tables$df_old)]

  if (length(group_col) > 1) {
    both_tables = group_columns(both_tables, group_col)
    group_col = "grp"
  }

  both_diffs = combined_rowdiffs_v2(both_tables, group_col)

  check_if_similar_after_unique_and_reorder(both_tables, both_diffs, stop_on_error)

  comparison_table         = create_comparison_table(both_diffs, group_col, round_output_to)
  comparison_table_ts2char = .ts2char(comparison_table)
  comparison_table_diff    = create_comparison_table_diff(comparison_table_ts2char, group_col, tolerance, tolerance_type)

  comparison_table         = eliminate_tolerant_rows(comparison_table, comparison_table_diff)
  comparison_table_ts2char = comparison_table_ts2char %>% eliminate_tolerant_rows(comparison_table_diff)
  comparison_table_diff    = eliminate_tolerant_rows(comparison_table_diff, comparison_table_diff)

  if (keep_unchanged_rows) {

    comparison_table = comparison_table %>% keep_unchanged_rows_fn(both_tables, group_col, "val_table")
    comparison_table_ts2char = comparison_table_ts2char %>% keep_unchanged_rows_fn(both_tables, group_col, "val_table")
    comparison_table_diff    = comparison_table_diff %>% keep_unchanged_rows_fn(both_tables, group_col, "color_table")

    comparison_table_diff = comparison_table_diff[order(comparison_table[[group_col]]),]
    comparison_table_ts2char = comparison_table_ts2char[order(comparison_table[[group_col]]),]
    comparison_table = comparison_table[order(comparison_table[[group_col]]),]
  }

  if (!keep_unchanged_cols) {
    all_unchanged = apply(comparison_table_diff %>% select(-!!group_col), 2, function(x) all(x <= 0))
    unchanged_cols = names(Filter(identity, all_unchanged))
    comparison_table = comparison_table %>% select(-one_of(unchanged_cols))
    comparison_table_ts2char = comparison_table_ts2char %>% select(-one_of(unchanged_cols))
    comparison_table_diff = comparison_table_diff %>% select(-one_of(unchanged_cols))
  }

  if (nrow(comparison_table) == 0) stop_or_warn("The two data frames are the same after accounting for tolerance!", stop_on_error)
  if (nrow(comparison_table_diff) == 0) stop_or_warn("The two data frames are the same after accounting for tolerance!", stop_on_error)

  change_count =  create_change_count(comparison_table, group_col)
  change_summary =  create_change_summary(change_count, both_tables)

  comparison_table$chng_type = comparison_table$chng_type %>% replace_numbers_with_change_markers(change_markers)
  comparison_table_diff_symbols = comparison_table_diff %>% replace_numbers_with_change_markers(change_markers)

  list(comparison_df = comparison_table,
       comparison_table_diff = comparison_table_diff_symbols,
       change_count = change_count, change_summary = change_summary,
       group_col = group_col,
       change_markers = change_markers,
       comparison_table_ts2char = comparison_table_ts2char,
       comparison_table_diff_numbers = comparison_table_diff)

}


convert_factors_to_character <- function(both_tables){
  lapply(both_tables, function(x){
    if (any(vapply(x, is.factor, TRUE))) {
      message_compareDF("Found factor columns! Will be casted to character for comparison!")
      x = x %>% mutate_if(is.factor, as.character)
    }
    x
  })
}

keep_unchanged_rows_fn <- function(comparison_table, both_tables, group_col, type){

  unchanged_rows = lapply(both_tables, function(x)
    x[!duplicated(rbind(x, comparison_table %>% select(-chng_type)), fromLast = TRUE)[seq_len(nrow(x))], ]
  ) %>%
    Reduce(rbind, .) %>% dplyr::mutate(chng_type = '0')

  if (type == 'color_table') unchanged_rows[] = -1
  comparison_table %>% rbind(unchanged_rows)
}

replace_numbers_with_change_markers <- function(x, change_markers){
  if (is.vector(x) && length(x) == 0) return(x)
  if (is.data.frame(x) && nrow(x) == 0) return(x)
  x[x == 2] = change_markers[1]
  x[x == 1] = change_markers[2]
  x[x == 0] = change_markers[3]
  x[x == -1] = change_markers[3]
  x
}

exclude_columns <- function(both_tables, exclude){
  list(df_old = both_tables$df_old %>% select(-one_of(exclude)),
       df_new = both_tables$df_new %>% select(-one_of(exclude)))
}

#' @importFrom dplyr group_indices
group_columns <- function(both_tables, group_col){
  message_compareDF("Grouping columns")
  df_combined = rbind(both_tables$df_new %>% mutate(from = "new"), both_tables$df_old %>% mutate(from = "old"))
  df_combined = df_combined %>%
    group_by_at(group_col) %>%
    data.frame(grp = group_indices(.), ., check.names = FALSE) %>%
    ungroup()
  list(df_new = df_combined %>% filter(from == "new") %>% select(-from),
       df_old = df_combined %>% filter(from == "old") %>% select(-from))
}

combined_rowdiffs_v2 <- function(both_tables, group_col){
  df_combined <- as.data.table(
    rbind(both_tables$df_old %>% mutate(newold_type = 'old'),
          both_tables$df_new %>% mutate(newold_type = 'new')), key = group_col)

  df_combined[
    ,
    if (uniqueN(.N) == 1) .SD,
    by = group_col
    ]
  df_combined[
    (duplicated(df_combined, by=setdiff(names(df_combined), 'newold_type')) |
       duplicated(df_combined, fromLast=TRUE,by=setdiff(names(df_combined), 'newold_type'))),
    chng_type := FALSE
    ]
  df_combined[is.na(chng_type), chng_type := TRUE]

  list(
    df1_2 = df_combined[newold_type == 'old' & chng_type,,] %>% data.frame(check.names = FALSE) %>% select(-newold_type, -chng_type),
    df2_1 = df_combined[newold_type == 'new' & chng_type,,] %>% data.frame(check.names = FALSE) %>% select(-newold_type, -chng_type)
  )
}

stop_or_warn <- function(text, stop_on_error = TRUE){
  if(is.null(stop_on_error)) return(NULL)
  if(stop_on_error) stop(text) else warning(text)
}

check_if_similar_after_unique_and_reorder <- function(both_tables, both_diffs, stop_on_error){
  if(any(sapply(both_diffs, nrow) != 0)) return(TRUE)
  if(nrow(both_tables$df_new) == nrow(both_tables$df_old))
    stop_or_warn("The two dataframes are similar after reordering", stop_on_error) else
      stop_or_warn("The two dataframes are similar after reordering and doing unique", stop_on_error)

}

create_comparison_table <- function(both_diffs, group_col, round_output_to){
  message_compareDF("Creating comparison table...")
  mixed_df = both_diffs$df1_2 %>% mutate(chng_type = NA_integer_) %>% slice(0) %>% data.frame(check.names = FALSE)
  if(nrow(both_diffs$df1_2) != 0) mixed_df = mixed_df %>% rbind(data.frame(chng_type = "1", both_diffs$df1_2, check.names = FALSE))
  if(nrow(both_diffs$df2_1) != 0) mixed_df = mixed_df %>% rbind(data.frame(chng_type = "2", both_diffs$df2_1, check.names = FALSE))
  mixed_df %>%
    arrange(desc(chng_type)) %>%
    arrange_at(group_col) %>%
    # mutate(chng_type = ifelse(chng_type == 1, "1", "2")) %>%
    select(one_of(group_col), everything()) %>% round_num_cols(round_output_to)
}


create_comparison_table_diff <- function(comparison_table_ts2char, group_col, tolerance, tolerance_type){
  comparison_table_ts2char %>% group_by_at(group_col) %>%
    do(.diff_type_df(., tolerance = tolerance, tolerance_type = tolerance_type)) %>%
    as.data.frame
}

eliminate_tolerant_rows <- function(comparison_table, comparison_table_diff){
  rows_inside_tolerance = comparison_table_diff %>% select(-chng_type) %>%
    apply(1, function(x) all(x == 0))
  comparison_table %>% filter(!rows_inside_tolerance)
}


check_if_comparable <- function(df_new, df_old, group_col, stop_on_error){

  if(isTRUE(all.equal(df_old, df_new))) stop_or_warn("The two data frames are the same!", stop_on_error)

  if(!(all(names(df_new) %in% names(df_old)))) stop("The two data frames have different columns!")

  if(!all(group_col %in% names(df_new))) stop("Grouping column(s) not found in the data.frames!")

  if(any(c("chng_type", "X2", "X1", "newold_type") %in% group_col)) stop("chng_type, newold_type, X1, X2 are reserved keywords for grouping column!")

  return(TRUE)

}

round_num_cols <- function(df, round_digits = 2)
{
  numeric_cols = which(sapply(df, is.numeric))
  df[, numeric_cols] = lapply(df[, numeric_cols, drop = F], round, round_digits)

  df
}

#' @importFrom stats na.omit
.diff_type_df <- function(df, tolerance = 1e-6, tolerance_type = 'ratio'){

  lapply(df, function(x) {
    len_unique_x = length(na.omit(unique(x)))

    # Score = 1 here implies it should be coloured
    if(length(na.omit(x)) == 1){
      score = 1
    }else{
      if(is.numeric(x) & !is.POSIXct(x) & len_unique_x > 1){

        range_x = diff(range(x, na.rm = T))
        if(tolerance_type == 'ratio') score = as.numeric(abs(range_x/min(x, na.rm = T)) > tolerance) else
          if(tolerance_type == 'difference') score = range_x > tolerance else
            stop("Unknown tolerance type: Should be `ratio` or `difference`")

      }else
        score = as.numeric(len_unique_x > 1)
    }
    # This step decides what colour it should be.
    score = score + score * as.numeric(df$chng_type == "2")
  }) %>% data.frame(check.names = FALSE)
}

# Courtesy - Gabor Grothendieck
# rowdiff2 <- function(x.1,x.2,...){
#   do.call("rbind", setdiff(split(x.1, rownames(x.1)), split(x.2, rownames(x.2))))
# }

.ts2char <- function(df)
{
  ts_cols = which(sapply(df, is.POSIXct))
  if (length(ts_cols) != 1) {
    df[, ts_cols] = lapply(df[, ts_cols], as.character)
  }else
    df[[ts_cols]] = as.character(df[[ts_cols]])

  df
}

is.POSIXct <- function(x) inherits(x, "POSIXct")

sequence_order_vector <- function(data)
{
  temp1 <- rle(as.vector(data))$lengths
  rep(seq_along(temp1),temp1) - 1L
}

create_change_count <- function(comparison_table_ts2char, group_col){
  change_count = comparison_table_ts2char %>% group_by_at(c(group_col, "chng_type")) %>% tally()
  change_count_replace = change_count %>%
    tidyr::pivot_wider(names_from = .data$chng_type, values_from = .data$n, names_prefix = "X") %>%
    data.frame(check.names = F)
  change_count_replace[is.na(change_count_replace)] = 0

  if(is.null(change_count_replace[['X1']])) change_count_replace = change_count_replace %>% mutate(X1 = 0L)
  if(is.null(change_count_replace[['X2']])) change_count_replace = change_count_replace %>% mutate(X2 = 0L)
  change_count_replace = change_count_replace %>%
    as.data.frame %>%
    tidyr::pivot_longer(cols = c(.data$X2, .data$X1), names_to = "variable")

  change_count_output = change_count_replace %>% group_by_at(group_col) %>% arrange_at('variable') %>%
    summarize(changes = min(value), additions = value[2] - value[1], removals = value[1] - value[2]) %>%
    mutate(additions = replace(additions, is.na(additions) | additions < 0, 0)) %>%
    mutate(removals = replace(removals, is.na(removals) | removals < 0, 0))

  change_count_output %>% data.frame(check.names = FALSE)

}

create_change_summary <- function(change_count, both_tables){
  c(old_obs = nrow(both_tables$df_old), new_obs = nrow(both_tables$df_new),
    changes = sum(change_count$changes), additions = sum(change_count$additions), removals = sum(change_count$removals))
}

get_headers_for_table <- function(headers, change_col_name, group_col_name, comparison_table_diff) {
  # if (is.null(headers)) return(names(comparison_table_diff))

  headers_all = names(comparison_table_diff) %>%
    replace(. == 'grp', group_col_name) %>%
    replace(. == 'chng_type', change_col_name)

  matching_vals = names(headers) %>% sapply(function(x) which(x == headers_all)) %>% Filter(function(x) length(x) > 0, .) %>% unlist()
  headers_all[matching_vals] = headers[names(matching_vals)]

  headers_all
}

### Deprecated

# rowdiff <- function(x.1,x.2,...){
#   if(nrow(x.2) == 0) return(x.1)
#   x.1[!duplicated(rbind(x.2, x.1))[-(1:nrow(x.2))],]
# }
#
# combined_rowdiffs <- function(both_tables){
#   list(df1_2 = rowdiff(both_tables$df_old, both_tables$df_new),
#        df2_1 = rowdiff(both_tables$df_new, both_tables$df_old))
#
#   list(df1_2 = rowdiff(both_tables$df_old, both_tables$df_new),
#        df2_1 = rowdiff(both_tables$df_new, both_tables$df_old))
# }
