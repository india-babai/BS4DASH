fromToInput <- function(id, label = "From date", offset = 365){
  ns <- NS(id)
  
  tagList(
  dateInput(inputId = ns("date_range"), label = label, value = Sys.Date() - offset, width = "80%"),
  sliderInput(
    ns("time_range"),
    "",
    min = as.POSIXct("2017-01-01 00:00:00"),
    max = as.POSIXct("2017-01-01 23:59:59"),
    value = c(
      as.POSIXct("2017-01-01 12:00:00")),
    timeFormat = "%T",
    step = 30
  )
  )
  
}

fromTo <- function(input, output, session){
  
  date_time_paste <- function(date, time){
    # date should be in date format
    # time should be in POSIXct format
    time <- strftime(time, format = "%H:%M:%S")
    paste0(date, " ",time)
  }
  
  date_time <- reactive( date_time_paste(date = input$date_range, input$time_range))
  date_time

}





