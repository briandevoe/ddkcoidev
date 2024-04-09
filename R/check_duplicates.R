#' @name check_duplicates
#' @title check_duplicates
#' @description Check if rows are uniquely identified by a set of columns.
#' @param dt A data.table.
#' @param by_cols A character vector of column names.
#' @param noisily Logical. If TRUE, print messages.

check_duplicates <- function(dt=NULL, by_cols=NULL, noisily=T) {

  if (noisily==T) cat(" ", sepby="\n")

  ### Checks
  if (!all(by_cols %in% colnames(dt))) stop("Not all elements of by_cols are in dt")

  rows_dt     <- nrow(dt)
  unique_rows <- nrow( unique(dt[,..by_cols], by=by_cols) )

  if (rows_dt!=unique_rows) {

    cat(" ", sepby="\n")
    stop("Rows not uniquely identified by by_cols.")

  } else {

    if (noisily==T) cat("  by_cols uniquely identify rows", sepby="\n")

  }

}


