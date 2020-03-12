
#### DYGRAPH ####
install_load("dygraphs")

dy_val <- final %>% 
  dplyr::filter(Sensor == '1') %>% 
  select(time, `X(uT)`, `Y(uT)`, `Z(uT)`)

test <- final %>% reshape2::dcast(time ~ Sensor, value.var = "X(uT)")

dat_xts <- xts::xts(x = test[,-1], order.by = test$time)
dygraph(data = dat_xts) %>% 
  dyOptions(fillGraph = F, fillAlpha = 0.1)
  
tsdyplot <- function(data, var){
  try({
  temp <- data %>% 
    dplyr::mutate(Sensor = paste("Sensor ", Sensor)) %>% 
    reshape2::dcast(time ~ Sensor, value.var = var)
  dat_xts <- xts::xts(x = temp[,-1], order.by = temp$time)
  
  dygraph(data = dat_xts, xlab = "Time", ylab = var, main = paste(var, " over time")) %>% 
    dyOptions(fillGraph = F, fillAlpha = 0.1, axisLineWidth = 1.5) %>% 
    dyRangeSelector()
  })
  
}
tsdyplot(final, "Y(uT)")
s <- tsdyplot(data.frame(), "X")
