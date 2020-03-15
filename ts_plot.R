
#### DYGRAPH ####
# install_load("dygraphs")
# 
# dy_val <- final %>% 
#   dplyr::filter(Sensor == '1') %>% 
#   select(time, `X(uT)`, `Y(uT)`, `Z(uT)`)
# 
# test <- final %>% reshape2::dcast(time ~ Sensor, value.var = "X(uT)")
# 
# dat_xts <- xts::xts(x = test[,-1], order.by = test$time)
# dygraph(data = dat_xts) %>% 
#   dyOptions(fillGraph = F, fillAlpha = 0.1)
#   
tsdyplot <- function(data, var, title_comp){
  try({
    
    # The following hack is needed as dygraph can't work in arbitrary timezone; 
    # It always work in system's timezone; But the influxDB time is in GMT; So to make sure that 
    # time labels of DYGRAPH are in exactly same format as in influxDB, the following is needed
    data$time <- data$time %>% 
      as.character() %>% 
      as.POSIXct(tz = Sys.timezone())
    #
    
  temp <- data %>% 
    dplyr::mutate(Sensor = paste("Sensor ", Sensor)) %>% 
    reshape2::dcast(time ~ Sensor, value.var = var)
  dat_xts <- xts::xts(x = temp %>% dplyr::select(-time), order.by = temp$time)
  
  dygraph(data = dat_xts, xlab = "Time (GMT)", ylab = var, main = paste0(var, " over time (", title_comp, ")")) %>% 
    dyOptions(fillGraph = F, fillAlpha = 0.1, axisLineWidth = 1.5) %>% 
    dyRangeSelector()
  })
  
}

