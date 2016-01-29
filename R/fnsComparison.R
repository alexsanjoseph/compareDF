
# This file has different comparison functions

CompareICTReports <- function(ict_report_1, ict_report_2, exclude = NULL, limit_html = 0, order_col = "subRoutineStart"){
  
  message("Checking that the two ICT reports are actually different")
  assert_that(!all(dim(ict_report_1) == dim(ict_report_2)) ||
                !all(ict_report_1==ict_report_2))
  
  #   message("Checking equivalence of time periods for each device")
  #   assert_that(are_equal(.reportRange(ict_report_1), .reportRange(ict_report_2)))
  #   
  if(!is.null(exclude)){
    ict_report_1 = ict_report_1 %>% select(-one_of(exclude))
    ict_report_2 = ict_report_2 %>% select(-one_of(exclude))
  }
  
  ict_report_1_dummy = ict_report_1 %>% mutate(slNo = 1:n())
  ict_report_2_dummy = ict_report_2 %>% mutate(slNo = 1:n())
  
  report1_2 = setdiffDFwithoutNA(ict_report_1, ict_report_2)
  report2_1 = setdiffDFwithoutNA(ict_report_2, ict_report_1)
  
  report2_1 = merge(report2_1, ict_report_2_dummy)
  report1_2 = merge(report1_2, ict_report_1_dummy)
  
  message("Creating comparison table...")
  comparison_table = rbind(data.frame(type = "+", report1_2) , data.frame(type = "-", report2_1)) %>% 
    group_by(type) %>% arrange_(order_col) %>% 
    mutate(diffGroup = cumsum(c(1, diff(slNo)) - 1)) %>%
    mutate(group = SequenceOrderVector(diffGroup), diffGroup = NULL) %>% ungroup %>% 
    arrange_(order_col, "type") %>% select(group, everything()) %>% r2two() %>% as.data.frame
  
  html_table = NULL 
  
  if(limit_html > 0){
    comparison_table_ts2char = ts2char(comparison_table) %>% head(limit_html)
    
    comparison_table_color_code  = comparison_table_ts2char %>% group_by(group) %>% 
      do(.colour_coding_df(.)) %>% ungroup %>% as.data.frame
    
    shading = ifelse(comparison_table_ts2char$group %% 2, "#dedede", "white")
    
    table_css = lapply(comparison_table_color_code, function(x)
      paste0("padding: .2em; color: ", x, ";")) %>% data.frame
    
    message("Creating HTML table for first ", limit_html, " rows")
    html_table = htmlTable(comparison_table_ts2char,  col.rgroup = shading, 
                           rnames = F, css.cell = table_css, padding.rgroup = rep("5em", length(shading)))
  }
  
  output = list(html_output = html_table, comparison_df = comparison_table)
  
}

.reportRange <- function(x){
  x %>% group_by(Device) %>% summarize(start = paste0(min(subRoutineStart), end = max(subRoutineStart+subRoutineDur)))
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
    score = score + score * as.numeric(df$type == "+")
  }) %>% data.frame 
}


setdiffDFwithoutNA <- function(x, y){
  random_string = "asdasd"
  random_number = 180114L
  
  assert_that(all(as.character(sapply(x, is)) == as.character(sapply(y, is))))
  # x[sapply(x, is.int)]
  numeric_columns = sapply(x, is.numeric)
  char_columns = sapply(x, is.character)
  
  x[,numeric_columns][is.na(x[,numeric_columns])] = random_number
  x[,char_columns][is.na(x[,char_columns])] = random_string
  
  y[,numeric_columns][is.na(y[,numeric_columns])] = random_number
  y[,char_columns][is.na(y[,char_columns])] = random_string
  
  output = setdiff(x, y)
  
  if (isEmpty(output)) stop("No Difference between the two DF")
  
  if (sum(numeric_columns) > 0) output[,numeric_columns][output[,numeric_columns] == random_number] = NA
  if (sum(char_columns) > 0) output[,char_columns][output[,char_columns] == random_string] = NA
  output
}



CompareDataFrames <- function(df_new, df_old, group_col, exclude = NULL, limit_html = 100, tolerance = 0){
  
  message("Checking that the two ICT reports are actually different")
  assert_that(!isTRUE(all.equal(df_old, df_new)))
  
  if(!is.null(exclude)) {
    df_old = df_old %>% select(-one_of(exclude))
    df_new = df_new %>% select(-one_of(exclude))
  }
  
  if (length(group_col) > 1) {
    
    message("Grouping grouping columns")
    df_combined = rbind(df_new %>% mutate(from = "new"), df_old %>% mutate(from = "old"))
    df_combined = df_combined %>% piped.do.call(group_by_, group_col) %>% data.frame(grp = group_indices(.), .) %>% ungroup
    df_new = df_combined %>% filter(from == "new") %>% select(-from)
    df_old = df_combined %>% filter(from == "old") %>% select(-from)
    group_col = 'grp'
  }
  
  df1_2 = setdiffDFwithoutNA(df_old, df_new)
  df2_1 = setdiffDFwithoutNA(df_new, df_old)
  
  message("Creating comparison table...")
  comparison_table = rbind(data.frame(type = "-", df1_2) , data.frame(type = "+", df2_1)) %>% 
    arrange(desc(type)) %>% arrange_(group_col) %>% 
    select(one_of(group_col), everything()) %>% r2two() 

  html_table = NULL 
  comparison_table_ts2char = .ts2char(comparison_table)
  
  comparison_table_diff  = comparison_table_ts2char %>% group_by_(group_col) %>% 
    do(.diff_type_df(., tolerance = tolerance)) %>% as.data.frame
  
  if (limit_html > 0){
    # Todo: Make seperate function
    require(htmlTable)
    comparison_table_color_code  = comparison_table_diff %>% do(.colour_coding_df(.)) %>% as.data.frame
    
    shading = ifelse(SequenceOrderVector(comparison_table_ts2char[[group_col]]) %% 2, "#dedede", "white")
    
    table_css = lapply(comparison_table_color_code, function(x)
      paste0("padding: .2em; color: ", x, ";")) %>% data.frame  %>% head(limit_html)
    
    message("Creating HTML table for first ", limit_html, " rows")
    html_table = htmlTable(comparison_table_ts2char %>% head(limit_html),
                           col.rgroup = shading, 
                           rnames = F, css.cell = table_css, 
                           padding.rgroup = rep("5em", length(shading))
    )
  }
  
  
  ### Summary report 
  change_count = comparison_table_ts2char %>% group_by_(group_col, "type") %>% tally()
  change_count_replace = change_count %>% spread(key = type, value = n) 
  change_count_replace[is.na(change_count_replace)] = 0
  change_count_replace = change_count_replace %>% as.data.frame %>%
    gather_("variable", "value", c("+", "-")) 
  
  change_count = change_count_replace %>% group_by_(group_col) %>% arrange(value) %>% 
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
  change_detail_replace = change_detail_replace %>% group_by_(group_col, "variable") %>% spread(key = value, value = n)
  change_detail_replace[is.na(change_detail_replace)] = 0
  change_detail_summary_replace = change_detail_replace %>% data.frame %>% dplyr::rename(param = variable) %>% 
    mutate(param = as.character(param)) %>% gather("variable", "value", 3:ncol(.))
  
  change_detail_count = change_detail_summary_replace %>% group_by_(group_col, "param") %>% arrange(desc(variable)) %>% 
    summarize(changes = min(value[1:2]), additions = value[1] - value[2], removals = value[2] - value[1]) %>% 
    mutate(additions = replace(additions, is.na(additions), 0)) %>% 
    mutate(removals = replace(removals, is.na(removals), 0)) 
  change_detail_count[change_detail_count < 0] = 0
  
  change_detail_count_summary = change_detail_count %>% group_by(param) %>% 
    summarize(total_changes = sum(changes), total_additions = sum(additions), tot_removals = sum(removals))
  
  output = list(comparison_df = comparison_table, html_output = html_table,  
                comparison_table_diff = comparison_table_diff, 
                change_count = change_count, change_summary = change_summary,
                change_detail_summary = change_detail_count_summary)
  
}

#' @title Convert timestamp tables to character
.ts2char <- function(dataframe)
{
  ts_cols = which(sapply(dataframe, is.POSIXct))
  if (length(ts_cols) != 1) {
    if (is.data.table(dataframe))
      dataframe[, ts_cols] = lapply(dataframe[, ts_cols, with = F], as.character) else
        dataframe[, ts_cols] = lapply(dataframe[, ts_cols], as.character) 
  }else
    dataframe[[ts_cols]] = as.character(dataframe[[ts_cols]])
  
    
    dataframe
}
