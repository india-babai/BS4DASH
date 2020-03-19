#### Chapter 0: Loading csv data(with the specific format) to influxDB ####
# InfluxDB Database contains many measurements
# measurements ---> table-name
# tag ---> Character variable (group_by variable)
# field ---> floating/numeric variable on which time series will be plotted 

# Setting up the connection in influxDB: For rerun uncomment the the following
# library(influxdbr)
# library(RJSONIO)
# library(dplyr)
# library(magrittr)
# library(data.table)
# library(stringr)
# con <- influxdbr::influx_connection(host = "localhost",
#                                     port = 8086,
#                                     user = "username",
#                                     pass = "password")
# database_name <- "example3"
# measurement_name <- "two_mab_test_run"
# create_database(con = con, db = database_name)
# data_path <- "D:/DS/IoT my task/AP/bs4dash/IoT/inputs/testing/"
# # # 
# # # # Set the working directory
# setwd("D:/DS/IoT my task/AP/bs4dash/IoT/")
# # # 
# source("1_csv_influx_injest.R")
# injest_csv(con, database_name = database_name, measurement_name = measurement_name, path = data_path, precision = "m")

# drop_measurement(con = con, db = database_name, measurement = measurement_name)






#### Chapter 1: influxdb data base address , database name and the measurement name ####
  # Connection must be established to the influxDB database before running tje following script
  # Database contains many measurements
  # measurements ---> table-name
  # tag ---> Character variable (group_by variable)
  # field ---> floating/numeric variable on which time series will be plotted 

# This chapter is for testing/debugging the data(that goes into shiny) in local environment

con <- influxdbr::influx_connection(host = "localhost",
                                    port = 8086,
                                    user = "username",
                                    pass = "password")
influxdbr::show_databases(con)
influxdbr::drop_database(con, "example3")

# database_name <- "example3"
database_name <- "example"
measurement_name <- "two_mab_test_run"

dat <-
  influxdbr::influx_select(con,
                           db = database_name,
                           measurement = measurement_name,
                           # field_keys = "X_ut, Y_ut, Z_ut, T_c", #Required for database 'example3'
                           field_keys = '"X(uT)",	"Y(uT)",	"Z(uT)",	"T(*C)"', #Required for database 'example'
                           where = "time < '2020-03-10 16:53:56' and time > '2020-01-07 17:31:00'
                           and mag_type = 'LIS3MDL' and ( Sensor = '1' or Sensor = '2' or Sensor = '3' ) ",
                           group_by = "mag_type, Sensor",
                           limit = 20000,
                           return_xts = F)[[1]]
# 12:23:58

final <- dat[,c("series_names", "Sensor", "mag_type", "time","X(uT)",	"Y(uT)",	"Z(uT)",	"T(*C)")]
tsdyplot(final, "X(uT)", title_comp = "")
t <- final$time

t1 <- as.character(t)
t2 <- as.POSIXct(t1, tz = Sys.timezone())
final$time <- t2
