#' @name SQL_load
#' @title SQL_load
#' @description load table from SQL database

# libraries
library(RMariaDB)

# function: load_db
load_db <- function(table = NULL){

  # Connect to Brandeis office SQL database
  # TODO: throw error if not connected to pulse
  con <- dbConnect(RMariaDB::MariaDB(),
                   host='129.64.58.140', port=3306,
                   user='dba1', password='Password123$')

  # connect to coi database
  dbGetQuery(con, "USE coi;")

  # load table
  dt <- dbGetQuery(con, paste0("SELECT * FROM ", table, ";"))

  # disconnect from server
  dbDisconnect(con);rm(con)

  # return
  return(dt)
}

