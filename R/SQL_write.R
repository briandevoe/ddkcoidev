#' @name SQL_write
#' @title SQL_write
#' @author brian devoe
#'
#' @description
#' write table from given directory to COI SQL database
#'
#' @param infile path to file to write to SQL database
#' @param table_name name of table to write to in SQL database

# libraries
# library(data.table)
# library(tidyverse)
# library(RMariaDB)


SQL_write <- function(infile = NULL, table_name = NULL){


  # need to get table names from infile
  # TODO: make this part of the script more efficient
  #-----------------------------------------
  # read table
  table <- read.csv(infile, colClasses="character")
  # table <- read.csv(infile)
  # table <- fread(infile)

  # column names
  names <- colnames(table)
  for(i in 1:length(names)){
    names[i] <- paste0(names[i], " text(11)")
  }
  # fix column names for sql query
  names_str <- ""
  for(i in 1:length(names)){
    if(i == length(names)){names_str <- paste0(names_str, names[i])}
    else {names_str <- paste0(names_str, names[i], ", ")}
  }; rm(i,names)

  rm(table)
  #-----------------------------------------





  # SQL portion of function
  #-----------------------------------------
  # TODO: warning message if writing to a table that already exists
  # TODO: error stop message if can't write table for other reasons
  # set to write big data to server
  # dbGetQuery(con, "SET GLOBAL innodb_strict_mode = 0;")

  # Connect to Brandeis office SQL database
  # TODO: throw error if not connected to pulse
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),
                   host='129.64.58.140', port=3306,
                   user='dba1', password='Password123$')

  # select coi db
  # dbGetQuery(con, "USE coi;")
  RMariaDB::dbGetQuery(con, "USE coi_test;")




  # MySQL syntax for creating a table
  # CREATE TABLE table_name (
  #     column1 datatype,
  #     column2 datatype,
  #     column3 datatype,
  #    ....
  # );

  # create table
  create_table <- paste0("CREATE TABLE ", table_name, " (", names_str, ");")
  RMariaDB::dbExecute(con, create_table)
  rm(create_table)

  # write table
  start <- Sys.time()
  query <- paste0("LOAD DATA LOCAL INFILE '", infile_path, "' INTO TABLE ", table_name," FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';")
  RMariaDB::dbGetQuery(con, query)
  end <- Sys.time()

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  return(paste0("Time to write table: ", end-start))

}
