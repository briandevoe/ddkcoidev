#' @name check_miss
#' @title check_miss
#' @description Check for missing values in a data.table.
#' @param dt A data.table.
#' @param exempt A character vector of column names to be exempted from checks.
#' @param noisily Logical. If TRUE, print messages.
#' @param abort Logical. If TRUE, throw an error if missing values are found.

check_miss <- function(dt=NULL, exempt=NULL, noisily=T, abort=T) {

  if ( is.data.frame(dt)==F & is.data.table(dt)==F ) stop("dt needs to be a data.table or data.frame")
  if ( is.data.frame(dt)==T) dt <- as.data.table(dt)

  vars <- names(dt)

  # Remove exempt from checks
  if (!is.null(exempt)) {
    if (!all(exempt %in% names(dt))) stop("One or more elements of exempt does not exist in data.table")
    for (itm in exempt) {
      vars <- vars[!str_detect(vars, itm)]
    }
  }

  ##############################################################################

  ### Examine non-exempt

  # Check for NAs and
  NAs <- dt[, colSums( is.na(dt[ , .SD, .SDcols=vars]) )]
  names(NAs) <- vars

  # Check for Inf
  if (nrow(dt)>1) {
    Infs <- dt[,  colSums(sapply(.SD, is.infinite)), .SDcols=vars ]
  } else {
    Infs <- dt[,  sapply(.SD, is.infinite), .SDcols=vars ]
    for (vr in vars) {
      Infs[[vr]] <- ifelse(Infs[[vr]]==T, 1, 0)
    }
  }
  names(Infs) <- vars

  ### Check character variables
  char_vars <- sapply(vars, function(x) is.character(dt[[x]])) # sapply returns boolean

  if (sum(char_vars)>0) {
    char_vars <- names(char_vars[char_vars])

    NAs_string <- lapply(char_vars, function(x) {
      vec <- str_squish( dt[[x]] ) # removes whitespace at the start and end, and replaces all internal whitespace with a single space.
      vec <- sum(nchar(vec)==0, na.rm = T)
    })
    NAs_string <- unlist(NAs_string)
    names(NAs_string) <- char_vars

  } else {

    NAs_string <- 0

  }

  rm(char_vars)


  # Report/abort if non-exempted have missing/inf
  if ( sum(NAs)+sum(Infs)+sum(NAs_string)!=0 ) {

    if (sum(NAs)!=0) {
      cat("", sepby="\n")
      cat(paste0("Number of missing elements in non-exempt columns"), sepby="\n\n")
      print(NAs)
    }

    if (sum(Infs)!=0) {
      cat("", sepby="\n")
      cat(paste0("Number of infinite elements in non-exempt columns"), sepby="\n\n")
      print(Infs)
    }

    if (sum(NAs_string)!=0) {
      cat("", sepby="\n")
      cat(paste0("Number of empty elements in non-exempt character columns"), sepby="\n\n")
      print(NAs_string)
    }

    cat("", sepby="\n")
    throw_error <- T

  }

  rm(Infs, NAs, NAs_string, vars)

  ### Examine exempt, if any
  if (!is.null(exempt) & noisily==T) {

    # Check for NAs and
    NAs <- dt[, colSums( is.na(dt[ , .SD, .SDcols=exempt]) )]
    names(NAs) <- exempt

    # Check for Inf
    if (nrow(dt)>1) {
      Infs <- dt[,  colSums(sapply(.SD, is.infinite)), .SDcols=exempt ]
    } else {
      Infs <- dt[,  sapply(.SD, is.infinite), .SDcols=exempt ]
      for (vr in exempt) {
        Infs[[vr]] <- ifelse(Infs[[vr]]==T, 1, 0)
      }
    }
    names(Infs) <- exempt

    ### Check character variables
    char_vars <- sapply(exempt, function(x) is.character(dt[[x]])) # sapply returns boolean
    if (sum(char_vars)>0) {
      char_vars <- names(char_vars[char_vars])

      NAs_string <- lapply(char_vars, function(x) {
        vec <- str_squish( dt[[x]] ) # removes whitespace at the start and end, and replaces all internal whitespace with a single space.
        vec <- sum(nchar(vec)==0, na.rm = T)
      })
      NAs_string <- unlist(NAs_string)
      names(NAs_string) <- char_vars

    } else {

      NAs_string <- 0

    }

    rm(char_vars)

    # Report/abort if non-exempted have missing/inf
    if ( sum(NAs)+sum(Infs)+sum(NAs_string)!=0 ) {

      if (sum(NAs)!=0) {
        cat("", sepby="\n")
        cat(paste0("Number of missing elements in exempt columns"), sepby="\n\n")
        print(NAs)
      }

      if (sum(Infs)!=0) {
        cat("", sepby="\n")
        cat(paste0("Number of infinite elements in exempt columns"), sepby="\n\n")
        print(Infs)
      }

      if (sum(NAs_string)!=0) {
        cat("", sepby="\n")
        cat(paste0("Number of empty elements in exempt character columns"), sepby="\n\n")
        print(NAs_string)
      }

      cat("", sepby="\n")

    }

    rm(Infs, NAs, NAs_string, exempt)

  }

  if (exists("throw_error") & abort==T) {
    stop("Missing, infinite or empty element(s) found.")
  } else if (exists("throw_error") & abort==F) {
    cat("Missing, infinite or empty element(s) found.", sepby="\n")
  } else {
    if (noisily==T) cat("  No issues found in non-exempt columns", sepby="\n")
  }

}
