#' @name SQL_tables
#' @title SQL_tables
#' @author brian devoe
#' @description Call function to list available tables in COI SQL database

# libraries
library(RMariaDB)

# function list tables
list_tables <- function(){

  # Connect to Brandeis office SQL database
  # TODO: throw error if not connected to pulse
  con <- dbConnect(RMariaDB::MariaDB(),
                   host='129.64.58.140', port=3306,
                   user='dba1', password='Password123$')

  # connect to coi database
  dbGetQuery(con, "USE coi")

  # load table
  tables <- dbGetQuery(con, "SHOW TABLES;")

  # disconnect from server
  dbDisconnect(con);rm(con)

  # return
  return(tables)
}
