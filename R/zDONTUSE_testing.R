# heading ------------------------------------------------------------------------------------------

#'@author brian devoe
#'@description write larger coi data files as tables to sql database

# clear environment
rm(list=ls());gc()

# libraries
library(data.table)
library(tidyverse)
library(RMariaDB)


# connect to db ------------------------------------------------------------------------------------

# Connect to Brandeis office server (need to be connected with Pulse secure)
con <- dbConnect(RMariaDB::MariaDB(),
                 host='129.64.58.140', port=3306,
                 user='dba1', password='Password123$')

# create database
dbGetQuery(con, "SHOW DATABASES;")
dbGetQuery(con, "USE coi_test;")
dbGetQuery(con, "SHOW tables;")
# dbExecute( con, "DROP TABLE indicators_20_raw;")
# dbExecute(con, "CREATE DATABASE coi_test;")
# dbExecute(con, "DROP DATABASE coi_test;")

# set to write big data to server
# dbGetQuery(con, "SET GLOBAL innodb_strict_mode = 0;")

# load and fix data ---------------------------------------------------------------------------

geography <- c("METROS","NATION","NATION-METROS","OPP_GAP","STATES")
# geography <- c("METROS","NATION","NATION-METROS","OPP_GAP","STATES", "ZIP", "TRACT")

for(geo in geography){
  
  # paths to data
  path <- paste0("C:/Users/bdevoe/Desktop/SQL/", geo, "/")
  
  for(file in list.files(path)){

    IN   <- file
    OUT  <- gsub(".csv", "", IN) ; OUT <- gsub("-", "_", OUT)
    
    # load data
    dt <- fread(paste0(path, IN, "/", IN, ".csv"), colClasses = "character")
    
    # column names
    names <- colnames(dt)
    for(i in 1:length(names)){
      names[i] <- paste0(names[i], " text(15)")
    }
    
    # fix column names for sql query
    names_str <- ""
    for(i in 1:length(names)){
      if(i == length(names)){names_str <- paste0(names_str, names[i])}
      else {names_str <- paste0(names_str, names[i], ", ")}
    }; rm(i,names)
    
  
    # create table --------------------------------------------------------------------------------
    
    # MySQL syntax for creating a table
    # CREATE TABLE table_name (
    #     column1 datatype,
    #     column2 datatype,
    #     column3 datatype,
    #    ....
    # );
    asdf
    # create table
    create_table <- paste0("CREATE TABLE ", OUT, " (", names_str, ");")
    dbExecute(con, create_table)
    rm(create_table)
    
    # write table
    start <- Sys.time()
    query <- paste0("LOAD DATA LOCAL INFILE '", paste0(path, IN, "/", IN, ".csv"), "' INTO TABLE ", OUT," FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';")
    dbGetQuery(con, query)
    end <- Sys.time(); print(paste0("write time: ", OUT, ": ", end-start))
  
    }
}

# disconnect from server
dbDisconnect(con);rm(con)


