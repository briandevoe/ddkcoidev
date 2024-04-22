#' @name SQL_load
#' @title SQL_load
#' @author brian devoe
#'
#' @description
#' load table from SQL database
#'
#' @param table    Name of table from SQL database to load into R environment.
#'                 See SQL_table function for list of tables.
#' @param database Name of database to connect to. Default is 'coi'.
#' @param columns  Columns to load from table. Default is all columns.
#' @param dictionary Load dictionary table. Default is FALSE.
#' @param metadata   Load metadata table. Default is FALSE.


# FIXME: Can we return multiple objects? i.e. a seperate table, dictionary, and metadata object?
#        Would saving them to a list be ok? Maybe seperate functions?


# function: load_db
SQL_load <- function(table = NULL, database = NULL, columns = NULL, dictionary = FALSE, metadata = FALSE){

  # Connect to Brandeis office SQL database
  # TODO: throw error if not connected to pulse
  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),
                   host='129.64.58.140', port=3306,
                   user='dba1', password='Password123$')

  # connect to coi database
  if(is.null(database)){
    RMariaDB::dbGetQuery(con, "USE coi;")}
  if(!is.null(database)){
    RMariaDB::dbGetQuery(con, paste0("USE ", database, ";"))}

  # load table
  if(is.null(columns)){
    dt <- RMariaDB::dbGetQuery(con, paste0("SELECT * FROM ", table, ";"))}
  if(!is.null(columns)){
    dt <- RMariaDB::dbGetQuery(con, paste0("SELECT ", columns, " FROM ", table, ";"))}

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return
  return(dt)
}

