.onLoad <- function(libname, pkgname) {
  options(stringsAsFactors = FALSE) # nocov
}

# R CMD Check love
utils::globalVariables(c("chng_type", ".", "one_of", "everything", "value", "additions", "removals", "from"))

#' Data set created set to show off the package capabilities - Results of students for 2010
#'
#' A manually created dataset showing the hypothetical scores of two divisions of students
#' \itemize{
#'   \item Division The division to which the student belongs
#'   \item Student Name of the Student
#'   \item Maths, Physics, Chemistry, Art Scores of the student across different subjects
#'   \item Discipline, PE Grades of the students across different subjects
#' }
#' @format A data frame 12 rows and 8 columns
"results_2010"


#' Data set created set to show off the package capabilities - Results of students for 2011
#'
#' A manually created dataset showing the hypothetical scores of two divisions of students
#' \itemize{
#'   \item Division The division to which the student belongs
#'   \item Student Name of the Student
#'   \item Maths, Physics, Chemistry, Art Scores of the student across different subjects
#'   \item Discipline, PE Grades of the students across different subjects
#' }
#'
#' @format A data frame 13 rows and 8 columns
"results_2011"
