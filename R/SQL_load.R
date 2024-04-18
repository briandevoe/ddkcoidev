#' @name SQL_load
#' @title SQL_load
#' @author brian devoe
#'
#' @description
#' load table from SQL database
#'
#' @param table name of table from SQL coi database to load into R environment. See SQL_table function for list of tables.
#' @param database name of database to connect to. Default is 'coi'.


# function: load_db
SQL_load <- function(table = NULL, database = NULL){

  # Connect to Brandeis office SQL database
  # TODO: throw error if not connected to pulse
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),
                   host='129.64.58.140', port=3306,
                   user='dba1', password='Password123$')

  # connect to coi database
  RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))

  # load table
  dt <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table, ";"))

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return
  return(dt)
}

