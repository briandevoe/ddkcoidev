#' @name check_merge
#' @title check_merge
#' @description check_merge is a function that checks the results of a merge between two datasets
#' @param data1 is always the larger dataset and the one in which key combinations may repeat
#' @param data2 is always uniquely identified by keys
#' @param keys is a vector of key columns
#' @param join_type is the type of join to perform: "outer"-default, "inner", "left", or "right"
#' @param abort is a logical that determines whether to abort if mismatches are detected
#' @param return_class is the class of the returned object: "data.table"-default, "tibble", or "data.frame"
#' @param keep_merge_vars is a logical that determines whether to keep the merge variables
#' @param noisily is a logical that determines whether to print output

cat("Loading check_merge: function(data1, data2, keys, join_type, abort, return_class, keep_merge_vars, noisily)", sep="\n")

check_merge <- function(data1, data2, keys, join_type="outer", abort=T, return_class="data.table", keep_merge_vars=F, noisily=T) {

  if (noisily==T) cat("", sep="\n")

  ##############################################################################

  ### Helper things

  # List of variables for output tables
  disp_vars <- c("result", "N", "perc_of_merged", "perc_of_original")

  # Reporting
  print_merge_results <- function(dt=merged, disp_vars=disp_vars) {

    dt <- merged[, .N, by=.(data1,data2)]

    dt$sort <- ifelse(is.na(dt$data2)==1 & dt$data1==1, 1, NA)
    dt$sort <- ifelse(is.na(dt$data1)==1 & dt$data2==1, 2, NA)
    dt$sort <- ifelse(dt$data1==1 & dt$data2==1, 3, NA)
    setorder(dt, "sort")

    dt$result <- ifelse(dt$data1==1 & dt$data2==1, "In data1   and   data2: ", dt$result)
    dt$result <- ifelse(is.na(dt$data2)==1 & dt$data1==1, "In data1 but not data2: ", dt$result)
    dt$result <- ifelse(is.na(dt$data1)==1 & dt$data2==1, "In data2 but not data1: ", dt$result)

    dt <- dt[ , perc_of_merged:=paste0( 100*round(N/sum(N),4),"%")]

    dt$perc_of_original <- ifelse( is.na(dt$data2)==1 & dt$data1==1,
                                          paste0( 100*round(dt$N/nrow(data1),4),"%"),
                                          NA)
    dt$perc_of_original <- ifelse( is.na(dt$data1)==1 & dt$data2==1,
                                          paste0( 100*round(dt$N/nrow(data2),4),"%"),
                                          dt$perc_of_original)
    return(dt)

  }

  ##############################################################################

  ### Checks

  # Check options
  if (any( str_detect(c("inner","outer","left","right"), join_type) )==F)        stop("join_type can only be outer (default), inner, left, or right")
  if (any( str_detect(c("data.table","tibble","data.frame"), return_class) )==F) stop("return_class can only be data.table (default), tibble or data.frame")
  if ((noisily==T | noisily==F)==F)                       stop("noisily can only be TRUE (default) or FALSE")
  if ((keep_merge_vars==T | keep_merge_vars==F)==F)       stop("keep_merge_vars can only be FALSE (default) or TRUE")
  if ((abort==T | abort==F)==F)                           stop("abort can only be FALSE (default) or TRUE")

  # Check that none of the objects about to be defined exist
  for (itm in c("names1","names2","names_intersect","merged","merge_results")) {
    if ( exists(x = itm) ) stop(paste0("Object ",itm," already exists"))
  }
  rm(itm)

  # Check that data1 and data2 don't exist in either data1 and data2
  if ("data1" %in% colnames(data1)) stop("Column data1 already exists in data1")
  if ("data1" %in% colnames(data2)) stop("Column data1 already exists in data2")
  if ("data2" %in% colnames(data1)) stop("Column data2 already exists in data1")
  if ("data2" %in% colnames(data2)) stop("Column data2 already exists in data2")

  # Convert data1 and data2 to data.table
  data1 <- as.data.table(data1)
  data2 <- as.data.table(data2)

  ### Get variable names from data sets
  names1 <- names(data1)
  names2 <- names(data2)

  # Check that keys exist in both datasets
  for(k in 1:length(keys)) {
    if ( any( str_detect(names1, keys[k]) )==F ) stop(paste0(keys[k], " missing from data1"))
    if ( any( str_detect(names2, keys[k]) )==F ) stop(paste0(keys[k], " missing from data2"))
  }
  rm(k)

  # Check that keys are of the same class/type
  for (k in 1:length(keys)) {
    chk1 <- paste0(class(data1[[keys[k]]])," ",typeof(data1[[keys[k]]]))
    chk2 <- paste0(class(data2[[keys[k]]])," ",typeof(data2[[keys[k]]]))
    if (chk1!=chk2) {
      print(paste0("Classes and or types do not match across datasets for ",keys[k]))
      stop(paste0(keys[k], " is ", chk1, " in data1, and ", chk2, " in data2"))
    }
    rm(chk1,chk2)
  }
  rm(k)

  # Check that data2 isn't longer than data1
  # if ( nrow(data2)>nrow(data1) ) stop("data2 can't have more rows than data1")

  ##############################################################################

  ### Prepare data for merge

  # Get intersection of variable names from data sets, and remove keys
  names_intersect <- base::intersect(names1,names2)
  names_intersect <- names_intersect[!names_intersect %in% keys]

  # Drop variables that exist in both datasets from data2
  if (length(names_intersect)>0) {
    data2 <- data2[, -..names_intersect]
    if (length(names_intersect) > 1) names_intersect <- paste0(names_intersect, collapse=", ")
    if (noisily==T) cat(paste0("  Dropping the following column(s) from data2: ", names_intersect), sep = "\n\n"); cat("", sep="\n")
  }
  rm(names1, names2, names_intersect)

  # There can be duplicates in data, in which case we do a many-to-one merge
  if (nrow(data1)!=nrow(unique(data1, by=keys))) {
    if (noisily==T) cat("  many-to-one merge", sep = "\n")
  } else {
    if (noisily==T) cat("  one-to-one merge", sep = "\n")
  }
  if (nrow(data2)!=nrow(unique(data2, by=keys))) stop("Rows not uniquely identified by keys in data2.")
  if (noisily==T) cat("", sep = "\n")

  ##############################################################################

  # Actual merge
  data1$data1 <- data2$data2 <- 1
  merged <- merge(x = data1, y = data2, by=keys, all=T)

  # Examine merge result
  merge_result <- print_merge_results(dt=merged, disp_vars=disp_vars)

  if (noisily==T) {
    cat(format(as_tibble(merge_result[,..disp_vars]))[-c(1,3)], sep = "\n")
    cat("",sep="\n")
  }

  if (nrow(merge_result[data1==1 & data2==1])==0) stop("No observations matched! Check keys.")

  # Abort
  if (abort==T) {

    # Only row in merge result has data1==1 & data2==1
    if ( nrow(merge_result)!=1 & nrow(merge_result[data1==1 & data2==1])==1 ) {

      cat("  At least one observation is mismatched!", sep="\n\n")
      cat("", sep="\n")

      if (noisily==F) {
        cat(format(as_tibble(merge_result[,..disp_vars]))[-c(1,3)], sep = "\n")
        cat("",sep="\n")
      }

      warning("  Setting join_type to outer, and returning data1 and data2 merge variables.
              Specify abort=F to override this behavior. Use this to diagnose: dt[is.na(data2)] or dt[is.na(data1)] or dt[is.na(data1) | is.na(data2)]")
      join_type <- "outer"
      keep_merge_vars <- T
      noisily <- F

    }

  }

  rm(data1, data2, disp_vars, print_merge_results, merge_result)

  # Join type
  if (join_type=="inner") {

    if (noisily==T) {
      cat("  Inner join, dropping mismatched observations from data1 and data2 (if any), minus ")
      cat(paste0(abs(nrow(merged[data1==1 & data2==1])-nrow(merged)), " observations"), sep = "\n")
    }
    merged <- merged[data1==1 & data2==1]

  } else if (join_type=="left") {

    if (noisily==T) {
      cat("  Left join, dropping mismatched observations from data2 (if any), minus ")
      cat(paste0(abs(nrow(merged[(data1==1 & data2==1) | (data1==1 & is.na(data2))])-nrow(merged)), " observations"), sep = "\n")
    }
    merged <- merged[(data1==1 & data2==1) | (data1==1 & is.na(data2))]

  } else if (join_type=="right") {

    if (noisily==T) {
      cat("  Right join, dropping mismatched observations from data1 (if any), minus ")
      cat(paste0(abs(nrow(merged[(data1==1 & data2==1) | (data2==1 & is.na(data1))])-nrow(merged)), " observations"), sep = "\n")
    }
    merged <- merged[(data1==1 & data2==1) | (data2==1 & is.na(data1))]

  } else {

    if (noisily==T) {
      cat("  Outer join (default), no observations dropped.", sep = "\n")
    }

  }

  # Delete merge variables
  if (keep_merge_vars==F) merged$data1 <- merged$data2 <- NULL

  # Convert to class
  if (return_class=="tibble")     merged <- as_tibble(merged)
  if (return_class=="data.frame") merged <- as.data.frame(merged)

  if (noisily==T) cat(" ", sepby="\n")

  return(merged)

}
