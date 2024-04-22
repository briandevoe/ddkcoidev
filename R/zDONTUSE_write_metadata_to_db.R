# heading ------------------------------------------------------------------------------------------

# purpose: write metadata tables to sql database
# authors: brian devoe

# clear environment
rm(list=ls());gc()

# libraries
library(data.table)
library(tidyverse)
library(RMariaDB)

# run time
start <- Sys.time()

# path
path <- "C:/Users/bdevoe/Dropbox/COI30/Production/SQL/"

# connect to db ------------------------------------------------------------------------------------

# Connect to Brandeis office server (need to be connected with Pulse secure)
con <- dbConnect(RMariaDB::MariaDB(),
                 host='129.64.58.140',
                 port=3306,
                 user='dba1',
                 password='Password123$')

# create database
# dbGetQuery(con, "CREATE DATABASE coi_test;")
# dbGetQuery(con, "DROP DATABASE coi_test;")
dbGetQuery(con, "SHOW DATABASES;")
dbGetQuery(con, "USE coi_test;")
dbGetQuery(con, "SHOW tables;")

# run if dbWriteTable isn't working
# dbSendQuery(con, "SET GLOBAL local_infile = true;")
# dbExecute(con, "SET default_storage_engine=InnoDB;")

# write to db --------------------------------------------------------------------------------------

# geography <- c("METROS","NATION","NATION-METROS","OPP_GAP","STATES", "ZIP", "TRACT")
geography <- c("METROS")
for(geo in geography){

  # path for data
  import_path <- paste0(path, geo, "/")
  
  # file names
  file_names <- list.files(path = import_path)
  file_names_fixed <- gsub("-", "_", file_names)
  
  # load indicators data
  for(i in 1:length(file_names)){
    
    # print current file to import and export from dropbox to MySQL db
    print(file_names_fixed[[i]])
    
    # # write metadata table to database 
    if(file.exists(    paste0(import_path, file_names[[i]], "/", file_names[[i]], "_metadata.csv"))){
      dt_meta <- fread(paste0(import_path, file_names[[i]], "/", file_names[[i]], "_metadata.csv"))
      names_dt <- names(dt_meta)
      fields <- setNames(rep("text(10)", length(names_dt)), names_dt) # set field type
      dbWriteTable(con, name=paste0(file_names_fixed[[i]], "_metadata"), value=dt_meta, overwrite=TRUE, row.names=F)
      rm(fields, dt_meta, names_dt)
    }
  }
}
rm(i,geo,geography,file_names,file_names_fixed,import_path,path)

# run time
end <- Sys.time()
print(end-start)

# disconnect from server
dbDisconnect(con);rm(con)
