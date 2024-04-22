#' @name SQL_tables
#' @title SQL_tables
#' @author brian devoe
#'
#' @description
#' Call function to list available tables in COI SQL database
#'
#' @param database Name of database to connect to. Default is 'coi'.


# TODO: add metadata functionality? it simply attaches to the 'tables' datatable as new columns


# function list tables
SQL_tables <- function(database = NULL){

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

  # load tables list
  tables <- RMariaDB::dbGetQuery(con, "SHOW TABLES;")

  # disconnect from server
  RMariaDB::dbDisconnect(con);rm(con)

  # return
  return(tables)
}
