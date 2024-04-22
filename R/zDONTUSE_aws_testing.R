# heading ------------------------------------------------------------------------------------------

# purpose: write to sql database
# authors: brian devoe

# clear environment
rm(list=ls());gc()

# libraries
library(data.table)
library(tidyverse)
library(RMariaDB)
# library(RMySQL)

# run time
start <- Sys.time()

# path
path <- "C:/Users/bdevoe/Dropbox/COI30/Production/SQL/"
# path <- "Dropbox/COI30/Production/SQL/"


# connect to db ------------------------------------------------------------------------------------

# Cannot connect within Brandeis firewall
con <- dbConnect(RMariaDB::MariaDB(),
                 host='database-1.cvtvfnlr2etb.us-east-2.rds.amazonaws.com',
                 port=3306,
                 user='admin',
                 password='CarlGauss2023')

# create database
# dbGetQuery(con, "DROP DATABASE coi;")
dbGetQuery(con, "SHOW DATABASES;")
# dbGetQuery(con, "CREATE DATABASE coi;")
dbGetQuery(con, "USE coi")
dbGetQuery(con, "SHOW tables;")

# run if dbWriteTable isn't working
# dbSendQuery(con, "SET GLOBAL local_infile = true;")
# dbExecute(con, "SET default_storage_engine=InnoDB;")


# # write to db --------------------------------------------------------------------------------------
# 
# geography <- c("METROS")
# itr=0
# for(geo in geography){
# 
#   # path for data
#   # import_path <- paste0("C:/Users/bdevoe/Desktop/SQL/", geo, "/")
#   import_path <- paste0(path, geo, "/")
#   
#   # file names
#   file_names <- list.files(path = import_path)
#   file_names <- file_names[1:5]
#   file_names_fixed <- gsub("-", "_", file_names)
#   
#   # load indicators data
#   for(i in 1:length(file_names)){
#   # for(i in 1:20){
#  
#     # print current file to import and export from dropbox to MySQL db
#     itr=itr+1
#     print(paste0(itr, ": ", file_names_fixed[[i]]))
#     
#     
#     # load data
#     if(file.exists(paste0(import_path, file_names[[i]], "/", file_names[[i]], ".csv"))){
#       dt <- fread( paste0(import_path, file_names[[i]], "/", file_names[[i]], ".csv"))
#       names_dt <- names(dt)
#       fields <- setNames(rep("text(10)", length(names_dt)), names_dt) # set field type
#       dbWriteTable(con, name=file_names_fixed[[i]], value=dt, field.types=fields, overwrite=TRUE, row.names=F)
#       rm(fields, dt, names_dt)
#     }
#     
#     # write metadata table to database 
#     if(file.exists(    paste0(import_path, file_names[[i]], "/", file_names[[i]], "_metadata.csv"))){
#       dt_meta <- fread(paste0(import_path, file_names[[i]], "/", file_names[[i]], "_metadata.csv"))
#       names_dt <- names(dt_meta)
#       fields <- setNames(rep("text(10)", length(names_dt)), names_dt) # set field type
#       dbWriteTable(con, name=paste0(file_names_fixed[[i]], "_metadata"), value=dt_meta, overwrite=TRUE, row.names=F)
#       rm(fields, dt_meta, names_dt)
#     }
#     
#   }
#   rm(i)
#   
# }
# rm(geo,geography,file_names,file_names_fixed,import_path,path)
# 
# # run time
# end <- Sys.time()
# print(end-start)
# 
# # disconnect from server
# dbDisconnect(con);rm(con)


