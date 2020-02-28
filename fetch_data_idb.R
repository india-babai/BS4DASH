#### Chapter 0: Loading csv data(with the specific format) to influxDB ####
# Database contains many measurements
# measurements ---> table-name
# tag ---> Character variable (group_by variable)
# field ---> floating/numeric variable on which time series will be plotted 

# Setting up the connection in influxDB
library(influxdbr)
library(RJSONIO)
library(dplyr)
library(magrittr)
library(data.table)
library(stringr)
con <- influxdbr::influx_connection(host = "localhost",
                                    port = 8086,
                                    user = "username",
                                    pass = "password")
database_name <- "example3"
measurement_name <- "two_mab_test_run"
create_database(con = con, db = database_name)
data_path <- "D:/DS/IoT my task/AP/bs4dash/IoT/inputs/testing/"
# # 
# # # Set the working directory
setwd("D:/DS/IoT my task/AP/bs4dash/IoT/")
# # 
source("1_csv_influx_injest.R")
injest_csv(con, database_name = database_name, measurement_name = measurement_name, path = data_path)

# drop_measurement(con = con, db = database_name, measurement = measurement_name)






#### Chapter 1: influxdb data base address , database name and the measurement name ####
  # Connection must be established to the influxDB database before running tje following script
  # Database contains many measurements
  # measurements ---> table-name
  # tag ---> Character variable (group_by variable)
  # field ---> floating/numeric variable on which time series will be plotted 


con <- influxdbr::influx_connection(host = "localhost",
                                    port = 8086,
                                    user = "username",
                                    pass = "password")
influxdbr::show_databases(con)
# influxdbr::drop_database(con, "example3")

database_name <- "example3"
measurement_name <- "two_mab_test_run"

dat <-
  influxdbr::influx_select(con,
                           db = database_name,
                           measurement = measurement_name,
                           field_keys = "X_ut, Y_ut, Z_ut, T_c",
                           where = "time = '2020-01-07 16:52:57' and mag_type = 'LIS3MDL' ",
                           limit = 10000,
                           return_xts = F)[[1]]
# 12:23:58

sapply(dat, function(x)all(is.na(x))) %>% sum()


mat <- matrix(dat$X_ut, nrow = 10, ncol = 10, byrow = T)


values <- round(mat,2)
title <- paste("3D plot from influxDB")
mgf_submit_1 <- list(values, title)
heatmap_3d(mgf_submit_1)



