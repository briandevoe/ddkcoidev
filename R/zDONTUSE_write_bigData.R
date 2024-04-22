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
# dbGetQuery(con, "DROP DATABASE coi_test;")
# dbGetQuery(con, "CREATE DATABASE coi_test;")
dbGetQuery(con, "USE coi_test;")
dbGetQuery(con, "SHOW tables;")

# set to write big data to server
# dbGetQuery(con, "SET GLOBAL innodb_strict_mode = 0;")

# load and fix data ---------------------------------------------------------------------------

# paths to data
path <- "C:/Users/bdevoe/Desktop/SQL/METROS/COI_10_metros_met_averages/"
IN   <- "COI_10_metros_met_averages.csv"
OUT  <- gsub(".csv", "", IN) ; OUT <- gsub("-", "_", OUT)

# load data
dt <- read.csv(paste0(path, IN), colClasses="character")
# dt <- fread(paste0(path, IN), colClasses = c("geoid20"="character"))

# column names
names <- colnames(dt)
# names[1] <- paste0(names[1], " text(11)")
# names[2] <- paste0(names[2], " int(4)")
# for(i in 3:length(names)){
#   names[i] <- paste0(names[i], " int(10)")
# }

for(i in 1:length(names)){
  names[i] <- paste0(names[i], " text(11)")
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

# create table
create_table <- paste0("CREATE TABLE ", OUT, " (", names_str, ");")
dbExecute(con, create_table)
rm(create_table)

# write table
start <- Sys.time()
query <- paste0("LOAD DATA LOCAL INFILE '", paste0(path,IN), "' INTO TABLE ", OUT," FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';")
dbGetQuery(con, query)
end <- Sys.time(); print(paste0("write time: ", end-start))

# load table
start2 <- Sys.time()
dt2 <- dbGetQuery(con, paste0("SELECT * FROM ", OUT, ";"))
end2 <- Sys.time(); print(paste0("load time: ", end2-start2))

# disconnect from server
dbDisconnect(con);rm(con)


